{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.CommitRefHtml where

import           Control.Applicative       ((<$>), (<*>))
import           Data.Aeson                (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types          (Value (..), (.:), (.=))
import           Data.Text                 (Text)
import           Test.QuickCheck.Arbitrary (Arbitrary (..))

------------------------------------------------------------------------------
-- CommitRefHtml

data CommitRefHtml = CommitRefHtml
    { commitRefHtmlSha     :: Text
    , commitRefHtmlUrl     :: Text
    , commitRefHtmlHtmlUrl :: Text
    } deriving (Eq, Show, Read)


instance FromJSON CommitRefHtml where
    parseJSON (Object x) = CommitRefHtml
        <$> x .: "sha"
        <*> x .: "url"
        <*> x .: "html_url"

    parseJSON _ = fail "CommitRefHtml"


instance ToJSON CommitRefHtml where
    toJSON CommitRefHtml{..} = object
        [ "sha"      .= commitRefHtmlSha
        , "url"      .= commitRefHtmlUrl
        , "html_url" .= commitRefHtmlHtmlUrl
        ]


instance Arbitrary CommitRefHtml where
    arbitrary = CommitRefHtml
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary
