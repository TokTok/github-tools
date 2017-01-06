{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}
module PullRequestInfo where

import           Control.Monad         (join)
import           Data.Aeson            (FromJSON, ToJSON)
import qualified Data.List             as List
import           Data.Monoid           ((<>))
import           Data.Text             (Text)
import qualified Data.Text             as Text
import           Data.Time.Clock       (UTCTime, diffUTCTime)
import           GHC.Generics          (Generic)
import           Text.Html             (prettyHtml, toHtml)
import           Text.Tabular          (Header (..), Properties (..),
                                        Table (..))
import qualified Text.Tabular.AsciiArt as AsciiArt
import qualified Text.Tabular.Html     as Html


data PullRequestInfo = PullRequestInfo
  { prRepoName  :: Text
    -- ^ The repository for which the pull request is.
  , prNumber    :: Int
    -- ^ The assigned pull request issue number.
  , prUser      :: Text
    -- ^ The user who proposed this PR.
  , prBranch    :: Text
    -- ^ The branch name from which the pull request came.
  , prCreated   :: UTCTime
    -- ^ Creation time of pull request. I.e. when it was proposed.
  , prTitle     :: Text
    -- ^ Title of pull request.
  , prReviewers :: [Text]
    -- ^ The list of pull request reviewers (assignees).
  , prState     :: Text
  }
  deriving (Ord, Eq, Generic)

instance ToJSON PullRequestInfo
instance FromJSON PullRequestInfo


formatPR :: Bool -> UTCTime -> [[PullRequestInfo]] -> Text
formatPR False now = Text.pack . AsciiArt.render Text.unpack Text.unpack Text.unpack . prToTable now
formatPR True  now = Text.pack . prettyHtml . Html.render textHtml textHtml textHtml . prToTable now
  where textHtml = toHtml . Text.unpack


prToTable :: UTCTime -> [[PullRequestInfo]] -> Table Text Text Text
prToTable now prss = Table rowNames columnNames rows
  where
    rowNames = Group SingleLine
      . map (Group NoLine . map (Header . getRowName))
      . filter (not . null)
      $ prss

    getRowName pr =
      let repo num = prRepoName pr <> " " <> num in
      repo . Text.pack . show . prNumber $ pr

    columnNames =  Group SingleLine
      [ Header "branch"
      , Header "age"
      , Header "title"
      , Header "state"
      , Header "review_status"
      ]

    rows = map (flip map
      [ (\pr -> prUser pr <> "/" <> prBranch pr)
      , Text.pack . (++ "d") . show . diffInDays now . prCreated
      , prTitle
      , prState
      , Text.pack . List.intercalate "," . map Text.unpack . prReviewers
      ] . flip ($)) $ join prss


diffInDays :: UTCTime -> UTCTime -> Int
diffInDays a b = round $ diffUTCTime a b / (60 * 60 * 24)
