{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE DeriveGeneric         #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE PolyKinds             #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE TypeOperators         #-}
module TokTok.Hello (newApp) where

import           Control.Applicative   ((<$>), (<*>))
import           Data.Aeson            (FromJSON, ToJSON)
import qualified Data.ByteString.Char8 as BS8
import qualified Data.ByteString.Lazy  as LBS
import           Data.Monoid           ((<>))
import           Data.Text             (Text)
import qualified Data.Text             as Text
import           Data.Text.Encoding    (encodeUtf8)
import           GHC.Generics          (Generic)
import qualified GitHub
import           Network.HTTP.Media    ((//), (/:))
import           Servant
import           System.Environment    (getEnv)

import qualified Changelogs
import qualified PullStatus


data ApiContext = ApiContext
  { getChangelog :: Changelogs.ChangeLog
  , getRoadmap   :: Changelogs.ChangeLog
  , getPulls     :: Text
  }


newContext :: IO ApiContext
newContext = do
  auth <- Just . GitHub.OAuth . BS8.pack <$> getEnv "GITHUB_TOKEN"

  ApiContext
    <$> Changelogs.fetchChangeLog False "TokTok" "c-toxcore" Nothing
    <*> Changelogs.fetchChangeLog True  "TokTok" "c-toxcore" Nothing
    <*> (Text.pack <$> PullStatus.getPullStatus "TokTok" "TokTok" True auth)


-- * Example

-- | A greet message data type
newtype Greet = Greet { _msg :: Text }
  deriving (Generic, Show)

instance FromJSON Greet
instance ToJSON Greet

data HTML
instance Accept HTML where
  contentType _ = "text" // "html" /: ("charset", "utf-8")
instance MimeRender HTML Text where
  mimeRender _ = LBS.fromStrict . encodeUtf8

-- API specification
type TestApi =
       -- GET /hello/:name?capital={true, false}  returns a Greet as JSON
       "hello" :> Capture "name" Text :> QueryParam "capital" Bool :> Get '[JSON] Greet

  :<|> "changelog" :> Get '[PlainText] Text
  :<|> "roadmap" :> Get '[PlainText] Text
  :<|> "pulls" :> Get '[HTML] Text

       -- POST /greet with a Greet as JSON in the request body,
       --             returns a Greet as JSON
  :<|> "greet" :> ReqBody '[JSON] Greet :> Post '[JSON] Greet

       -- DELETE /greet/:greetid
  :<|> "greet" :> Capture "greetid" Text :> Delete '[JSON] NoContent

testApi :: Proxy TestApi
testApi = Proxy

-- Server-side handlers.
--
-- There's one handler per endpoint, which, just like in the type
-- that represents the API, are glued together using :<|>.
--
-- Each handler runs in the 'Handler' monad.
server :: ApiContext -> Server TestApi
server ctx =
       helloH
  :<|> changelogH False
  :<|> changelogH True
  :<|> pullsH
  :<|> postGreetH
  :<|> deleteGreetH
  where
    helloH name Nothing      = helloH name (Just False)
    helloH name (Just False) = return . Greet $ "Hello, " <> name
    helloH name (Just True)  = return . Greet . Text.toUpper $ "Hello, " <> name

    changelogH False = return $ Changelogs.formatChangeLog False (getChangelog ctx)
    changelogH True  = return $ Changelogs.formatChangeLog True  (getRoadmap ctx)

    pullsH = return $ getPulls ctx

    postGreetH = return

    deleteGreetH _ = return NoContent

-- Turn the server into a WAI app. 'serve' is provided by servant,
-- more precisely by the Servant.Server module.
app :: ApiContext -> Application
app = serve testApi . server

newApp :: IO Application
newApp = app <$> newContext
