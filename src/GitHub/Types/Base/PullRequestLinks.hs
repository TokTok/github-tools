{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.PullRequestLinks where

import           Control.Applicative       ((<$>), (<*>))
import           Data.Aeson                (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types          (Value (..), (.:), (.=))
import           Test.QuickCheck.Arbitrary (Arbitrary (..))

import           GitHub.Types.Base.Link

------------------------------------------------------------------------------
-- PullRequestLinks

data PullRequestLinks = PullRequestLinks
    { pullRequestLinksSelf           :: Link
    , pullRequestLinksCommits        :: Link
    , pullRequestLinksStatuses       :: Link
    , pullRequestLinksReviewComments :: Link
    , pullRequestLinksHtml           :: Link
    , pullRequestLinksComments       :: Link
    , pullRequestLinksReviewComment  :: Link
    , pullRequestLinksIssue          :: Link
    } deriving (Eq, Show, Read)


instance FromJSON PullRequestLinks where
    parseJSON (Object x) = PullRequestLinks
        <$> x .: "self"
        <*> x .: "commits"
        <*> x .: "statuses"
        <*> x .: "review_comments"
        <*> x .: "html"
        <*> x .: "comments"
        <*> x .: "review_comment"
        <*> x .: "issue"

    parseJSON _ = fail "PullRequestLinks"


instance ToJSON PullRequestLinks where
    toJSON PullRequestLinks{..} = object
        [ "self"            .= pullRequestLinksSelf
        , "commits"         .= pullRequestLinksCommits
        , "statuses"        .= pullRequestLinksStatuses
        , "review_comments" .= pullRequestLinksReviewComments
        , "html"            .= pullRequestLinksHtml
        , "comments"        .= pullRequestLinksComments
        , "review_comment"  .= pullRequestLinksReviewComment
        , "issue"           .= pullRequestLinksIssue
        ]


instance Arbitrary PullRequestLinks where
    arbitrary = PullRequestLinks
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
