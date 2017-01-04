{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Events.ReleaseEvent where

import           Control.Applicative       ((<$>), (<*>))
import           Data.Aeson                (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types          (Value (..), (.:), (.=))
import           Data.Text                 (Text)
import           Test.QuickCheck.Arbitrary (Arbitrary (..))

import           GitHub.Types.Base
import           GitHub.Types.Event


data ReleaseEvent = ReleaseEvent
    { releaseEventOrganization :: Organization
    , releaseEventRepository   :: Repository
    , releaseEventSender       :: User

    , releaseEventAction       :: Text
    , releaseEventRelease      :: Release
    } deriving (Eq, Show, Read)

instance Event ReleaseEvent where
    typeName = TypeName "ReleaseEvent"
    eventName = EventName "release"

instance FromJSON ReleaseEvent where
    parseJSON (Object x) = ReleaseEvent
        <$> x .: "organization"
        <*> x .: "repository"
        <*> x .: "sender"

        <*> x .: "action"
        <*> x .: "release"

    parseJSON _ = fail "ForkEvent"

instance ToJSON ReleaseEvent where
    toJSON ReleaseEvent{..} = object
        [ "organization" .= releaseEventOrganization
        , "repository"   .= releaseEventRepository
        , "sender"       .= releaseEventSender

        , "action"       .= releaseEventAction
        , "release"      .= releaseEventRelease
        ]


instance Arbitrary ReleaseEvent where
    arbitrary = ReleaseEvent
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary

        <*> arbitrary
        <*> arbitrary
