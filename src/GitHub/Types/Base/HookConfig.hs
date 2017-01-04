{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.HookConfig where

import           Control.Applicative       ((<$>), (<*>))
import           Data.Aeson                (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types          (Value (..), (.:), (.=))
import           Data.Text                 (Text)
import           Test.QuickCheck.Arbitrary (Arbitrary (..))

------------------------------------------------------------------------------
-- HookConfig

data HookConfig = HookConfig
    { hookConfigContentType :: Text
    , hookConfigInsecureSsl :: Text
    , hookConfigSecret      :: Text
    , hookConfigUrl         :: Text
    } deriving (Eq, Show, Read)


instance FromJSON HookConfig where
    parseJSON (Object x) = HookConfig
        <$> x .: "content_type"
        <*> x .: "insecure_ssl"
        <*> x .: "secret"
        <*> x .: "url"

    parseJSON _ = fail "HookConfig"


instance ToJSON HookConfig where
    toJSON HookConfig{..} = object
        [ "content_type" .= hookConfigContentType
        , "insecure_ssl" .= hookConfigInsecureSsl
        , "secret"       .= hookConfigSecret
        , "url"          .= hookConfigUrl
        ]


instance Arbitrary HookConfig where
    arbitrary = HookConfig
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
