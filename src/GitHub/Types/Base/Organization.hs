{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.Organization where

import           Control.Applicative       ((<$>), (<*>))
import           Data.Aeson                (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types          (Value (..), (.:), (.=))
import           Data.Text                 (Text)
import           Test.QuickCheck.Arbitrary (Arbitrary (..))

------------------------------------------------------------------------------
-- Organization

data Organization = Organization
    { organizationLogin            :: Text
    , organizationId               :: Int
    , organizationUrl              :: Text
    , organizationReposUrl         :: Text
    , organizationEventsUrl        :: Text
    , organizationHooksUrl         :: Text
    , organizationIssuesUrl        :: Text
    , organizationMembersUrl       :: Text
    , organizationPublicMembersUrl :: Text
    , organizationAvatarUrl        :: Text
    , organizationDescription      :: Text
    } deriving (Eq, Show, Read)


instance FromJSON Organization where
    parseJSON (Object x) = Organization
        <$> x .: "login"
        <*> x .: "id"
        <*> x .: "url"
        <*> x .: "repos_url"
        <*> x .: "events_url"
        <*> x .: "hooks_url"
        <*> x .: "issues_url"
        <*> x .: "members_url"
        <*> x .: "public_members_url"
        <*> x .: "avatar_url"
        <*> x .: "description"

    parseJSON _ = fail "Organization"


instance ToJSON Organization where
    toJSON Organization{..} = object
        [ "login"              .= organizationLogin
        , "id"                 .= organizationId
        , "url"                .= organizationUrl
        , "repos_url"          .= organizationReposUrl
        , "events_url"         .= organizationEventsUrl
        , "hooks_url"          .= organizationHooksUrl
        , "issues_url"         .= organizationIssuesUrl
        , "members_url"        .= organizationMembersUrl
        , "public_members_url" .= organizationPublicMembersUrl
        , "avatar_url"         .= organizationAvatarUrl
        , "description"        .= organizationDescription
        ]


instance Arbitrary Organization where
    arbitrary = Organization
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
