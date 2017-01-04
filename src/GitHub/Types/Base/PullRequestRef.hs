{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.PullRequestRef where

import           Control.Applicative       ((<$>), (<*>))
import           Data.Aeson                (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types          (Value (..), (.:), (.=))
import           Data.Text                 (Text)
import           Test.QuickCheck.Arbitrary (Arbitrary (..))

------------------------------------------------------------------------------
-- PullRequestRef

data PullRequestRef = PullRequestRef
    { pullRequestRefUrl      :: Text
    , pullRequestRefDiffUrl  :: Text
    , pullRequestRefPatchUrl :: Text
    , pullRequestRefHtmlUrl  :: Text
    } deriving (Eq, Show, Read)


instance FromJSON PullRequestRef where
    parseJSON (Object x) = PullRequestRef
        <$> x .: "url"
        <*> x .: "diff_url"
        <*> x .: "patch_url"
        <*> x .: "html_url"

    parseJSON _ = fail "PullRequestRef"


instance ToJSON PullRequestRef where
    toJSON PullRequestRef{..} = object
        [ "url"       .= pullRequestRefUrl
        , "diff_url"  .= pullRequestRefDiffUrl
        , "patch_url" .= pullRequestRefPatchUrl
        , "html_url"  .= pullRequestRefHtmlUrl
        ]


instance Arbitrary PullRequestRef where
    arbitrary = PullRequestRef
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
