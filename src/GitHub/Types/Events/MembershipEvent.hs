{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Events.MembershipEvent where

import           Control.Applicative       ((<$>), (<*>))
import           Data.Aeson                (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types          (Value (..), (.:), (.=))
import           Data.Text                 (Text)
import           Test.QuickCheck.Arbitrary (Arbitrary (..))

import           GitHub.Types.Base
import           GitHub.Types.Event


data MembershipEvent = MembershipEvent
    { membershipEventOrganization :: Organization
    , membershipEventSender       :: User

    , membershipEventAction       :: Text
    , membershipEventMember       :: User
    , membershipEventScope        :: Text
    , membershipEventTeam         :: Team
    } deriving (Eq, Show, Read)

instance Event MembershipEvent where
    typeName = TypeName "MembershipEvent"
    eventName = EventName "membership"

instance FromJSON MembershipEvent where
    parseJSON (Object x) = MembershipEvent
        <$> x .: "organization"
        <*> x .: "sender"

        <*> x .: "action"
        <*> x .: "member"
        <*> x .: "scope"
        <*> x .: "team"

    parseJSON _ = fail "MembershipEvent"

instance ToJSON MembershipEvent where
    toJSON MembershipEvent{..} = object
        [ "organization" .= membershipEventOrganization
        , "sender"       .= membershipEventSender

        , "action"       .= membershipEventAction
        , "member"       .= membershipEventMember
        , "scope"        .= membershipEventScope
        , "team"         .= membershipEventTeam
        ]


instance Arbitrary MembershipEvent where
    arbitrary = MembershipEvent
        <$> arbitrary
        <*> arbitrary

        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
