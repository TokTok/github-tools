{-# LANGUAGE OverloadedStrings #-}
module Main (main) where

import           Control.Monad.Catch     (throwM)
import qualified Data.ByteString         as BS
import qualified Data.ByteString.Lazy    as LBS
import qualified Data.List               as List
import qualified Data.Maybe              as Maybe
import qualified Data.Text               as Text
import qualified Data.Vector             as V
import qualified GitHub
import qualified GitHub.Data.Id          as GitHub
import           Network.HTTP.Client     (Manager, httpLbs, newManager,
                                          parseRequest, responseBody)
import           Network.HTTP.Client.TLS (tlsManagerSettings)
import           System.Environment      (getEnv, lookupEnv)
import           Text.Html               (prettyHtml, toHtml)
import           Text.HTML.TagSoup.Tree  (TagTree (..), parseTree)
import           Text.Tabular            (Header (..), Properties (..),
                                          Table (..))
import qualified Text.Tabular.AsciiArt   as AsciiArt
import qualified Text.Tabular.Html       as Html


data Approval
  = Approved
  | Rejected
  | Unknown
  deriving (Show)

data AssignedList = AssignedList
  { assignedName :: BS.ByteString 
  }

data ReviewStatus = ReviewStatus
  { reviewerName    :: BS.ByteString
  , _reviewerStatus :: Approval
  }

instance Show ReviewStatus where
  show (ReviewStatus name Approved) = '+' : read (show name)
  show (ReviewStatus name Rejected) = '-' : read (show name)
  show (ReviewStatus name Unknown)  = '?' : read (show name)

instance Show AssignedList where 
  show (AssignedList name) = read $ show name

data PullRequestInfo = PullRequestInfo
  { reviewStatus :: [ReviewStatus]
  , pullRequest  :: GitHub.PullRequest
  }

request :: GitHub.Auth -> Manager -> GitHub.Request k a -> IO a
request auth mgr req = do
  possiblePRs <- GitHub.executeRequestWithMgr mgr auth req
  case possiblePRs of
    Left  err -> throwM err
    Right res -> return res


fetchHtml :: Manager -> GitHub.SimplePullRequest -> IO BS.ByteString
fetchHtml mgr pr = do
  let url = Text.unpack $ GitHub.getUrl $ GitHub.simplePullRequestHtmlUrl pr
  putStrLn $ "fetching " ++ url
  req <- parseRequest url
  LBS.toStrict . responseBody <$> httpLbs req mgr


collectDiscussionItems :: TagTree BS.ByteString -> [(BS.ByteString, BS.ByteString)]
collectDiscussionItems = reverse . go []
  where
    go acc TagLeaf {} = acc

    go acc (TagBranch "div" [("class", cls)] (_ : TagBranch "div" _ (_ : TagBranch "a" [("href", name)] _ : _) : _))
      | BS.isInfixOf "discussion-item-review" cls = (cls, BS.tail name) : acc
    go acc (TagBranch _ _ body) =
      foldl go acc body

collectAssigned :: TagTree BS.ByteString -> [(BS.ByteString, BS.ByteString)]
collectAssigned = reverse . go []
  where
    go acc TagLeaf {} = acc

    go acc (TagBranch "span" _ (_ : TagBranch "p" _ (_ : TagBranch "a" [("class", cls)] name : _) : _))
      | BS.isInfixOf "assignee" cls = do
        putStrLn $ "assigned " ++ name 
        (cls, BS.tail name) : acc
    go acc (TagBranch _ _ body) =
      foldl go acc body

extractApprovals :: [(BS.ByteString, BS.ByteString)] -> [ReviewStatus]
extractApprovals = foldl extract []
  where
    extract acc (cls, name)
      | BS.isInfixOf "is-rejected" cls = ReviewStatus name Rejected : acc
      | BS.isInfixOf "is-approved" cls = ReviewStatus name Approved : acc
      | otherwise = acc

extractAssigned :: [(BS.ByteString, BS.ByteString)] -> [AssignedList]
extractAssigned = foldl extract []
  where
    extract acc (cls, name)
      | cls = AssignedList name : acc
      | otherwise = acc

approvalsFromHtml :: BS.ByteString -> [AssignedList]
approvalsFromHtml =
  List.nubBy (\x y -> reviewerName x == reviewerName y)
  . extractApprovals
  . collectDiscussionItems
  . TagBranch "xml" []
  . parseTree

assignedFromHmtl :: BS.ByteString -> [AssignedList]
assignedFromHmtl =
  List.nubBy (\x y -> assignedName x == assignedName y)
  . extractAssigned
  . collectAssigned
  . TagBranch "xml" []
  . parseTree

parseHtml :: BS.ByteString -> GitHub.PullRequest -> PullRequestInfo
parseHtml body pr = PullRequestInfo
  { reviewStatus = approvalsFromHtml body
  , pullRequest  = pr
  }


getFullPr :: GitHub.Auth -> Manager -> GitHub.Name GitHub.Owner -> GitHub.Name GitHub.Repo -> GitHub.SimplePullRequest -> IO GitHub.PullRequest
getFullPr auth mgr owner repo simplePr = do
  putStrLn $ "getting PR info for #" ++ show (GitHub.simplePullRequestNumber simplePr)
  request auth mgr
    . GitHub.pullRequestR owner repo
    . GitHub.Id
    . GitHub.simplePullRequestNumber
    $ simplePr


main :: IO ()
main = do
  let ownerName = "TokTok"
  let repoName = "toxcore"

  -- Get auth token from $HOME/.github-token.
  home <- getEnv "HOME"
  token <- BS.init <$> BS.readFile (home ++ "/.github-token")
  let auth = GitHub.OAuth token

  -- Check if we need to produce HTML or ASCII art.
  wantHtml <- not . null <$> lookupEnv "GITHUB_WANT_HTML"

  -- Initialise HTTP manager so we can benefit from keep-alive connections.
  mgr <- newManager tlsManagerSettings

  -- Get PR list.
  putStrLn $ "getting PR list for " ++
    Text.unpack (GitHub.untagName ownerName) ++
    "/" ++
    Text.unpack (GitHub.untagName repoName)
  simplePRs <- V.toList <$> request auth mgr (GitHub.pullRequestsForR ownerName repoName GitHub.stateOpen GitHub.FetchAll)
  fullPrs <- mapM (getFullPr auth mgr ownerName repoName) simplePRs

  -- Fetch and parse HTML pages for each PR.
  prHtmls <- mapM (fetchHtml mgr) simplePRs
  let infos = zipWith parseHtml prHtmls fullPrs

  -- Pretty-print table with information.
  putStrLn $ formatPR wantHtml infos


formatPR :: Bool -> [PullRequestInfo] -> String
formatPR False = AsciiArt.render id id id . prToTable
formatPR True  = prettyHtml . Html.render toHtml toHtml toHtml . prToTable


prToTable :: [PullRequestInfo] -> Table String String String
prToTable prs = Table rowNames columnNames rows
  where
    rowNames = Group NoLine $ map (Header . show . GitHub.pullRequestNumber . pullRequest) prs

    columnNames =  Group SingleLine
      [ Header "branch"
      , Header "title"
      , Header "mergeable"
      , Header "mergeable_state"
      , Header "review_status"
      , Header "assigned"
      ]

    rows = map (\pr ->
      [ getPrBranch $ pullRequest pr
      , getPrTitle $ pullRequest pr
      , getPrMergeable $ pullRequest pr
      , getPrMergeableState $ pullRequest pr
      , show $ reviewStatus pr
      , show $ assignedList pr
      ]) prs

    getPrTitle = Text.unpack . GitHub.pullRequestTitle
    getPrMergeable = show . Maybe.fromMaybe False . GitHub.pullRequestMergeable
    getPrMergeableState = show . GitHub.pullRequestMergeableState

    getPrBranch =
      Text.unpack
        . GitHub.pullRequestCommitLabel
        . GitHub.pullRequestHead
