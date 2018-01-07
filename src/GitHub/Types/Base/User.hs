{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.User where

import           Control.Applicative       ((<$>), (<*>))
import           Data.Aeson                (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types          (Value (..), (.:), (.:?), (.=))
import           Data.Text                 (Text)
import           Data.Text.Arbitrary       ()
import           Test.QuickCheck.Arbitrary (Arbitrary (..))

------------------------------------------------------------------------------
-- User

data User = User
    { userAvatarUrl         :: Text
    , userEmail             :: Maybe Text
    , userEventsUrl         :: Text
    , userFollowersUrl      :: Text
    , userFollowingUrl      :: Text
    , userGistsUrl          :: Text
    , userGravatarId        :: Text
    , userHtmlUrl           :: Text
    , userId                :: Int
    , userLogin             :: Text
    , userName              :: Maybe Text
    , userOrganizationsUrl  :: Text
    , userReceivedEventsUrl :: Text
    , userReposUrl          :: Text
    , userSiteAdmin         :: Bool
    , userStarredUrl        :: Text
    , userSubscriptionsUrl  :: Text
    , userType              :: Text
    , userUrl               :: Text
    } deriving (Eq, Show, Read)


instance FromJSON User where
    parseJSON (Object x) = User
        <$> x .: "avatar_url"
        <*> x .:? "email"
        <*> x .: "events_url"
        <*> x .: "followers_url"
        <*> x .: "following_url"
        <*> x .: "gists_url"
        <*> x .: "gravatar_id"
        <*> x .: "html_url"
        <*> x .: "id"
        <*> x .: "login"
        <*> x .:? "name"
        <*> x .: "organizations_url"
        <*> x .: "received_events_url"
        <*> x .: "repos_url"
        <*> x .: "site_admin"
        <*> x .: "starred_url"
        <*> x .: "subscriptions_url"
        <*> x .: "type"
        <*> x .: "url"

    parseJSON _ = fail "User"


instance ToJSON User where
    toJSON User{..} = object
        [ "avatar_url"          .= userAvatarUrl
        , "email"               .= userEmail
        , "events_url"          .= userEventsUrl
        , "followers_url"       .= userFollowersUrl
        , "following_url"       .= userFollowingUrl
        , "gists_url"           .= userGistsUrl
        , "gravatar_id"         .= userGravatarId
        , "html_url"            .= userHtmlUrl
        , "id"                  .= userId
        , "login"               .= userLogin
        , "name"                .= userName
        , "organizations_url"   .= userOrganizationsUrl
        , "received_events_url" .= userReceivedEventsUrl
        , "repos_url"           .= userReposUrl
        , "site_admin"          .= userSiteAdmin
        , "starred_url"         .= userStarredUrl
        , "subscriptions_url"   .= userSubscriptionsUrl
        , "type"                .= userType
        , "url"                 .= userUrl
        ]


instance Arbitrary User where
    arbitrary = User
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
        <*> arbitrary
        <*> arbitrary
