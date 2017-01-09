{-# LANGUAGE LambdaCase        #-}
{-# LANGUAGE OverloadedStrings #-}
module Changelogs
  ( fetchChangeLog
  , formatChangeLog
  , ChangeLog
  ) where

import           Control.Applicative     ((<$>), (<*>))
import           Control.Arrow           (first, second, (&&&))
import           Data.List               (foldl')
import qualified Data.List               as List
import qualified Data.Map                as Map
import qualified Data.Maybe              as Maybe
import           Data.Monoid             ((<>))
import           Data.Text               (Text)
import qualified Data.Text               as Text
import qualified Data.Vector             as V
import qualified GitHub
import           Network.HTTP.Client     (newManager)
import           Network.HTTP.Client.TLS (tlsManagerSettings)
-- import           Text.Groom              (groom)

import           Requests


newtype ChangeLog = ChangeLog { unChangeLog :: [(Text, [Text], [Text])] }


formatChangeLog :: Bool -> ChangeLog -> Text
formatChangeLog wantRoadmap =
  (<> "\n") . foldl' (<>) "" . map formatMilestone . unChangeLog
  where
    issuesWord = if wantRoadmap then "Planned tasks" else "Closed issues"
    prsWord    = if wantRoadmap then "PRs to review" else "Merged PRs"

    formatMilestone (milestone, issues, pulls) =
      "\n\n## " <> milestone
      <> closedIssues issues
      <> mergedPrs pulls

    closedIssues [] = ""
    closedIssues issues =
      foldl' (<>) ("\n\n### " <> issuesWord <> ":\n") . itemise $ issues

    mergedPrs [] = ""
    mergedPrs pulls =
      foldl' (<>) ("\n\n### " <> prsWord <> ":\n") . itemise $ pulls

    itemise = map ("\n- " <>)


data ChangeLogItemKind
  = PullRequest
  | Issue
  deriving Show


data ChangeLogItem = ChangeLogItem
  { clMilestone :: Text
  , clTitle     :: Text
  , clNumber    :: Int
  }


formatChangeLogItem :: ChangeLogItemKind -> GitHub.Name GitHub.Owner -> GitHub.Name GitHub.Repo -> ChangeLogItem -> Text
formatChangeLogItem kind ownerName repoName item =
  "[#" <> number <> "](https://github.com/" <> GitHub.untagName ownerName <> "/" <> GitHub.untagName repoName <> kindPart <> number <> ") " <> clTitle item
  where
    number = Text.pack . show . clNumber $ item
    kindPart =
      case kind of
        PullRequest -> "/pull/"
        Issue       -> "/issues/"


makeChangeLog :: Bool -> GitHub.Name GitHub.Owner -> GitHub.Name GitHub.Repo -> [GitHub.SimplePullRequest] -> [GitHub.Issue] -> ChangeLog
makeChangeLog wantRoadmap ownerName repoName pulls issues =
  ChangeLog
  . sortChangelog
  . Map.foldlWithKey (\changes milestone (msIssues, msPulls) ->
      if milestone == "meta"
        then changes
        else
          ( milestone
          , map (formatChangeLogItem Issue       ownerName repoName) msIssues
          , map (formatChangeLogItem PullRequest ownerName repoName) msPulls
          ) : changes
    ) []
  . groupByMilestone (first  . (:)) changeLogIssues
  . groupByMilestone (second . (:)) changeLogPrs
  $ Map.empty
  where
    sortChangelog =
      if wantRoadmap
        then reverse
        else id

    (mergedPrs, openPrs) = List.partition (\case
        GitHub.SimplePullRequest
          { GitHub.simplePullRequestMergedAt = Just _ } -> True
        _ -> False
      ) pulls

    selectedPrs =
      if wantRoadmap
        then openPrs
        else mergedPrs

    selectedItems = filter (\case
        GitHub.Issue
          { GitHub.issueMilestone = Just GitHub.Milestone
            { GitHub.milestoneState = state }
          } ->
            if wantRoadmap
              then state == "open"
              else state == "closed"
        _ -> False
      ) issues

    milestoneByIssueId =
      Map.fromList
      . map (GitHub.issueNumber &&& GitHub.milestoneTitle . Maybe.fromJust . GitHub.issueMilestone)
      $ selectedItems

    changeLogIssues :: [ChangeLogItem]
    changeLogIssues = Maybe.mapMaybe (\case
        -- filter out PRs
        GitHub.Issue { GitHub.issuePullRequest = Just _ } -> Nothing
        issue -> Just ChangeLogItem
          { clMilestone = GitHub.milestoneTitle . Maybe.fromJust . GitHub.issueMilestone $ issue
          , clTitle     = GitHub.issueTitle issue
          , clNumber    = GitHub.issueNumber issue
          }
      ) selectedItems

    changeLogPrs :: [ChangeLogItem]
    changeLogPrs = Maybe.mapMaybe (\issue -> do
        milestone <- flip Map.lookup milestoneByIssueId . GitHub.simplePullRequestNumber $ issue
        return ChangeLogItem
          { clMilestone = milestone
          , clTitle     = GitHub.simplePullRequestTitle issue
          , clNumber    = GitHub.simplePullRequestNumber issue
          }
      ) selectedPrs

    groupByMilestone add = flip $ foldr (\item group ->
        Map.insert (clMilestone item) (
            case Map.lookup (clMilestone item) group of
              Just old -> add item old
              Nothing  -> add item ([], [])
          ) group
      )


fetchChangeLog :: Bool -> GitHub.Name GitHub.Owner -> GitHub.Name GitHub.Repo -> Maybe GitHub.Auth -> IO ChangeLog
fetchChangeLog wantRoadmap ownerName repoName auth = do
  -- Initialise HTTP manager so we can benefit from keep-alive connections.
  mgr <- newManager tlsManagerSettings

  let pulls  state = V.toList <$> request auth mgr (GitHub.pullRequestsForR ownerName repoName state GitHub.FetchAll)
  let issues state = V.toList <$> request auth mgr (GitHub.issuesForRepoR   ownerName repoName (state <> GitHub.optionsAnyMilestone) GitHub.FetchAll)

  -- issues >>= putStrLn . groom

  if wantRoadmap
    then makeChangeLog wantRoadmap ownerName repoName <$> pulls GitHub.stateOpen   <*> issues GitHub.stateOpen
    else makeChangeLog wantRoadmap ownerName repoName <$> pulls GitHub.stateClosed <*> issues GitHub.stateClosed
