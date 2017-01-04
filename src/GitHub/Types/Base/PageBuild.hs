{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.PageBuild where

import           Control.Applicative              ((<$>), (<*>))
import           Data.Aeson                       (FromJSON (..), ToJSON (..),
                                                   object)
import           Data.Aeson.Types                 (Value (..), (.:), (.=))
import           Data.Text                        (Text)
import           Test.QuickCheck.Arbitrary        (Arbitrary (..))

import           GitHub.Types.Base.DateTime
import           GitHub.Types.Base.PageBuildError
import           GitHub.Types.Base.User

------------------------------------------------------------------------------
-- PageBuild

data PageBuild = PageBuild
    { pageBuildCommit    :: Text
    , pageBuildCreatedAt :: DateTime
    , pageBuildDuration  :: Int
    , pageBuildError     :: PageBuildError
    , pageBuildPusher    :: User
    , pageBuildStatus    :: Text
    , pageBuildUpdatedAt :: DateTime
    , pageBuildUrl       :: Text
    } deriving (Eq, Show, Read)


instance FromJSON PageBuild where
    parseJSON (Object x) = PageBuild
        <$> x .: "commit"
        <*> x .: "created_at"
        <*> x .: "duration"
        <*> x .: "error"
        <*> x .: "pusher"
        <*> x .: "status"
        <*> x .: "updated_at"
        <*> x .: "url"

    parseJSON _ = fail "PageBuild"


instance ToJSON PageBuild where
    toJSON PageBuild{..} = object
        [ "commit"     .= pageBuildCommit
        , "created_at" .= pageBuildCreatedAt
        , "duration"   .= pageBuildDuration
        , "error"      .= pageBuildError
        , "pusher"     .= pageBuildPusher
        , "status"     .= pageBuildStatus
        , "updated_at" .= pageBuildUpdatedAt
        , "url"        .= pageBuildUrl
        ]


instance Arbitrary PageBuild where
    arbitrary = PageBuild
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
