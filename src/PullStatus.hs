{-# LANGUAGE OverloadedStrings #-}
module PullStatus
  ( getPullStatus
  , getPullInfos
  , showPullInfos
  ) where

import           Control.Applicative     ((<$>))
import qualified Control.Monad.Parallel  as Parallel
import qualified Data.List               as List
import           Data.Text               (Text)
import qualified Data.Text               as Text
import           Data.Time.Clock         (getCurrentTime)
import qualified Data.Vector             as V
import qualified GitHub
import qualified GitHub.Data.Id          as GitHub
import           Network.HTTP.Client     (Manager, newManager)
import           Network.HTTP.Client.TLS (tlsManagerSettings)

import           PullRequestInfo         (PullRequestInfo (..))
import qualified PullRequestInfo
import           Requests


getFullPr
  :: Maybe GitHub.Auth
  -> Manager
  -> GitHub.Name GitHub.Owner
  -> GitHub.Name GitHub.Repo
  -> GitHub.SimplePullRequest
  -> IO GitHub.PullRequest
getFullPr auth mgr owner repo =
  request auth mgr
    . GitHub.pullRequestR owner repo
    . GitHub.Id
    . GitHub.simplePullRequestNumber


getPrInfo
  :: Maybe GitHub.Auth
  -> Manager
  -> GitHub.Name GitHub.Owner
  -> GitHub.Name GitHub.Repo
  -> GitHub.SimplePullRequest
  -> IO ([Text], GitHub.PullRequest)
getPrInfo auth mgr ownerName repoName pr = do
  let assignees = V.toList $ GitHub.simplePullRequestAssignees pr
  let reviewers = map (GitHub.untagName . GitHub.simpleUserLogin) assignees
  -- Get more information that is only in the PullRequest response.
  fullPr <- getFullPr auth mgr ownerName repoName pr
  return (reviewers, fullPr)


makePullRequestInfo
  :: GitHub.Name GitHub.Repo
  -> ([Text], GitHub.PullRequest)
  -> PullRequestInfo
makePullRequestInfo repoName (reviewers, pr) = PullRequestInfo
  { prRepoName  = GitHub.untagName repoName
  , prNumber    = GitHub.pullRequestNumber pr
  , prUser      = user
  , prBranch    = Text.tail branch
  , prCreated   = GitHub.pullRequestCreatedAt pr
  , prTitle     = GitHub.pullRequestTitle pr
  , prReviewers = reviewers
  , prState     = showMergeableState $ GitHub.pullRequestMergeableState pr
  }
  where
    (user, branch) = Text.breakOn ":" . GitHub.pullRequestCommitLabel . GitHub.pullRequestHead $ pr

    showMergeableState GitHub.StateBehind   = "behind"
    showMergeableState GitHub.StateBlocked  = "blocked"
    showMergeableState GitHub.StateClean    = "clean"
    showMergeableState GitHub.StateDirty    = "dirty"
    showMergeableState GitHub.StateUnknown  = "unknown"
    showMergeableState GitHub.StateUnstable = "unstable"


getPrsForRepo
  :: Maybe GitHub.Auth
  -> Manager
  -> GitHub.Name GitHub.Owner
  -> GitHub.Name GitHub.Repo
  -> IO [PullRequestInfo]
getPrsForRepo auth mgr ownerName repoName = do
  -- Get PR list.
  simplePRs <- V.toList <$> request auth mgr (GitHub.pullRequestsForR ownerName repoName GitHub.stateOpen GitHub.FetchAll)

  prInfos <- Parallel.mapM (getPrInfo auth mgr ownerName repoName) simplePRs

  return $ map (makePullRequestInfo repoName) prInfos


getPullInfos
  :: GitHub.Name GitHub.Organization
  -> GitHub.Name GitHub.Owner
  -> Maybe GitHub.Auth
  -> IO [[PullRequestInfo]]
getPullInfos orgName ownerName auth = do
  -- Initialise HTTP manager so we can benefit from keep-alive connections.
  mgr <- newManager tlsManagerSettings

  -- Get repo list.
  repos <- V.toList <$> request auth mgr (GitHub.organizationReposR orgName GitHub.RepoPublicityAll GitHub.FetchAll)
  let repoNames = map GitHub.repoName repos

  filter (not . null) . List.sort <$> Parallel.mapM (getPrsForRepo auth mgr ownerName) repoNames


showPullInfos :: Bool -> [[PullRequestInfo]] -> IO Text
showPullInfos wantHtml infos =
  -- Pretty-print table with information.
  flip (PullRequestInfo.formatPR wantHtml) infos <$> getCurrentTime


getPullStatus
  :: GitHub.Name GitHub.Organization
  -> GitHub.Name GitHub.Owner
  -> Bool
  -> Maybe GitHub.Auth
  -> IO Text
getPullStatus orgName ownerName wantHtml auth =
  getPullInfos orgName ownerName auth >>= showPullInfos wantHtml
