{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Events.IssueCommentEvent where

import           Control.Applicative       ((<$>), (<*>))
import           Data.Aeson                (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types          (Value (..), (.:), (.:?), (.=))
import           Data.Text                 (Text)
import           Test.QuickCheck.Arbitrary (Arbitrary (..))

import           GitHub.Types.Base
import           GitHub.Types.Event


data IssueCommentEvent = IssueCommentEvent
    { issueCommentEventOrganization :: Organization
    , issueCommentEventRepository   :: Repository
    , issueCommentEventSender       :: User

    , issueCommentEventAction       :: Text
    , issueCommentEventChanges      :: Maybe Changes
    , issueCommentEventComment      :: IssueComment
    , issueCommentEventIssue        :: Issue
    } deriving (Eq, Show, Read)

instance Event IssueCommentEvent where
    typeName = TypeName "IssueCommentEvent"
    eventName = EventName "issue_comment"

instance FromJSON IssueCommentEvent where
    parseJSON (Object x) = IssueCommentEvent
        <$> x .: "organization"
        <*> x .: "repository"
        <*> x .: "sender"

        <*> x .: "action"
        <*> x .:? "changes"
        <*> x .: "comment"
        <*> x .: "issue"

    parseJSON _ = fail "IssueCommentEvent"

instance ToJSON IssueCommentEvent where
    toJSON IssueCommentEvent{..} = object
        [ "organization" .= issueCommentEventOrganization
        , "repository"   .= issueCommentEventRepository
        , "sender"       .= issueCommentEventSender

        , "action"       .= issueCommentEventAction
        , "changes"      .= issueCommentEventChanges
        , "comment"      .= issueCommentEventComment
        , "issue"        .= issueCommentEventIssue
        ]


instance Arbitrary IssueCommentEvent where
    arbitrary = IssueCommentEvent
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary

        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
