{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.UserStamp where

import           Control.Applicative       ((<$>), (<*>))
import           Data.Aeson                (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types          (Value (..), (.:), (.=))
import           Data.Text                 (Text)
import           Data.Text.Arbitrary       ()
import           Test.QuickCheck.Arbitrary (Arbitrary (..))

------------------------------------------------------------------------------
-- UserStamp

data UserStamp = UserStamp
    { userStampName  :: Text
    , userStampEmail :: Text
    , userStampDate  :: Text
    } deriving (Eq, Show, Read)


instance FromJSON UserStamp where
    parseJSON (Object x) = UserStamp
        <$> x .: "name"
        <*> x .: "email"
        <*> x .: "date"

    parseJSON _ = fail "UserStamp"


instance ToJSON UserStamp where
    toJSON UserStamp{..} = object
        [ "name"  .= userStampName
        , "email" .= userStampEmail
        , "date"  .= userStampDate
        ]


instance Arbitrary UserStamp where
    arbitrary = UserStamp
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary
