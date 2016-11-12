module Requests where

import           Control.Monad.Catch (throwM)
import qualified GitHub
import           Network.HTTP.Client (Manager)


request
  :: GitHub.Auth
  -> Manager
  -> GitHub.Request k a
  -> IO a
request auth mgr req = do
  response <- GitHub.executeRequestWithMgr mgr auth req
  case response of
    Left  err -> throwM err
    Right res -> return res
