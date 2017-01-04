{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.Deployment where

import           Control.Applicative        ((<$>), (<*>))
import           Data.Aeson                 (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types           (Value (..), (.:), (.=))
import           Data.Text                  (Text)
import           Test.QuickCheck.Arbitrary  (Arbitrary (..))

import           GitHub.Types.Base.DateTime
import           GitHub.Types.Base.User

-- We don't know what the payload type is, yet. Other libraries put "Value"
-- there, also not knowing what is in it. The documentation is incorrect:
-- https://developer.github.com/v3/activity/events/types/#deploymentevent says
-- it's a string, but the example shows it's an empty object. Until we know
-- what this really is, we'll just assume it's an empty object.
data EmptyObject = EmptyObject
   deriving (Eq, Show, Read)

instance FromJSON EmptyObject where
    parseJSON (Object _) = return EmptyObject
    parseJSON _ = fail "Deployment"

instance ToJSON EmptyObject where
    toJSON EmptyObject = object []

instance Arbitrary EmptyObject where
    arbitrary = return EmptyObject

------------------------------------------------------------------------------
-- Deployment

data Deployment = Deployment
    { deploymentUrl           :: Text
    , deploymentId            :: Int
    , deploymentSha           :: Text
    , deploymentRef           :: Text
    , deploymentTask          :: Text
    , deploymentPayload       :: EmptyObject
    , deploymentEnvironment   :: Text
    , deploymentDescription   :: Maybe Text
    , deploymentCreator       :: User
    , deploymentCreatedAt     :: DateTime
    , deploymentUpdatedAt     :: DateTime
    , deploymentStatusesUrl   :: Text
    , deploymentRepositoryUrl :: Text
    } deriving (Eq, Show, Read)

instance FromJSON Deployment where
    parseJSON (Object x) = Deployment
        <$> x .: "url"
        <*> x .: "id"
        <*> x .: "sha"
        <*> x .: "ref"
        <*> x .: "task"
        <*> x .: "payload"
        <*> x .: "environment"
        <*> x .: "description"
        <*> x .: "creator"
        <*> x .: "created_at"
        <*> x .: "updated_at"
        <*> x .: "statuses_url"
        <*> x .: "repository_url"

    parseJSON _ = fail "Deployment"

instance ToJSON Deployment where
    toJSON Deployment{..} = object
        [ "url"            .= deploymentUrl
        , "id"             .= deploymentId
        , "sha"            .= deploymentSha
        , "ref"            .= deploymentRef
        , "task"           .= deploymentTask
        , "payload"        .= deploymentPayload
        , "environment"    .= deploymentEnvironment
        , "description"    .= deploymentDescription
        , "creator"        .= deploymentCreator
        , "created_at"     .= deploymentCreatedAt
        , "updated_at"     .= deploymentUpdatedAt
        , "statuses_url"   .= deploymentStatusesUrl
        , "repository_url" .= deploymentRepositoryUrl
        ]


instance Arbitrary Deployment where
    arbitrary = Deployment
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
