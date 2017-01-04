{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Events.MemberEvent where

import           Control.Applicative       ((<$>), (<*>))
import           Data.Aeson                (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types          (Value (..), (.:), (.=))
import           Data.Text                 (Text)
import           Test.QuickCheck.Arbitrary (Arbitrary (..))

import           GitHub.Types.Base
import           GitHub.Types.Event


data MemberEvent = MemberEvent
    { memberEventOrganization :: Organization
    , memberEventRepository   :: Repository
    , memberEventSender       :: User

    , memberEventAction       :: Text
    } deriving (Eq, Show, Read)

instance Event MemberEvent where
    typeName = TypeName "MemberEvent"
    eventName = EventName "member"

instance FromJSON MemberEvent where
    parseJSON (Object x) = MemberEvent
        <$> x .: "organization"
        <*> x .: "repository"
        <*> x .: "sender"

        <*> x .: "action"

    parseJSON _ = fail "MemberEvent"

instance ToJSON MemberEvent where
    toJSON MemberEvent{..} = object
        [ "organization" .= memberEventOrganization
        , "repository"   .= memberEventRepository
        , "sender"       .= memberEventSender

        , "action"      .= memberEventAction
        ]


instance Arbitrary MemberEvent where
    arbitrary = MemberEvent
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary

        <*> arbitrary
