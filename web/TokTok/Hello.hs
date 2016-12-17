{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PolyKinds         #-}
{-# LANGUAGE TypeFamilies      #-}
{-# LANGUAGE TypeOperators     #-}
module TokTok.Hello (newApp) where

import           Control.Monad.Trans (lift)
import           Data.Aeson          (FromJSON, ToJSON)
import           Data.IORef          (IORef)
import qualified Data.IORef          as IORef
import           Data.Monoid         ((<>))
import           Data.Text           (Text, toUpper)
import           GHC.Generics        (Generic)
import           Servant

import qualified Changelogs


data ApiContext = ApiContext
  { getChangelog :: IORef Changelogs.ChangeLog
  }


newContext :: IO ApiContext
newContext = ApiContext
  <$> (IORef.newIORef =<< Changelogs.fetchChangeLog "TokTok" "c-toxcore" Nothing)


-- * Example

-- | A greet message data type
newtype Greet = Greet { _msg :: Text }
  deriving (Generic, Show)

instance FromJSON Greet
instance ToJSON Greet

-- API specification
type TestApi =
       -- GET /hello/:name?capital={true, false}  returns a Greet as JSON
       "hello" :> Capture "name" Text :> QueryParam "capital" Bool :> Get '[JSON] Greet

       -- GET /hello/:name?capital={true, false}  returns a Greet as JSON
  :<|> "changelog" :> Get '[PlainText] Text

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
  :<|> changelogH
  :<|> postGreetH
  :<|> deleteGreetH
  where
    helloH name Nothing      = helloH name (Just False)
    helloH name (Just False) = return . Greet $ "Hello, " <> name
    helloH name (Just True)  = return . Greet . toUpper $ "Hello, " <> name

    changelogH = lift $ Changelogs.formatChangeLog <$> IORef.readIORef (getChangelog ctx)

    postGreetH greet = return greet

    deleteGreetH _ = return NoContent

-- Turn the server into a WAI app. 'serve' is provided by servant,
-- more precisely by the Servant.Server module.
app :: ApiContext -> Application
app = serve testApi . server

newApp :: IO Application
newApp = app <$> newContext
