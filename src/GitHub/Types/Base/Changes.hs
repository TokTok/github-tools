{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.Changes where

import           Control.Applicative       ((<$>), (<*>))
import           Data.Aeson                (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types          (Value (..), (.:?), (.=))
import           Test.QuickCheck.Arbitrary (Arbitrary (..))

import           GitHub.Types.Base.Change

------------------------------------------------------------------------------
-- Changes

data Changes = Changes
    { changesTitle :: Maybe Change
    , changesBody  :: Maybe Change
    } deriving (Eq, Show, Read)


instance FromJSON Changes where
    parseJSON (Object x) = Changes
        <$> x .:? "title"
        <*> x .:? "body"

    parseJSON _ = fail "Changes"


instance ToJSON Changes where
    toJSON Changes{..} = object
        [ "title" .= changesTitle
        , "body"  .= changesBody
        ]


instance Arbitrary Changes where
    arbitrary = Changes
        <$> arbitrary
        <*> arbitrary
