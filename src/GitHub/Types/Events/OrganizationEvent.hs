{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Events.OrganizationEvent where

import           Control.Applicative       ((<$>), (<*>))
import           Data.Aeson                (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types          (Value (..), (.:), (.:?), (.=))
import           Data.Text                 (Text)
import           Test.QuickCheck.Arbitrary (Arbitrary (..))

import           GitHub.Types.Base
import           GitHub.Types.Event


data OrganizationEvent = OrganizationEvent
    { organizationEventOrganization :: Organization
    , organizationEventSender       :: User

    , organizationEventAction       :: Text
    , organizationEventInvitation   :: Maybe Invitation
    , organizationEventMembership   :: Maybe Membership
    , organizationEventUser         :: Maybe User
    } deriving (Eq, Show, Read)

instance Event OrganizationEvent where
    typeName = TypeName "OrganizationEvent"
    eventName = EventName "organization"

instance FromJSON OrganizationEvent where
    parseJSON (Object x) = OrganizationEvent
        <$> x .: "organization"
        <*> x .: "sender"

        <*> x .: "action"
        <*> x .:? "invitation"
        <*> x .:? "membership"
        <*> x .:? "user"

    parseJSON _ = fail "OrganizationEvent"

instance ToJSON OrganizationEvent where
    toJSON OrganizationEvent{..} = object
        [ "organization" .= organizationEventOrganization
        , "sender"       .= organizationEventSender

        , "action"       .= organizationEventAction
        , "invitation"   .= organizationEventInvitation
        , "membership"   .= organizationEventMembership
        , "user"         .= organizationEventUser
        ]


instance Arbitrary OrganizationEvent where
    arbitrary = OrganizationEvent
        <$> arbitrary
        <*> arbitrary

        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
