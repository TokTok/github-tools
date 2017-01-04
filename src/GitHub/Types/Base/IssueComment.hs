{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.IssueComment where

import           Control.Applicative        ((<$>), (<*>))
import           Data.Aeson                 (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types           (Value (..), (.:), (.=))
import           Data.Text                  (Text)
import           Test.QuickCheck.Arbitrary  (Arbitrary (..))

import           GitHub.Types.Base.DateTime
import           GitHub.Types.Base.User

------------------------------------------------------------------------------
-- IssueComment

data IssueComment = IssueComment
    { issueCommentBody      :: Text
    , issueCommentUrl       :: Text
    , issueCommentUser      :: User
    , issueCommentUpdatedAt :: DateTime
    , issueCommentCreatedAt :: DateTime
    , issueCommentId        :: Int
    , issueCommentIssueUrl  :: Text
    , issueCommentHtmlUrl   :: Text
    } deriving (Eq, Show, Read)


instance FromJSON IssueComment where
    parseJSON (Object x) = IssueComment
        <$> x .: "body"
        <*> x .: "url"
        <*> x .: "user"
        <*> x .: "updated_at"
        <*> x .: "created_at"
        <*> x .: "id"
        <*> x .: "issue_url"
        <*> x .: "html_url"

    parseJSON _ = fail "IssueComment"


instance ToJSON IssueComment where
    toJSON IssueComment{..} = object
        [ "body"       .= issueCommentBody
        , "url"        .= issueCommentUrl
        , "user"       .= issueCommentUser
        , "updated_at" .= issueCommentUpdatedAt
        , "created_at" .= issueCommentCreatedAt
        , "id"         .= issueCommentId
        , "issue_url"  .= issueCommentIssueUrl
        , "html_url"   .= issueCommentHtmlUrl
        ]


instance Arbitrary IssueComment where
    arbitrary = IssueComment
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
