{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.Hook where

import           Control.Applicative          ((<$>), (<*>))
import           Data.Aeson                   (FromJSON (..), ToJSON (..),
                                               object)
import           Data.Aeson.Types             (Value (..), (.:), (.=))
import           Data.Text                    (Text)
import           Test.QuickCheck.Arbitrary    (Arbitrary (..))

import           GitHub.Types.Base.DateTime
import           GitHub.Types.Base.HookConfig

------------------------------------------------------------------------------
-- Hook

data Hook = Hook
    { hookActive    :: Bool
    , hookConfig    :: HookConfig
    , hookCreatedAt :: DateTime
    , hookEvents    :: [Text]
    , hookId        :: Int
    , hookName      :: Text
    , hookPingUrl   :: Text
    , hookType      :: Text
    , hookUpdatedAt :: DateTime
    , hookUrl       :: Text
    } deriving (Eq, Show, Read)


instance FromJSON Hook where
    parseJSON (Object x) = Hook
        <$> x .: "active"
        <*> x .: "config"
        <*> x .: "created_at"
        <*> x .: "events"
        <*> x .: "id"
        <*> x .: "name"
        <*> x .: "ping_url"
        <*> x .: "type"
        <*> x .: "updated_at"
        <*> x .: "url"

    parseJSON _ = fail "Hook"


instance ToJSON Hook where
    toJSON Hook{..} = object
        [ "active"     .= hookActive
        , "config"     .= hookConfig
        , "created_at" .= hookCreatedAt
        , "events"     .= hookEvents
        , "id"         .= hookId
        , "name"       .= hookName
        , "ping_url"   .= hookPingUrl
        , "type"       .= hookType
        , "updated_at" .= hookUpdatedAt
        , "url"        .= hookUrl
        ]


instance Arbitrary Hook where
    arbitrary = Hook
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
