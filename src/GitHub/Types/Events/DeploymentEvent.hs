{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Events.DeploymentEvent where

import           Control.Applicative       ((<$>), (<*>))
import           Data.Aeson                (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types          (Value (..), (.:), (.=))
import           Test.QuickCheck.Arbitrary (Arbitrary (..))

import           GitHub.Types.Base
import           GitHub.Types.Event


data DeploymentEvent = DeploymentEvent
    { deploymentEventOrganization :: Organization
    , deploymentEventRepository   :: Repository
    , deploymentEventSender       :: User

    , deploymentEventDeployment   :: Deployment
    } deriving (Eq, Show, Read)

instance Event DeploymentEvent where
    typeName = TypeName "DeploymentEvent"
    eventName = EventName "deployment"

instance FromJSON DeploymentEvent where
    parseJSON (Object x) = DeploymentEvent
        <$> x .: "organization"
        <*> x .: "repository"
        <*> x .: "sender"

        <*> x .: "deployment"

    parseJSON _ = fail "DeploymentEvent"

instance ToJSON DeploymentEvent where
    toJSON DeploymentEvent{..} = object
        [ "organization" .= deploymentEventOrganization
        , "repository"   .= deploymentEventRepository
        , "sender"       .= deploymentEventSender

        , "deployment"   .= deploymentEventDeployment
        ]


instance Arbitrary DeploymentEvent where
    arbitrary = DeploymentEvent
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary

        <*> arbitrary
