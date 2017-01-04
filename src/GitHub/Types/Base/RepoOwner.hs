module GitHub.Types.Base.RepoOwner where

import           Control.Applicative       ((<$>), (<|>))
import           Data.Aeson                (FromJSON (..), ToJSON (..))
import           Test.QuickCheck.Arbitrary (Arbitrary (..))
import qualified Test.QuickCheck.Gen       as Gen

import           GitHub.Types.Base.User
import           GitHub.Types.Base.UserRef

------------------------------------------------------------------------------
-- RepoOwner

data RepoOwner
    = RepoOwnerUser User
    | RepoOwnerUserRef UserRef
    deriving (Eq, Show, Read)


instance FromJSON RepoOwner where
    parseJSON x =
          RepoOwnerUser    <$> parseJSON x
      <|> RepoOwnerUserRef <$> parseJSON x


instance ToJSON RepoOwner where
    toJSON (RepoOwnerUser    x) = toJSON x
    toJSON (RepoOwnerUserRef x) = toJSON x


instance Arbitrary RepoOwner where
    arbitrary = Gen.oneof
      [ RepoOwnerUser    <$> arbitrary
      , RepoOwnerUserRef <$> arbitrary
      ]
