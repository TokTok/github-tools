{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.CommitRef where

import           Control.Applicative       ((<$>), (<*>))
import           Data.Aeson                (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types          (Value (..), (.:), (.=))
import           Data.Text                 (Text)
import           Test.QuickCheck.Arbitrary (Arbitrary (..))

------------------------------------------------------------------------------
-- CommitRef

data CommitRef = CommitRef
    { commitRefSha :: Text
    , commitRefUrl :: Text
    } deriving (Eq, Show, Read)


instance FromJSON CommitRef where
    parseJSON (Object x) = CommitRef
        <$> x .: "sha"
        <*> x .: "url"

    parseJSON _ = fail "CommitRef"


instance ToJSON CommitRef where
    toJSON CommitRef{..} = object
        [ "sha" .= commitRefSha
        , "url" .= commitRefUrl
        ]


instance Arbitrary CommitRef where
    arbitrary = CommitRef
        <$> arbitrary
        <*> arbitrary
