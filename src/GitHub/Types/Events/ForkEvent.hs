{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Events.ForkEvent where

import           Control.Applicative       ((<$>), (<*>))
import           Data.Aeson                (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types          (Value (..), (.:), (.=))
import           Test.QuickCheck.Arbitrary (Arbitrary (..))

import           GitHub.Types.Base
import           GitHub.Types.Event


data ForkEvent = ForkEvent
    { forkEventOrganization :: Organization
    , forkEventRepository   :: Repository
    , forkEventSender       :: User

    , forkEventForkee       :: Repository
    } deriving (Eq, Show, Read)

instance Event ForkEvent where
    typeName = TypeName "ForkEvent"
    eventName = EventName "fork"

instance FromJSON ForkEvent where
    parseJSON (Object x) = ForkEvent
        <$> x .: "organization"
        <*> x .: "repository"
        <*> x .: "sender"

        <*> x .: "forkee"

    parseJSON _ = fail "ForkEvent"

instance ToJSON ForkEvent where
    toJSON ForkEvent{..} = object
        [ "organization" .= forkEventOrganization
        , "repository"   .= forkEventRepository
        , "sender"       .= forkEventSender

        , "forkee"       .= forkEventForkee
        ]


instance Arbitrary ForkEvent where
    arbitrary = ForkEvent
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary

        <*> arbitrary
