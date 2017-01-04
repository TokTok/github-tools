{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.Commit where

import           Control.Applicative          ((<$>), (<*>))
import           Data.Aeson                   (FromJSON (..), ToJSON (..),
                                               object)
import           Data.Aeson.Types             (Value (..), (.:), (.=))
import           Data.Text                    (Text)
import           Test.QuickCheck.Arbitrary    (Arbitrary (..))

import           GitHub.Types.Base.Repository
import           GitHub.Types.Base.User

------------------------------------------------------------------------------
-- Commit

data Commit = Commit
    { commitSha   :: Text
    , commitUser  :: User
    , commitRepo  :: Repository
    , commitLabel :: Text
    , commitRef   :: Text
    } deriving (Eq, Show, Read)


instance FromJSON Commit where
    parseJSON (Object x) = Commit
        <$> x .: "sha"
        <*> x .: "user"
        <*> x .: "repo"
        <*> x .: "label"
        <*> x .: "ref"

    parseJSON _ = fail "Commit"


instance ToJSON Commit where
    toJSON Commit{..} = object
        [ "sha"   .= commitSha
        , "user"  .= commitUser
        , "repo"  .= commitRepo
        , "label" .= commitLabel
        , "ref"   .= commitRef
        ]


instance Arbitrary Commit where
    arbitrary = Commit
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
