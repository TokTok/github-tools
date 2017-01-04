{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Events.PushEvent where

import           Control.Applicative       ((<$>), (<*>))
import           Data.Aeson                (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types          (Value (..), (.:), (.:?), (.=))
import           Data.Text                 (Text)
import           Test.QuickCheck.Arbitrary (Arbitrary (..))

import           GitHub.Types.Base
import           GitHub.Types.Event


data PushEvent = PushEvent
    { pushEventOrganization    :: Organization
    , pushEventRepository      :: Repository
    , pushEventSender          :: User

    , pushEventAfter           :: Text
    , pushEventBaseRef         :: Maybe Text
    , pushEventBefore          :: Text
    , pushEventCommits         :: [PushCommit]
    , pushEventCompare         :: Text
    , pushEventCreated         :: Bool
    , pushEventDeleted         :: Bool
    , pushEventDistinctCommits :: Maybe [PushCommit]
    , pushEventForced          :: Bool
    , pushEventHeadCommit      :: Maybe PushCommit
    , pushEventPusher          :: UserRef
    , pushEventRef             :: Text
    , pushEventRefName         :: Maybe Text
    } deriving (Eq, Show, Read)

instance Event PushEvent where
    typeName = TypeName "PushEvent"
    eventName = EventName "push"

instance FromJSON PushEvent where
    parseJSON (Object x) = PushEvent
        <$> x .: "organization"
        <*> x .: "repository"
        <*> x .: "sender"

        <*> x .: "after"
        <*> x .: "base_ref"
        <*> x .: "before"
        <*> x .: "commits"
        <*> x .: "compare"
        <*> x .: "created"
        <*> x .: "deleted"
        <*> x .:? "distinct_commits"
        <*> x .: "forced"
        <*> x .: "head_commit"
        <*> x .: "pusher"
        <*> x .: "ref"
        <*> x .:? "ref_name"

    parseJSON _ = fail "PushEvent"

instance ToJSON PushEvent where
    toJSON PushEvent{..} = object
        [ "organization"     .= pushEventOrganization
        , "repository"       .= pushEventRepository
        , "sender"           .= pushEventSender

        , "after"            .= pushEventAfter
        , "base_ref"         .= pushEventBaseRef
        , "before"           .= pushEventBefore
        , "commits"          .= pushEventCommits
        , "compare"          .= pushEventCompare
        , "created"          .= pushEventCreated
        , "deleted"          .= pushEventDeleted
        , "distinct_commits" .= pushEventDistinctCommits
        , "forced"           .= pushEventForced
        , "head_commit"      .= pushEventHeadCommit
        , "pusher"           .= pushEventPusher
        , "ref"              .= pushEventRef
        , "ref_name"         .= pushEventRefName
        ]


instance Arbitrary PushEvent where
    arbitrary = PushEvent
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
