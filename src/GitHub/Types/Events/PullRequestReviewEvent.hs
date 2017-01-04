{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Events.PullRequestReviewEvent where

import           Control.Applicative       ((<$>), (<*>))
import           Data.Aeson                (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types          (Value (..), (.:), (.=))
import           Data.Text                 (Text)
import           Test.QuickCheck.Arbitrary (Arbitrary (..))

import           GitHub.Types.Base
import           GitHub.Types.Event


data PullRequestReviewEvent = PullRequestReviewEvent
    { pullRequestReviewEventOrganization :: Organization
    , pullRequestReviewEventRepository   :: Repository
    , pullRequestReviewEventSender       :: User

    , pullRequestReviewEventAction       :: Text
    , pullRequestReviewEventPullRequest  :: SimplePullRequest
    , pullRequestReviewEventReview       :: Review
    } deriving (Eq, Show, Read)

instance Event PullRequestReviewEvent where
    typeName = TypeName "PullRequestReviewEvent"
    eventName = EventName "pull_request_review"

instance FromJSON PullRequestReviewEvent where
    parseJSON (Object x) = PullRequestReviewEvent
        <$> x .: "organization"
        <*> x .: "repository"
        <*> x .: "sender"

        <*> x .: "action"
        <*> x .: "pull_request"
        <*> x .: "review"

    parseJSON _ = fail "PullRequestReviewEvent"

instance ToJSON PullRequestReviewEvent where
    toJSON PullRequestReviewEvent{..} = object
        [ "organization" .= pullRequestReviewEventOrganization
        , "repository"   .= pullRequestReviewEventRepository
        , "sender"       .= pullRequestReviewEventSender

        , "action"       .= pullRequestReviewEventAction
        , "pull_request" .= pullRequestReviewEventPullRequest
        , "review"       .= pullRequestReviewEventReview
        ]


instance Arbitrary PullRequestReviewEvent where
    arbitrary = PullRequestReviewEvent
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary

        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
