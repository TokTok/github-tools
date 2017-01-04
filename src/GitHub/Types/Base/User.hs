{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.User where

import           Control.Applicative       ((<$>), (<*>))
import           Data.Aeson                (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types          (Value (..), (.:), (.=))
import           Data.Text                 (Text)
import           Test.QuickCheck.Arbitrary (Arbitrary (..))

------------------------------------------------------------------------------
-- User

data User = User
    { userLogin             :: Text
    , userId                :: Int
    , userAvatarUrl         :: Text
    , userGravatarId        :: Text
    , userUrl               :: Text
    , userHtmlUrl           :: Text
    , userFollowersUrl      :: Text
    , userFollowingUrl      :: Text
    , userGistsUrl          :: Text
    , userStarredUrl        :: Text
    , userSubscriptionsUrl  :: Text
    , userOrganizationsUrl  :: Text
    , userReposUrl          :: Text
    , userEventsUrl         :: Text
    , userReceivedEventsUrl :: Text
    , userType              :: Text
    , userSiteAdmin         :: Bool
    } deriving (Eq, Show, Read)


instance FromJSON User where
    parseJSON (Object x) = User
        <$> x .: "login"
        <*> x .: "id"
        <*> x .: "avatar_url"
        <*> x .: "gravatar_id"
        <*> x .: "url"
        <*> x .: "html_url"
        <*> x .: "followers_url"
        <*> x .: "following_url"
        <*> x .: "gists_url"
        <*> x .: "starred_url"
        <*> x .: "subscriptions_url"
        <*> x .: "organizations_url"
        <*> x .: "repos_url"
        <*> x .: "events_url"
        <*> x .: "received_events_url"
        <*> x .: "type"
        <*> x .: "site_admin"

    parseJSON _ = fail "User"


instance ToJSON User where
    toJSON User{..} = object
        [ "login"               .= userLogin
        , "id"                  .= userId
        , "avatar_url"          .= userAvatarUrl
        , "gravatar_id"         .= userGravatarId
        , "url"                 .= userUrl
        , "html_url"            .= userHtmlUrl
        , "followers_url"       .= userFollowersUrl
        , "following_url"       .= userFollowingUrl
        , "gists_url"           .= userGistsUrl
        , "starred_url"         .= userStarredUrl
        , "subscriptions_url"   .= userSubscriptionsUrl
        , "organizations_url"   .= userOrganizationsUrl
        , "repos_url"           .= userReposUrl
        , "events_url"          .= userEventsUrl
        , "received_events_url" .= userReceivedEventsUrl
        , "type"                .= userType
        , "site_admin"          .= userSiteAdmin
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
