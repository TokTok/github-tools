module GitHub.Types.Base.DateTime where

import           Control.Applicative       ((<$>), (<|>))
import           Data.Aeson                (FromJSON (..), ToJSON (..))
import           Data.Text                 (Text)
import           Test.QuickCheck.Arbitrary (Arbitrary (..))
import qualified Test.QuickCheck.Gen       as Gen

------------------------------------------------------------------------------
-- DateTime

data DateTime
    = DateTimeStamp Int
    | DateTimeText Text
    deriving (Eq, Show, Read)


instance FromJSON DateTime where
    parseJSON x =
          DateTimeStamp <$> parseJSON x
      <|> DateTimeText  <$> parseJSON x


instance ToJSON DateTime where
    toJSON (DateTimeStamp x) = toJSON x
    toJSON (DateTimeText  x) = toJSON x


instance Arbitrary DateTime where
    arbitrary = Gen.oneof
      [ DateTimeStamp <$> arbitrary
      , DateTimeText  <$> arbitrary
      ]
