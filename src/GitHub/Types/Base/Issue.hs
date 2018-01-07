{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.Issue where

import           Control.Applicative              ((<$>), (<*>))
import           Data.Aeson                       (FromJSON (..), ToJSON (..),
                                                   object)
import           Data.Aeson.Types                 (Value (..), (.:), (.:?),
                                                   (.=))
import           Data.Text                        (Text)
import           Test.QuickCheck.Arbitrary        (Arbitrary (..))

import           GitHub.Types.Base.DateTime
import           GitHub.Types.Base.Label
import           GitHub.Types.Base.Milestone
import           GitHub.Types.Base.PullRequestRef
import           GitHub.Types.Base.User

------------------------------------------------------------------------------
-- Issue

data Issue = Issue
    { issueAssignee          :: Maybe User
    , issueAssignees         :: [User]
    , issueAuthorAssociation :: Text
    , issueBody              :: Text
    , issueClosedAt          :: Maybe DateTime
    , issueComments          :: Int
    , issueCommentsUrl       :: Text
    , issueCreatedAt         :: DateTime
    , issueEventsUrl         :: Text
    , issueHtmlUrl           :: Text
    , issueId                :: Int
    , issueLabels            :: [Label]
    , issueLabelsUrl         :: Text
    , issueLocked            :: Bool
    , issueMilestone         :: Maybe Milestone
    , issueNumber            :: Int
    , issuePullRequest       :: Maybe PullRequestRef
    , issueRepositoryUrl     :: Text
    , issueState             :: Text
    , issueTitle             :: Text
    , issueUpdatedAt         :: DateTime
    , issueUrl               :: Text
    , issueUser              :: User
    } deriving (Eq, Show, Read)


instance FromJSON Issue where
    parseJSON (Object x) = Issue
        <$> x .: "assignee"
        <*> x .: "assignees"
        <*> x .: "author_association"
        <*> x .: "body"
        <*> x .: "closed_at"
        <*> x .: "comments"
        <*> x .: "comments_url"
        <*> x .: "created_at"
        <*> x .: "events_url"
        <*> x .: "html_url"
        <*> x .: "id"
        <*> x .: "labels"
        <*> x .: "labels_url"
        <*> x .: "locked"
        <*> x .: "milestone"
        <*> x .: "number"
        <*> x .:? "pull_request"
        <*> x .: "repository_url"
        <*> x .: "state"
        <*> x .: "title"
        <*> x .: "updated_at"
        <*> x .: "url"
        <*> x .: "user"

    parseJSON _ = fail "Issue"


instance ToJSON Issue where
    toJSON Issue{..} = object
        [ "assignee"           .= issueAssignee
        , "assignees"          .= issueAssignees
        , "author_association" .= issueAuthorAssociation
        , "body"               .= issueBody
        , "closed_at"          .= issueClosedAt
        , "comments"           .= issueComments
        , "comments_url"       .= issueCommentsUrl
        , "created_at"         .= issueCreatedAt
        , "events_url"         .= issueEventsUrl
        , "html_url"           .= issueHtmlUrl
        , "id"                 .= issueId
        , "labels"             .= issueLabels
        , "labels_url"         .= issueLabelsUrl
        , "locked"             .= issueLocked
        , "milestone"          .= issueMilestone
        , "number"             .= issueNumber
        , "pull_request"       .= issuePullRequest
        , "repository_url"     .= issueRepositoryUrl
        , "state"              .= issueState
        , "title"              .= issueTitle
        , "updated_at"         .= issueUpdatedAt
        , "url"                .= issueUrl
        , "user"               .= issueUser
        ]


instance Arbitrary Issue where
    arbitrary = Issue
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
