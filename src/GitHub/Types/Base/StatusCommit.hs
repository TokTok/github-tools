{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.StatusCommit where

import           Control.Applicative             ((<$>), (<*>))
import           Data.Aeson                      (FromJSON (..), ToJSON (..),
                                                  object)
import           Data.Aeson.Types                (Value (..), (.:), (.=))
import           Data.Text                       (Text)
import           Test.QuickCheck.Arbitrary       (Arbitrary (..))

import           GitHub.Types.Base.CommitDetails
import           GitHub.Types.Base.CommitRefHtml
import           GitHub.Types.Base.User

------------------------------------------------------------------------------
-- StatusCommit

data StatusCommit = StatusCommit
    { statusCommitAuthor      :: User
    , statusCommitCommentsUrl :: Text
    , statusCommitCommit      :: CommitDetails
    , statusCommitCommitter   :: Maybe User
    , statusCommitHtmlUrl     :: Text
    , statusCommitParents     :: [CommitRefHtml]
    , statusCommitSha         :: Text
    , statusCommitUrl         :: Text
    } deriving (Eq, Show, Read)


instance FromJSON StatusCommit where
    parseJSON (Object x) = StatusCommit
        <$> x .: "author"
        <*> x .: "comments_url"
        <*> x .: "commit"
        <*> x .: "committer"
        <*> x .: "html_url"
        <*> x .: "parents"
        <*> x .: "sha"
        <*> x .: "url"

    parseJSON _ = fail "StatusCommit"


instance ToJSON StatusCommit where
    toJSON StatusCommit{..} = object
        [ "author"       .= statusCommitAuthor
        , "comments_url" .= statusCommitCommentsUrl
        , "commit"       .= statusCommitCommit
        , "committer"    .= statusCommitCommitter
        , "html_url"     .= statusCommitHtmlUrl
        , "parents"      .= statusCommitParents
        , "sha"          .= statusCommitSha
        , "url"          .= statusCommitUrl
        ]


instance Arbitrary StatusCommit where
    arbitrary = StatusCommit
        <$> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
        <*> arbitrary
