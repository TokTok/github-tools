{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.PullRequest where

import           Control.Applicative                ((<$>), (<*>))
import           Data.Aeson                         (FromJSON (..), ToJSON (..),
                                                     object)
import           Data.Aeson.Types                   (Value (..), (.:), (.=))
import           Data.Text                          (Text)
import           Test.QuickCheck.Arbitrary          (Arbitrary (..))

import           GitHub.Types.Base.Commit
import           GitHub.Types.Base.DateTime
import           GitHub.Types.Base.Milestone
import           GitHub.Types.Base.PullRequestLinks
import           GitHub.Types.Base.User

------------------------------------------------------------------------------
-- PullRequest

data PullRequest = PullRequest
    { pullRequestAdditions           :: Int
    , pullRequestAssignee            :: Maybe User
    , pullRequestAssignees           :: [User]
    , pullRequestAuthorAssociation   :: Text
    , pullRequestBase                :: Commit
    , pullRequestBody                :: Text
    , pullRequestChangedFiles        :: Int
    , pullRequestClosedAt            :: Maybe DateTime
    , pullRequestComments            :: Int
    , pullRequestCommentsUrl         :: Text
    , pullRequestCommits             :: Int
    , pullRequestCommitsUrl          :: Text
    , pullRequestCreatedAt           :: DateTime
    , pullRequestDeletions           :: Int
    , pullRequestDiffUrl             :: Text
    , pullRequestHead                :: Commit
    , pullRequestHtmlUrl             :: Text
    , pullRequestId                  :: Int
    , pullRequestIssueUrl            :: Text
    , pullRequestLinks               :: PullRequestLinks
    , pullRequestLocked              :: Bool
    , pullRequestMaintainerCanModify :: Bool
    , pullRequestMergeable           :: Maybe Bool
    , pullRequestMergeableState      :: Text
    , pullRequestMergeCommitSha      :: Maybe Text
    , pullRequestMerged              :: Bool
    , pullRequestMergedAt            :: Maybe DateTime
    , pullRequestMergedBy            :: Maybe User
    , pullRequestMilestone           :: Maybe Milestone
    , pullRequestNumber              :: Int
    , pullRequestPatchUrl            :: Text
    , pullRequestRebaseable          :: Maybe Bool
    , pullRequestRequestedReviewers  :: [Text]
    , pullRequestReviewComments      :: Int
    , pullRequestReviewCommentsUrl   :: Text
    , pullRequestReviewCommentUrl    :: Text
    , pullRequestState               :: Text
    , pullRequestStatusesUrl         :: Text
    , pullRequestTitle               :: Text
    , pullRequestUpdatedAt           :: DateTime
    , pullRequestUrl                 :: Text
    , pullRequestUser                :: User
    } deriving (Eq, Show, Read)


instance FromJSON PullRequest where
    parseJSON (Object x) = PullRequest
        <$> x .: "additions"
        <*> x .: "assignee"
        <*> x .: "assignees"
        <*> x .: "author_association"
        <*> x .: "base"
        <*> x .: "body"
        <*> x .: "changed_files"
        <*> x .: "closed_at"
        <*> x .: "comments"
        <*> x .: "comments_url"
        <*> x .: "commits"
        <*> x .: "commits_url"
        <*> x .: "created_at"
        <*> x .: "deletions"
        <*> x .: "diff_url"
        <*> x .: "head"
        <*> x .: "html_url"
        <*> x .: "id"
        <*> x .: "issue_url"
        <*> x .: "_links"
        <*> x .: "locked"
        <*> x .: "maintainer_can_modify"
        <*> x .: "mergeable"
        <*> x .: "mergeable_state"
        <*> x .: "merge_commit_sha"
        <*> x .: "merged"
        <*> x .: "merged_at"
        <*> x .: "merged_by"
        <*> x .: "milestone"
        <*> x .: "number"
        <*> x .: "patch_url"
        <*> x .: "rebaseable"
        <*> x .: "requested_reviewers"
        <*> x .: "review_comments"
        <*> x .: "review_comments_url"
        <*> x .: "review_comment_url"
        <*> x .: "state"
        <*> x .: "statuses_url"
        <*> x .: "title"
        <*> x .: "updated_at"
        <*> x .: "url"
        <*> x .: "user"

    parseJSON _ = fail "PullRequest"


instance ToJSON PullRequest where
    toJSON PullRequest{..} = object
        [ "additions"             .= pullRequestAdditions
        , "assignee"              .= pullRequestAssignee
        , "assignees"             .= pullRequestAssignees
        , "author_association"    .= pullRequestAuthorAssociation
        , "base"                  .= pullRequestBase
        , "body"                  .= pullRequestBody
        , "changed_files"         .= pullRequestChangedFiles
        , "closed_at"             .= pullRequestClosedAt
        , "comments"              .= pullRequestComments
        , "comments_url"          .= pullRequestCommentsUrl
        , "commits"               .= pullRequestCommits
        , "commits_url"           .= pullRequestCommitsUrl
        , "created_at"            .= pullRequestCreatedAt
        , "deletions"             .= pullRequestDeletions
        , "diff_url"              .= pullRequestDiffUrl
        , "head"                  .= pullRequestHead
        , "html_url"              .= pullRequestHtmlUrl
        , "id"                    .= pullRequestId
        , "issue_url"             .= pullRequestIssueUrl
        , "_links"                .= pullRequestLinks
        , "locked"                .= pullRequestLocked
        , "maintainer_can_modify" .= pullRequestMaintainerCanModify
        , "mergeable"             .= pullRequestMergeable
        , "mergeable_state"       .= pullRequestMergeableState
        , "merge_commit_sha"      .= pullRequestMergeCommitSha
        , "merged"                .= pullRequestMerged
        , "merged_at"             .= pullRequestMergedAt
        , "merged_by"             .= pullRequestMergedBy
        , "milestone"             .= pullRequestMilestone
        , "number"                .= pullRequestNumber
        , "patch_url"             .= pullRequestPatchUrl
        , "rebaseable"            .= pullRequestRebaseable
        , "requested_reviewers"   .= pullRequestRequestedReviewers
        , "review_comments"       .= pullRequestReviewComments
        , "review_comments_url"   .= pullRequestReviewCommentsUrl
        , "review_comment_url"    .= pullRequestReviewCommentUrl
        , "state"                 .= pullRequestState
        , "statuses_url"          .= pullRequestStatusesUrl
        , "title"                 .= pullRequestTitle
        , "updated_at"            .= pullRequestUpdatedAt
        , "url"                   .= pullRequestUrl
        , "user"                  .= pullRequestUser
        ]


instance Arbitrary PullRequest where
    arbitrary = PullRequest
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
