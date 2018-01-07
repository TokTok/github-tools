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
    { issueCommentAuthorAssociation :: Text
    , issueCommentBody              :: Text
    , issueCommentCreatedAt         :: DateTime
    , issueCommentHtmlUrl           :: Text
    , issueCommentId                :: Int
    , issueCommentIssueUrl          :: Text
    , issueCommentUpdatedAt         :: DateTime
    , issueCommentUrl               :: Text
    , issueCommentUser              :: User
    } deriving (Eq, Show, Read)


instance FromJSON IssueComment where
    parseJSON (Object x) = IssueComment
        <$> x .: "author_association"
        <*> x .: "body"
        <*> x .: "created_at"
        <*> x .: "html_url"
        <*> x .: "id"
        <*> x .: "issue_url"
        <*> x .: "updated_at"
        <*> x .: "url"
        <*> x .: "user"

    parseJSON _ = fail "IssueComment"


instance ToJSON IssueComment where
    toJSON IssueComment{..} = object
        [ "author_association" .= issueCommentAuthorAssociation
        , "body"               .= issueCommentBody
        , "created_at"         .= issueCommentCreatedAt
        , "html_url"           .= issueCommentHtmlUrl
        , "id"                 .= issueCommentId
        , "issue_url"          .= issueCommentIssueUrl
        , "updated_at"         .= issueCommentUpdatedAt
        , "url"                .= issueCommentUrl
        , "user"               .= issueCommentUser
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
        <*> arbitrary
