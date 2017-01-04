{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.Membership where

import           Control.Applicative       ((<$>), (<*>))
import           Data.Aeson                (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types          (Value (..), (.:), (.=))
import           Data.Text                 (Text)
import           Test.QuickCheck.Arbitrary (Arbitrary (..))

import           GitHub.Types.Base.User

------------------------------------------------------------------------------
-- Membership

data Membership = Membership
    { membershipOrganizationUrl :: Text
    , membershipRole            :: Text
    , membershipState           :: Text
    , membershipUrl             :: Text
    , membershipUser            :: User
    } deriving (Eq, Show, Read)


instance FromJSON Membership where
    parseJSON (Object x) = Membership
        <$> x .: "organization_url"
        <*> x .: "role"
        <*> x .: "state"
        <*> x .: "url"
        <*> x .: "user"

    parseJSON _ = fail "Membership"


instance ToJSON Membership where
    toJSON Membership{..} = object
        [ "organization_url" .= membershipOrganizationUrl
        , "role"             .= membershipRole
        , "state"            .= membershipState
        , "url"              .= membershipUrl
        , "user"             .= membershipUser
        ]


instance Arbitrary Membership where
    arbitrary = Membership
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
