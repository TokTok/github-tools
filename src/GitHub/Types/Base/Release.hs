{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.Release where

import           Control.Applicative        ((<$>), (<*>))
import           Data.Aeson                 (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types           (Value (..), (.:), (.=))
import           Data.Text                  (Text)
import           Test.QuickCheck.Arbitrary  (Arbitrary (..))

import           GitHub.Types.Base.DateTime
import           GitHub.Types.Base.User

------------------------------------------------------------------------------
-- Release

data Release = Release
    { releaseTagName         :: Text
    , releaseTarballUrl      :: Text
    , releaseBody            :: Text
    , releaseUrl             :: Text
    , releasePrerelease      :: Bool
    , releaseZipballUrl      :: Text
    , releaseName            :: Text
    , releaseAssetsUrl       :: Text
    , releaseUploadUrl       :: Text
    , releasePublishedAt     :: DateTime
    , releaseCreatedAt       :: DateTime
    , releaseTargetCommitish :: Text
    , releaseAuthor          :: User
    , releaseDraft           :: Bool
    , releaseId              :: Int
    , releaseAssets          :: [Text]
    , releaseHtmlUrl         :: Text
    } deriving (Eq, Show, Read)


instance FromJSON Release where
    parseJSON (Object x) = Release
        <$> x .: "tag_name"
        <*> x .: "tarball_url"
        <*> x .: "body"
        <*> x .: "url"
        <*> x .: "prerelease"
        <*> x .: "zipball_url"
        <*> x .: "name"
        <*> x .: "assets_url"
        <*> x .: "upload_url"
        <*> x .: "published_at"
        <*> x .: "created_at"
        <*> x .: "target_commitish"
        <*> x .: "author"
        <*> x .: "draft"
        <*> x .: "id"
        <*> x .: "assets"
        <*> x .: "html_url"

    parseJSON _ = fail "Release"


instance ToJSON Release where
    toJSON Release{..} = object
        [ "tag_name"         .= releaseTagName
        , "tarball_url"      .= releaseTarballUrl
        , "body"             .= releaseBody
        , "url"              .= releaseUrl
        , "prerelease"       .= releasePrerelease
        , "zipball_url"      .= releaseZipballUrl
        , "name"             .= releaseName
        , "assets_url"       .= releaseAssetsUrl
        , "upload_url"       .= releaseUploadUrl
        , "published_at"     .= releasePublishedAt
        , "created_at"       .= releaseCreatedAt
        , "target_commitish" .= releaseTargetCommitish
        , "author"           .= releaseAuthor
        , "draft"            .= releaseDraft
        , "id"               .= releaseId
        , "assets"           .= releaseAssets
        , "html_url"         .= releaseHtmlUrl
        ]


instance Arbitrary Release where
    arbitrary = Release
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
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
