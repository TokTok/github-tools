{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Events.CreateEvent where

import           Control.Applicative       ((<$>), (<*>))
import           Data.Aeson                (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types          (Value (..), (.:), (.=))
import           Data.Text                 (Text)
import           Test.QuickCheck.Arbitrary (Arbitrary (..))

import           GitHub.Types.Base
import           GitHub.Types.Event


data CreateEvent = CreateEvent
    { createEventOrganization :: Organization
    , createEventRepository   :: Repository
    , createEventSender       :: User

    , createEventDescription  :: Text
    , createEventMasterBranch :: Text
    , createEventPusherType   :: Text
    , createEventRef          :: Text
    , createEventRefType      :: Text
    } deriving (Eq, Show, Read)

instance Event CreateEvent where
    typeName = TypeName "CreateEvent"
    eventName = EventName "create"

instance FromJSON CreateEvent where
    parseJSON (Object x) = CreateEvent
        <$> x .: "organization"
        <*> x .: "repository"
        <*> x .: "sender"

        <*> x .: "description"
        <*> x .: "master_branch"
        <*> x .: "pusher_type"
        <*> x .: "ref"
        <*> x .: "ref_type"

    parseJSON _ = fail "CreateEvent"

instance ToJSON CreateEvent where
    toJSON CreateEvent{..} = object
        [ "organization"  .= createEventOrganization
        , "repository"    .= createEventRepository
        , "sender"        .= createEventSender

        , "description"   .= createEventDescription
        , "master_branch" .= createEventMasterBranch
        , "pusher_type"   .= createEventPusherType
        , "ref"           .= createEventRef
        , "ref_type"      .= createEventRefType
        ]


instance Arbitrary CreateEvent where
    arbitrary = CreateEvent
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary

        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
