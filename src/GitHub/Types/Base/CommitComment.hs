{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.CommitComment where

import           Control.Applicative        ((<$>), (<*>))
import           Data.Aeson                 (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types           (Value (..), (.:), (.=))
import           Data.Text                  (Text)
import           Test.QuickCheck.Arbitrary  (Arbitrary (..))

import           GitHub.Types.Base.DateTime
import           GitHub.Types.Base.User

------------------------------------------------------------------------------
-- CommitComment

data CommitComment = CommitComment
    { commitCommentUrl       :: Text
    , commitCommentHtmlUrl   :: Text
    , commitCommentId        :: Int
    , commitCommentUser      :: User
    , commitCommentPosition  :: Maybe Int
    , commitCommentLine      :: Maybe Int
    , commitCommentPath      :: Maybe Text
    , commitCommentCommitId  :: Text
    , commitCommentCreatedAt :: DateTime
    , commitCommentUpdatedAt :: DateTime
    , commitCommentBody      :: Text
    } deriving (Eq, Show, Read)


instance FromJSON CommitComment where
    parseJSON (Object x) = CommitComment
        <$> x .: "url"
        <*> x .: "html_url"
        <*> x .: "id"
        <*> x .: "user"
        <*> x .: "position"
        <*> x .: "line"
        <*> x .: "path"
        <*> x .: "commit_id"
        <*> x .: "created_at"
        <*> x .: "updated_at"
        <*> x .: "body"

    parseJSON _ = fail "CommitComment"


instance ToJSON CommitComment where
    toJSON CommitComment{..} = object
        [ "url"        .= commitCommentUrl
        , "html_url"   .= commitCommentHtmlUrl
        , "id"         .= commitCommentId
        , "user"       .= commitCommentUser
        , "position"   .= commitCommentPosition
        , "line"       .= commitCommentLine
        , "path"       .= commitCommentPath
        , "commit_id"  .= commitCommentCommitId
        , "created_at" .= commitCommentCreatedAt
        , "updated_at" .= commitCommentUpdatedAt
        , "body"       .= commitCommentBody
        ]


instance Arbitrary CommitComment where
    arbitrary = CommitComment
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
