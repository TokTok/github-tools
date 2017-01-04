{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.Team where

import           Control.Applicative       ((<$>), (<*>))
import           Data.Aeson                (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types          (Value (..), (.:), (.=))
import           Data.Text                 (Text)
import           Test.QuickCheck.Arbitrary (Arbitrary (..))

------------------------------------------------------------------------------
-- Team

data Team = Team
    { teamDescription     :: Text
    , teamId              :: Int
    , teamMembersUrl      :: Text
    , teamName            :: Text
    , teamPermission      :: Text
    , teamPrivacy         :: Text
    , teamRepositoriesUrl :: Text
    , teamSlug            :: Text
    , teamUrl             :: Text
    } deriving (Eq, Show, Read)


instance FromJSON Team where
    parseJSON (Object x) = Team
        <$> x .: "description"
        <*> x .: "id"
        <*> x .: "members_url"
        <*> x .: "name"
        <*> x .: "permission"
        <*> x .: "privacy"
        <*> x .: "repositories_url"
        <*> x .: "slug"
        <*> x .: "url"

    parseJSON _ = fail "Team"


instance ToJSON Team where
    toJSON Team{..} = object
        [ "description"      .= teamDescription
        , "id"               .= teamId
        , "members_url"      .= teamMembersUrl
        , "name"             .= teamName
        , "permission"       .= teamPermission
        , "privacy"          .= teamPrivacy
        , "repositories_url" .= teamRepositoriesUrl
        , "slug"             .= teamSlug
        , "url"              .= teamUrl
        ]


instance Arbitrary Team where
    arbitrary = Team
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
