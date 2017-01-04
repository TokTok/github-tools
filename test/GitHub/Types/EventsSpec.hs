{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE Trustworthy         #-}
module GitHub.Types.EventsSpec where

import           Data.Aeson          (decode, encode)
import           Test.Hspec
import           Test.QuickCheck

import           GitHub.Types.Events


spec :: Spec
spec =
  describe "identity JSON conversion" $ do
    it "CommitCommentEvent"            $ property $ \(x :: CommitCommentEvent           ) -> decode (encode x) `shouldBe` Just x
    it "CreateEvent"                   $ property $ \(x :: CreateEvent                  ) -> decode (encode x) `shouldBe` Just x
    it "DeleteEvent"                   $ property $ \(x :: DeleteEvent                  ) -> decode (encode x) `shouldBe` Just x
    it "DeploymentEvent"               $ property $ \(x :: DeploymentEvent              ) -> decode (encode x) `shouldBe` Just x
    it "DeploymentStatusEvent"         $ property $ \(x :: DeploymentStatusEvent        ) -> decode (encode x) `shouldBe` Just x
    it "ForkEvent"                     $ property $ \(x :: ForkEvent                    ) -> decode (encode x) `shouldBe` Just x
    it "GollumEvent"                   $ property $ \(x :: GollumEvent                  ) -> decode (encode x) `shouldBe` Just x
    it "IssueCommentEvent"             $ property $ \(x :: IssueCommentEvent            ) -> decode (encode x) `shouldBe` Just x
    it "IssuesEvent"                   $ property $ \(x :: IssuesEvent                  ) -> decode (encode x) `shouldBe` Just x
    it "LabelEvent"                    $ property $ \(x :: LabelEvent                   ) -> decode (encode x) `shouldBe` Just x
    it "MemberEvent"                   $ property $ \(x :: MemberEvent                  ) -> decode (encode x) `shouldBe` Just x
    it "MembershipEvent"               $ property $ \(x :: MembershipEvent              ) -> decode (encode x) `shouldBe` Just x
    it "MilestoneEvent"                $ property $ \(x :: MilestoneEvent               ) -> decode (encode x) `shouldBe` Just x
    it "OrganizationEvent"             $ property $ \(x :: OrganizationEvent            ) -> decode (encode x) `shouldBe` Just x
    it "PageBuildEvent"                $ property $ \(x :: PageBuildEvent               ) -> decode (encode x) `shouldBe` Just x
    it "PingEvent"                     $ property $ \(x :: PingEvent                    ) -> decode (encode x) `shouldBe` Just x
    it "PullRequestEvent"              $ property $ \(x :: PullRequestEvent             ) -> decode (encode x) `shouldBe` Just x
    it "PullRequestReviewCommentEvent" $ property $ \(x :: PullRequestReviewCommentEvent) -> decode (encode x) `shouldBe` Just x
    it "PullRequestReviewEvent"        $ property $ \(x :: PullRequestReviewEvent       ) -> decode (encode x) `shouldBe` Just x
    it "PushEvent"                     $ property $ \(x :: PushEvent                    ) -> decode (encode x) `shouldBe` Just x
    it "ReleaseEvent"                  $ property $ \(x :: ReleaseEvent                 ) -> decode (encode x) `shouldBe` Just x
    it "RepositoryEvent"               $ property $ \(x :: RepositoryEvent              ) -> decode (encode x) `shouldBe` Just x
    it "StatusEvent"                   $ property $ \(x :: StatusEvent                  ) -> decode (encode x) `shouldBe` Just x
    it "WatchEvent"                    $ property $ \(x :: WatchEvent                   ) -> decode (encode x) `shouldBe` Just x
