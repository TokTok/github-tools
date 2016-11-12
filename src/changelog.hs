{-# LANGUAGE LambdaCase        #-}
{-# LANGUAGE OverloadedStrings #-}
module Main (main) where

import qualified Data.ByteString.Char8   as BS8
import qualified Data.Map                as Map
import qualified Data.Maybe              as Maybe
import           Data.Monoid             ((<>))
import qualified Data.Text               as Text
import qualified Data.Vector             as V
import qualified GitHub
import           Network.HTTP.Client     (newManager)
import           Network.HTTP.Client.TLS (tlsManagerSettings)
import           System.Environment      (getEnv)
import           Text.Groom              (groom)

import           Requests


type ChangeLog = [(String, [String])]


formatChangeLog :: ChangeLog -> String
formatChangeLog = groom


formatIssue :: GitHub.Issue -> String
formatIssue issue =
  "#" ++ show (GitHub.issueNumber issue) ++ " " ++ Text.unpack (GitHub.issueTitle issue)


makeChangeLog :: [GitHub.Issue] -> String
makeChangeLog issues = formatChangeLog changeLog
  where
    relevantIssues = filter (\case
        GitHub.Issue
          { GitHub.issueMilestone = Just GitHub.Milestone
            { GitHub.milestoneState = "closed" }
          } -> True
        _ -> False
      ) issues

    issuesByMilestone = foldl (\byMilestone issue ->
        let
          milestone = GitHub.milestoneTitle . Maybe.fromJust . GitHub.issueMilestone $ issue
          msIssues =
            case Map.lookup milestone byMilestone of
              Just old -> issue : old
              Nothing  -> [issue]
        in
        Map.insert milestone msIssues byMilestone
      ) Map.empty relevantIssues

    changeLog = Map.foldlWithKey (\changes milestone msIssues ->
        (Text.unpack milestone, map formatIssue msIssues) : changes
      ) [] issuesByMilestone


main :: IO ()
main = do
  let ownerName = "TokTok"
  let repoName = "c-toxcore"

  -- Get auth token from the $GITHUB_TOKEN environment variable.
  token <- BS8.pack <$> getEnv "GITHUB_TOKEN"
  let auth = GitHub.OAuth token

  -- Initialise HTTP manager so we can benefit from keep-alive connections.
  mgr <- newManager tlsManagerSettings

  issues <- V.toList <$> request auth mgr (GitHub.issuesForRepoR ownerName repoName (GitHub.stateClosed <> GitHub.optionsAnyMilestone) GitHub.FetchAll)

  putStrLn $ makeChangeLog issues

  return ()
