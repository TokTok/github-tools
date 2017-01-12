{-# LANGUAGE CPP                   #-}
{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE DeriveGeneric         #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE PolyKinds             #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE TypeOperators         #-}
module TokTok.Hello (newApp) where

import           Caching.ExpiringCacheMap.HashECM (CacheSettings (..), ECM,
                                                   consistentDuration,
                                                   lookupECM, newECMIO)
import           Control.Applicative              ((<$>), (<*>))
import           Control.Concurrent.MVar          (MVar)
import           Control.Monad.Trans              (lift)
import           Data.Aeson                       (FromJSON, ToJSON)
import qualified Data.ByteString.Char8            as BS8
import qualified Data.ByteString.Lazy             as LBS
import           Data.HashMap.Strict              (HashMap)
import           Data.Monoid                      ((<>))
import           Data.Text                        (Text)
import qualified Data.Text                        as Text
import           Data.Text.Encoding               (encodeUtf8)
import qualified Data.Time.Clock.POSIX            as POSIX
import           GHC.Generics                     (Generic)
import qualified GitHub
import           Network.HTTP.Media               ((//), (/:))
#if !MIN_VERSION_servant_server(0, 6, 0)
import           Network.Wai                      (Application)
#endif
import           Servant
import           System.Environment               (getEnv)

import qualified Changelogs
import           PullRequestInfo                  (PullRequestInfo)
import qualified PullStatus


type PullRequestCache = ECM IO MVar () HashMap () [[PullRequestInfo]]


data ApiContext = ApiContext
  { getChangelog :: Changelogs.ChangeLog
  , getRoadmap   :: Changelogs.ChangeLog
  , pullInfos    :: PullRequestCache
  }


newPullInfoCache :: Maybe GitHub.Auth -> IO PullRequestCache
newPullInfoCache auth =
  newECMIO
    (consistentDuration 30 $ \state () -> do
      infos <- PullStatus.getPullInfos "TokTok" "TokTok" auth
      return (state, infos))
    (do time <- POSIX.getPOSIXTime
        return $ round time)
    1
    (CacheWithLRUList 1 1 1)


newContext :: IO ApiContext
newContext = do
  auth <- Just . GitHub.OAuth . BS8.pack <$> getEnv "GITHUB_TOKEN"

  ApiContext
    <$> Changelogs.fetchChangeLog False "TokTok" "c-toxcore" auth
    <*> Changelogs.fetchChangeLog True  "TokTok" "c-toxcore" auth
    <*> newPullInfoCache auth


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
       -- Link to the source code repository, to comply with AGPL.
       "source" :> Get '[PlainText] Text

       -- GET /hello/:name?capital={true, false}  returns a Greet as JSON
  :<|> "hello" :> Capture "name" Text :> QueryParam "capital" Bool :> Get '[JSON] Greet

  :<|> "changelog" :> Get '[PlainText] Text
  :<|> "roadmap" :> Get '[PlainText] Text
  :<|> "pulls.html" :> Get '[HTML] Text
  :<|> "pulls" :> Get '[JSON] [[PullRequestInfo]]

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
       sourceH
  :<|> helloH
  :<|> changelogH False
  :<|> changelogH True
  :<|> pullsHtmlH
  :<|> pullsH
  :<|> postGreetH
  :<|> deleteGreetH
  where
    sourceH = return "https://github.com/TokTok/github-tools"

    helloH name Nothing      = helloH name (Just False)
    helloH name (Just False) = return . Greet $ "Hello, " <> name
    helloH name (Just True)  = return . Greet . Text.toUpper $ "Hello, " <> name

    changelogH False = return $ Changelogs.formatChangeLog False (getChangelog ctx)
    changelogH True  = return $ Changelogs.formatChangeLog True  (getRoadmap ctx)

    pullsHtmlH = lift $ do
      infos <- lookupECM (pullInfos ctx) ()
      PullStatus.showPullInfos True infos
    pullsH = lift $ lookupECM (pullInfos ctx) ()

    postGreetH = return

    deleteGreetH _ = return NoContent

-- Turn the server into a WAI app. 'serve' is provided by servant,
-- more precisely by the Servant.Server module.
app :: ApiContext -> Application
app = serve testApi . server

newApp :: IO Application
newApp = app <$> newContext
