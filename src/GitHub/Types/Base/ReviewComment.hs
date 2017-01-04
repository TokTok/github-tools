{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.ReviewComment where

import           Control.Applicative                  ((<$>), (<*>))
import           Data.Aeson                           (FromJSON (..),
                                                       ToJSON (..), object)
import           Data.Aeson.Types                     (Value (..), (.:), (.=))
import           Data.Text                            (Text)
import           Test.QuickCheck.Arbitrary            (Arbitrary (..))

import           GitHub.Types.Base.DateTime
import           GitHub.Types.Base.ReviewCommentLinks
import           GitHub.Types.Base.User

------------------------------------------------------------------------------
-- ReviewComment

data ReviewComment = ReviewComment
    { reviewCommentUrl                 :: Text
    , reviewCommentHtmlUrl             :: Text
    , reviewCommentId                  :: Int
    , reviewCommentUser                :: User
    , reviewCommentPullRequestUrl      :: Text
    , reviewCommentOriginalPosition    :: Maybe Int
    , reviewCommentPosition            :: Maybe Int
    , reviewCommentPath                :: Maybe Text
    , reviewCommentCommitId            :: Text
    , reviewCommentCreatedAt           :: DateTime
    , reviewCommentUpdatedAt           :: DateTime
    , reviewCommentBody                :: Text
    , reviewCommentPullRequestReviewId :: Int
    , reviewCommentLinks               :: ReviewCommentLinks
    , reviewCommentDiffHunk            :: Text
    , reviewCommentOriginalCommitId    :: Text
    } deriving (Eq, Show, Read)


instance FromJSON ReviewComment where
    parseJSON (Object x) = ReviewComment
        <$> x .: "url"
        <*> x .: "html_url"
        <*> x .: "id"
        <*> x .: "user"
        <*> x .: "pull_request_url"
        <*> x .: "original_position"
        <*> x .: "position"
        <*> x .: "path"
        <*> x .: "commit_id"
        <*> x .: "created_at"
        <*> x .: "updated_at"
        <*> x .: "body"
        <*> x .: "pull_request_review_id"
        <*> x .: "_links"
        <*> x .: "diff_hunk"
        <*> x .: "original_commit_id"

    parseJSON _ = fail "ReviewComment"


instance ToJSON ReviewComment where
    toJSON ReviewComment{..} = object
        [ "url"                    .= reviewCommentUrl
        , "html_url"               .= reviewCommentHtmlUrl
        , "id"                     .= reviewCommentId
        , "user"                   .= reviewCommentUser
        , "pull_request_url"       .= reviewCommentPullRequestUrl
        , "original_position"      .= reviewCommentOriginalPosition
        , "position"               .= reviewCommentPosition
        , "path"                   .= reviewCommentPath
        , "commit_id"              .= reviewCommentCommitId
        , "created_at"             .= reviewCommentCreatedAt
        , "updated_at"             .= reviewCommentUpdatedAt
        , "body"                   .= reviewCommentBody
        , "pull_request_review_id" .= reviewCommentPullRequestReviewId
        , "_links"                 .= reviewCommentLinks
        , "diff_hunk"              .= reviewCommentDiffHunk
        , "original_commit_id"     .= reviewCommentOriginalCommitId
        ]


instance Arbitrary ReviewComment where
    arbitrary = ReviewComment
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
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
