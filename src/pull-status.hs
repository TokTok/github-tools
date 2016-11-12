{-# LANGUAGE OverloadedStrings #-}
module Main (main) where

import           Control.Applicative     ((<$>))
import qualified Control.Monad.Parallel  as Parallel
import qualified Data.ByteString.Char8   as BS8
import           Data.Time.Clock         (getCurrentTime)
import qualified Data.Vector             as V
import qualified GitHub
import qualified GitHub.Data.Id          as GitHub
import           Network.HTTP.Client     (Manager, newManager)
import           Network.HTTP.Client.TLS (tlsManagerSettings)
import           System.Environment      (getEnv, lookupEnv)

import           PullRequestInfo         (PullRequestInfo (PullRequestInfo))
import qualified PullRequestInfo
import           Requests
import qualified Review


getFullPr
  :: GitHub.Auth
  -> Manager
  -> GitHub.Name GitHub.Owner
  -> GitHub.Name GitHub.Repo
  -> GitHub.SimplePullRequest
  -> IO GitHub.PullRequest
getFullPr auth mgr owner repo simplePr = do
  request auth mgr
    . GitHub.pullRequestR owner repo
    . GitHub.Id
    . GitHub.simplePullRequestNumber
    $ simplePr


getPrInfo
  :: GitHub.Auth
  -> Manager
  -> GitHub.Name GitHub.Owner
  -> GitHub.Name GitHub.Repo
  -> GitHub.SimplePullRequest
  -> IO ([Review.Status], GitHub.PullRequest)
getPrInfo auth mgr ownerName repoName pr = do
  -- Use assignees as the initial approvals list, all responses unknown.
  let assignees = V.toList $ GitHub.simplePullRequestAssignees pr
  let initApprovals = map (Review.Status Review.Unknown . GitHub.untagName . GitHub.simpleUserLogin) assignees
  -- Fetch and parse HTML pages for this PR.
  approvals <- Review.approvalsFromHtml initApprovals <$> Review.fetchHtml mgr pr
  -- Get more information that is only in the PullRequest response.
  fullPr <- getFullPr auth mgr ownerName repoName pr
  return (approvals, fullPr)


getPrsForRepo
  :: GitHub.Auth
  -> Manager
  -> GitHub.Name GitHub.Owner
  -> GitHub.Name GitHub.Repo
  -> IO [PullRequestInfo]
getPrsForRepo auth mgr ownerName repoName = do
  -- Get PR list.
  simplePRs <- V.toList <$> request auth mgr (GitHub.pullRequestsForR ownerName repoName GitHub.stateOpen GitHub.FetchAll)

  prInfos <- Parallel.mapM (getPrInfo auth mgr ownerName repoName) simplePRs

  return $ map (uncurry $ PullRequestInfo repoName) prInfos


main :: IO ()
main = do
  let orgName = "TokTok"
  let ownerName = "TokTok"

  -- Get auth token from the $GITHUB_TOKEN environment variable.
  token <- BS8.pack <$> getEnv "GITHUB_TOKEN"
  let auth = GitHub.OAuth token

  -- Check if we need to produce HTML or ASCII art.
  wantHtml <- (/= Nothing) <$> lookupEnv "GITHUB_WANT_HTML"

  -- Initialise HTTP manager so we can benefit from keep-alive connections.
  mgr <- newManager tlsManagerSettings

  -- Get repo list.
  repos <- V.toList <$> request auth mgr (GitHub.organizationReposR orgName GitHub.RepoPublicityAll GitHub.FetchAll)
  let repoNames = map GitHub.repoName repos

  infos <- Parallel.mapM (getPrsForRepo auth mgr ownerName) repoNames

  -- Pretty-print table with information.
  now <- getCurrentTime
  putStrLn $ PullRequestInfo.formatPR wantHtml now infos
