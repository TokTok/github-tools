{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.CommitDetails where

import           Control.Applicative            ((<$>), (<*>))
import           Data.Aeson                     (FromJSON (..), ToJSON (..),
                                                 object)
import           Data.Aeson.Types               (Value (..), (.:), (.=))
import           Data.Text                      (Text)
import           Test.QuickCheck.Arbitrary      (Arbitrary (..))

import           GitHub.Types.Base.CommitRef
import           GitHub.Types.Base.UserStamp
import           GitHub.Types.Base.Verification

------------------------------------------------------------------------------
-- CommitDetails

data CommitDetails = CommitDetails
    { commitDetailsAuthor       :: UserStamp
    , commitDetailsCommentCount :: Int
    , commitDetailsCommitter    :: UserStamp
    , commitDetailsMessage      :: Text
    , commitDetailsTree         :: CommitRef
    , commitDetailsUrl          :: Text
    , commitDetailsVerification :: Verification
    } deriving (Eq, Show, Read)


instance FromJSON CommitDetails where
    parseJSON (Object x) = CommitDetails
        <$> x .: "author"
        <*> x .: "comment_count"
        <*> x .: "committer"
        <*> x .: "message"
        <*> x .: "tree"
        <*> x .: "url"
        <*> x .: "verification"

    parseJSON _ = fail "CommitDetails"


instance ToJSON CommitDetails where
    toJSON CommitDetails{..} = object
        [ "author"        .= commitDetailsAuthor
        , "comment_count" .= commitDetailsCommentCount
        , "committer"     .= commitDetailsCommitter
        , "message"       .= commitDetailsMessage
        , "tree"          .= commitDetailsTree
        , "url"           .= commitDetailsUrl
        , "verification"  .= commitDetailsVerification
        ]


instance Arbitrary CommitDetails where
    arbitrary = CommitDetails
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
