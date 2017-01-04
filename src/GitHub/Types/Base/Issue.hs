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
    { issueState         :: Text
    , issueAssignees     :: [User]
    , issueLocked        :: Bool
    , issueBody          :: Text
    , issueUrl           :: Text
    , issuePullRequest   :: Maybe PullRequestRef
    , issueMilestone     :: Maybe Milestone
    , issueAssignee      :: Maybe User
    , issueUser          :: User
    , issueCommentsUrl   :: Text
    , issueUpdatedAt     :: DateTime
    , issueCreatedAt     :: DateTime
    , issueId            :: Int
    , issueLabels        :: [Label]
    , issueComments      :: Int
    , issueTitle         :: Text
    , issueClosedAt      :: Maybe DateTime
    , issueNumber        :: Int
    , issueEventsUrl     :: Text
    , issueRepositoryUrl :: Text
    , issueLabelsUrl     :: Text
    , issueHtmlUrl       :: Text
    } deriving (Eq, Show, Read)


instance FromJSON Issue where
    parseJSON (Object x) = Issue
        <$> x .: "state"
        <*> x .: "assignees"
        <*> x .: "locked"
        <*> x .: "body"
        <*> x .: "url"
        <*> x .:? "pull_request"
        <*> x .: "milestone"
        <*> x .: "assignee"
        <*> x .: "user"
        <*> x .: "comments_url"
        <*> x .: "updated_at"
        <*> x .: "created_at"
        <*> x .: "id"
        <*> x .: "labels"
        <*> x .: "comments"
        <*> x .: "title"
        <*> x .: "closed_at"
        <*> x .: "number"
        <*> x .: "events_url"
        <*> x .: "repository_url"
        <*> x .: "labels_url"
        <*> x .: "html_url"

    parseJSON _ = fail "Issue"


instance ToJSON Issue where
    toJSON Issue{..} = object
        [ "state"          .= issueState
        , "assignees"      .= issueAssignees
        , "locked"         .= issueLocked
        , "body"           .= issueBody
        , "url"            .= issueUrl
        , "pull_request"   .= issuePullRequest
        , "milestone"      .= issueMilestone
        , "assignee"       .= issueAssignee
        , "user"           .= issueUser
        , "comments_url"   .= issueCommentsUrl
        , "updated_at"     .= issueUpdatedAt
        , "created_at"     .= issueCreatedAt
        , "id"             .= issueId
        , "labels"         .= issueLabels
        , "comments"       .= issueComments
        , "title"          .= issueTitle
        , "closed_at"      .= issueClosedAt
        , "number"         .= issueNumber
        , "events_url"     .= issueEventsUrl
        , "repository_url" .= issueRepositoryUrl
        , "labels_url"     .= issueLabelsUrl
        , "html_url"       .= issueHtmlUrl
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
