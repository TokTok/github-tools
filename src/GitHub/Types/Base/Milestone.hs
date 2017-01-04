{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module GitHub.Types.Base.Milestone where

import           Control.Applicative        ((<$>), (<*>))
import           Data.Aeson                 (FromJSON (..), ToJSON (..), object)
import           Data.Aeson.Types           (Value (..), (.:), (.=))
import           Data.Text                  (Text)
import           Test.QuickCheck.Arbitrary  (Arbitrary (..))

import           GitHub.Types.Base.DateTime
import           GitHub.Types.Base.User

------------------------------------------------------------------------------
-- Milestone

data Milestone = Milestone
    { milestoneCreator      :: User
    , milestoneClosedIssues :: Int
    , milestoneState        :: Text
    , milestoneDueOn        :: Text
    , milestoneUrl          :: Text
    , milestoneUpdatedAt    :: DateTime
    , milestoneCreatedAt    :: DateTime
    , milestoneId           :: Int
    , milestoneTitle        :: Text
    , milestoneClosedAt     :: Maybe DateTime
    , milestoneNumber       :: Int
    , milestoneDescription  :: Text
    , milestoneLabelsUrl    :: Text
    , milestoneHtmlUrl      :: Text
    , milestoneOpenIssues   :: Int
    } deriving (Eq, Show, Read)


instance FromJSON Milestone where
    parseJSON (Object x) = Milestone
        <$> x .: "creator"
        <*> x .: "closed_issues"
        <*> x .: "state"
        <*> x .: "due_on"
        <*> x .: "url"
        <*> x .: "updated_at"
        <*> x .: "created_at"
        <*> x .: "id"
        <*> x .: "title"
        <*> x .: "closed_at"
        <*> x .: "number"
        <*> x .: "description"
        <*> x .: "labels_url"
        <*> x .: "html_url"
        <*> x .: "open_issues"

    parseJSON _ = fail "Milestone"


instance ToJSON Milestone where
    toJSON Milestone{..} = object
        [ "creator"       .= milestoneCreator
        , "closed_issues" .= milestoneClosedIssues
        , "state"         .= milestoneState
        , "due_on"        .= milestoneDueOn
        , "url"           .= milestoneUrl
        , "updated_at"    .= milestoneUpdatedAt
        , "created_at"    .= milestoneCreatedAt
        , "id"            .= milestoneId
        , "title"         .= milestoneTitle
        , "closed_at"     .= milestoneClosedAt
        , "number"        .= milestoneNumber
        , "description"   .= milestoneDescription
        , "labels_url"    .= milestoneLabelsUrl
        , "html_url"      .= milestoneHtmlUrl
        , "open_issues"   .= milestoneOpenIssues
        ]


instance Arbitrary Milestone where
    arbitrary = Milestone
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
