{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.CommitDetails where

import           Control.Applicative         ((<$>), (<*>))
import           Data.Aeson                  (FromJSON (..), ToJSON (..),
                                              object)
import           Data.Aeson.Types            (Value (..), (.:), (.=))
import           Data.Text                   (Text)
import           Test.QuickCheck.Arbitrary   (Arbitrary (..))

import           GitHub.Types.Base.CommitRef
import           GitHub.Types.Base.UserStamp

------------------------------------------------------------------------------
-- CommitDetails

data CommitDetails = CommitDetails
    { commitDetailsAuthor       :: UserStamp
    , commitDetailsCommitter    :: UserStamp
    , commitDetailsMessage      :: Text
    , commitDetailsTree         :: CommitRef
    , commitDetailsUrl          :: Text
    , commitDetailsCommentCount :: Int
    } deriving (Eq, Show, Read)


instance FromJSON CommitDetails where
    parseJSON (Object x) = CommitDetails
        <$> x .: "author"
        <*> x .: "committer"
        <*> x .: "message"
        <*> x .: "tree"
        <*> x .: "url"
        <*> x .: "comment_count"

    parseJSON _ = fail "CommitDetails"


instance ToJSON CommitDetails where
    toJSON CommitDetails{..} = object
        [ "author"        .= commitDetailsAuthor
        , "committer"     .= commitDetailsCommitter
        , "message"       .= commitDetailsMessage
        , "tree"          .= commitDetailsTree
        , "url"           .= commitDetailsUrl
        , "comment_count" .= commitDetailsCommentCount
        ]


instance Arbitrary CommitDetails where
    arbitrary = CommitDetails
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
