{-# LANGUAGE DataKinds #-}
module Requests where

import           Control.Monad.Catch (throwM)
import qualified GitHub
import           Network.HTTP.Client (Manager)


request
  :: Maybe GitHub.Auth
  -> Manager
  -> GitHub.Request 'GitHub.RO a
  -> IO a
request auth mgr req = do
  response <- executeRequest
  case response of
    Left  err -> throwM err
    Right res -> return res

  where
    executeRequest =
      case auth of
        Nothing -> GitHub.executeRequestWithMgr' mgr req
        Just tk -> GitHub.executeRequestWithMgr mgr tk req
