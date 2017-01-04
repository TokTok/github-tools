{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.ReviewLinks where

import           Control.Applicative       ((<$>), (<*>))
import           Data.Aeson                (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types          (Value (..), (.:), (.=))
import           Test.QuickCheck.Arbitrary (Arbitrary (..))

import           GitHub.Types.Base.Link

------------------------------------------------------------------------------
-- ReviewLinks

data ReviewLinks = ReviewLinks
    { reviewLinksHtml        :: Link
    , reviewLinksPullRequest :: Link
    } deriving (Eq, Show, Read)


instance FromJSON ReviewLinks where
    parseJSON (Object x) = ReviewLinks
        <$> x .: "html"
        <*> x .: "pull_request"

    parseJSON _ = fail "ReviewLinks"


instance ToJSON ReviewLinks where
    toJSON ReviewLinks{..} = object
        [ "html"         .= reviewLinksHtml
        , "pull_request" .= reviewLinksPullRequest
        ]


instance Arbitrary ReviewLinks where
    arbitrary = ReviewLinks
        <$> arbitrary
        <*> arbitrary
