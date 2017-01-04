{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.PushCommit where

import           Control.Applicative       ((<$>), (<*>))
import           Data.Aeson                (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types          (Value (..), (.:), (.=))
import           Data.Text                 (Text)
import           Test.QuickCheck.Arbitrary (Arbitrary (..))

import           GitHub.Types.Base.Author

------------------------------------------------------------------------------
-- PushCommit

data PushCommit = PushCommit
    { pushCommitAdded     :: [Text]
    , pushCommitAuthor    :: Author
    , pushCommitCommitter :: Maybe Author
    , pushCommitDistinct  :: Bool
    , pushCommitId        :: Text
    , pushCommitMessage   :: Text
    , pushCommitModified  :: [Text]
    , pushCommitRemoved   :: [Text]
    , pushCommitTimestamp :: Text
    , pushCommitTreeId    :: Text
    , pushCommitUrl       :: Text
    } deriving (Eq, Show, Read)


instance FromJSON PushCommit where
    parseJSON (Object x) = PushCommit
        <$> x .: "added"
        <*> x .: "author"
        <*> x .: "committer"
        <*> x .: "distinct"
        <*> x .: "id"
        <*> x .: "message"
        <*> x .: "modified"
        <*> x .: "removed"
        <*> x .: "timestamp"
        <*> x .: "tree_id"
        <*> x .: "url"

    parseJSON _ = fail "PushCommit"


instance ToJSON PushCommit where
    toJSON PushCommit{..} = object
        [ "added"        .= pushCommitAdded
        , "author"       .= pushCommitAuthor
        , "committer"    .= pushCommitCommitter
        , "distinct"     .= pushCommitDistinct
        , "id"           .= pushCommitId
        , "message"      .= pushCommitMessage
        , "modified"     .= pushCommitModified
        , "removed"      .= pushCommitRemoved
        , "timestamp"    .= pushCommitTimestamp
        , "tree_id"      .= pushCommitTreeId
        , "url"          .= pushCommitUrl
        ]


instance Arbitrary PushCommit where
    arbitrary = PushCommit
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
        <*> arbitrary
