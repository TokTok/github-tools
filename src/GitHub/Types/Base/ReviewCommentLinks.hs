{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.ReviewCommentLinks where

import           Control.Applicative       ((<$>), (<*>))
import           Data.Aeson                (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types          (Value (..), (.:), (.=))
import           Test.QuickCheck.Arbitrary (Arbitrary (..))

import           GitHub.Types.Base.Link

------------------------------------------------------------------------------
-- ReviewCommentLinks

data ReviewCommentLinks = ReviewCommentLinks
    { reviewCommentLinksHtml        :: Link
    , reviewCommentLinksSelf        :: Link
    , reviewCommentLinksPullRequest :: Link
    } deriving (Eq, Show, Read)


instance FromJSON ReviewCommentLinks where
    parseJSON (Object x) = ReviewCommentLinks
        <$> x .: "html"
        <*> x .: "self"
        <*> x .: "pull_request"

    parseJSON _ = fail "ReviewCommentLinks"


instance ToJSON ReviewCommentLinks where
    toJSON ReviewCommentLinks{..} = object
        [ "html"         .= reviewCommentLinksHtml
        , "self"         .= reviewCommentLinksSelf
        , "pull_request" .= reviewCommentLinksPullRequest
        ]


instance Arbitrary ReviewCommentLinks where
    arbitrary = ReviewCommentLinks
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary
