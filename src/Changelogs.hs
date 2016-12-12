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


formatChangeLog :: ChangeLog -> Text
formatChangeLog = (<> "\n") . foldl' (<>) "" . map formatMilestone . unChangeLog
  where
    formatMilestone (milestone, issues, pulls) =
      "\n\n## " <> milestone
      <> closedIssues issues
      <> mergedPrs pulls

    closedIssues [] = ""
    closedIssues issues =
      foldl' (<>) "\n\n### Closed issues:\n" . itemise $ issues

    mergedPrs [] = ""
    mergedPrs pulls =
      foldl' (<>) "\n\n### Merged PRs:\n" . itemise $ pulls

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


formatChangeLogItem :: GitHub.Name GitHub.Owner -> GitHub.Name GitHub.Repo -> ChangeLogItem -> Text
formatChangeLogItem ownerName repoName item =
  "[#" <> number <> "](https://github.com/" <> GitHub.untagName ownerName <> "/" <> GitHub.untagName repoName <> "/issues/" <> number <> ") " <> clTitle item
  where
    number = Text.pack . show . clNumber $ item


makeChangeLog :: GitHub.Name GitHub.Owner -> GitHub.Name GitHub.Repo -> [GitHub.SimplePullRequest] -> [GitHub.Issue] -> ChangeLog
makeChangeLog ownerName repoName pulls issues =
  ChangeLog
  . Map.foldlWithKey (\changes milestone (msIssues, msPulls) ->
      ( milestone
      , map (formatChangeLogItem ownerName repoName) msIssues
      , map (formatChangeLogItem ownerName repoName) msPulls
      ) : changes
    ) []
  . groupByMilestone (first  . (:)) changeLogIssues
  . groupByMilestone (second . (:)) changeLogPrs
  $ Map.empty
  where
    mergedPrs = filter (\case
        GitHub.SimplePullRequest
          { GitHub.simplePullRequestMergedAt = Just _
          } -> True
        _ -> False
      ) pulls

    closedItems = filter (\case
        GitHub.Issue
          { GitHub.issueMilestone = Just GitHub.Milestone
            { GitHub.milestoneState = "closed" }
          } -> True
        _ -> False
      ) issues

    milestoneByIssueId =
      Map.fromList
      . map (GitHub.issueNumber &&& GitHub.milestoneTitle . Maybe.fromJust . GitHub.issueMilestone)
      $ closedItems

    changeLogIssues :: [ChangeLogItem]
    changeLogIssues = Maybe.mapMaybe (\case
        -- filter out PRs
        GitHub.Issue { GitHub.issuePullRequest = Just _ } -> Nothing
        issue -> Just $ ChangeLogItem
          { clMilestone = GitHub.milestoneTitle . Maybe.fromJust . GitHub.issueMilestone $ issue
          , clTitle     = GitHub.issueTitle issue
          , clNumber    = GitHub.issueNumber issue
          }
      ) closedItems

    changeLogPrs :: [ChangeLogItem]
    changeLogPrs = Maybe.mapMaybe (\issue -> do
        milestone <- flip Map.lookup milestoneByIssueId . GitHub.simplePullRequestNumber $ issue
        return $ ChangeLogItem
          { clMilestone = milestone
          , clTitle     = GitHub.simplePullRequestTitle issue
          , clNumber    = GitHub.simplePullRequestNumber issue
          }
      ) mergedPrs

    groupByMilestone add = flip $ foldr (\item group ->
        Map.insert (clMilestone item) (
            case Map.lookup (clMilestone item) group of
              Just old -> add item old
              Nothing  -> add item ([], [])
          ) group
      )


fetchChangeLog :: GitHub.Name GitHub.Owner -> GitHub.Name GitHub.Repo -> Maybe GitHub.Auth -> IO ChangeLog
fetchChangeLog ownerName repoName auth = do
  -- Initialise HTTP manager so we can benefit from keep-alive connections.
  mgr <- newManager tlsManagerSettings

  let pulls  = V.toList <$> request auth mgr (GitHub.pullRequestsForR ownerName repoName GitHub.stateClosed GitHub.FetchAll)
  let issues = V.toList <$> request auth mgr (GitHub.issuesForRepoR   ownerName repoName (GitHub.stateClosed <> GitHub.optionsAnyMilestone) GitHub.FetchAll)

  -- issues >>= putStrLn . groom

  makeChangeLog ownerName repoName <$> pulls <*> issues
