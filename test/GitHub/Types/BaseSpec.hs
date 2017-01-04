{-# LANGUAGE DeriveGeneric       #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE Trustworthy         #-}
module GitHub.Types.BaseSpec where

import           Control.Applicative ((<$>))
import           Data.Aeson          (FromJSON, ToJSON, decode, encode)
import           GHC.Generics        (Generic)
import           Test.Hspec
import           Test.QuickCheck

import           GitHub.Types.Base


spec :: Spec
spec =
  describe "identity JSON conversion" $ do
    it "Author"             $ property $ \(x :: Author            ) -> decode (encode x) `shouldBe` Just x
    it "Branch"             $ property $ \(x :: Branch            ) -> decode (encode x) `shouldBe` Just x
    it "Change"             $ property $ \(x :: Change            ) -> decode (encode x) `shouldBe` Just x
    it "Changes"            $ property $ \(x :: Changes           ) -> decode (encode x) `shouldBe` Just x
    it "Commit"             $ property $ \(x :: Commit            ) -> decode (encode x) `shouldBe` Just x
    it "CommitComment"      $ property $ \(x :: CommitComment     ) -> decode (encode x) `shouldBe` Just x
    it "CommitDetails"      $ property $ \(x :: CommitDetails     ) -> decode (encode x) `shouldBe` Just x
    it "CommitRef"          $ property $ \(x :: CommitRef         ) -> decode (encode x) `shouldBe` Just x
    it "CommitRefHtml"      $ property $ \(x :: CommitRefHtml     ) -> decode (encode x) `shouldBe` Just x
    -- DateTime is not an object, so we put it in a list. Valid JSON starts with
    -- either { for object or [ for array. DateTime is either a plain int or a
    -- plain string.
    it "DateTime"           $ property $ \(x :: [DateTime]        ) -> decode (encode x) `shouldBe` Just x
    it "Deployment"         $ property $ \(x :: Deployment        ) -> decode (encode x) `shouldBe` Just x
    it "DeploymentStatus"   $ property $ \(x :: DeploymentStatus  ) -> decode (encode x) `shouldBe` Just x
    it "Hook"               $ property $ \(x :: Hook              ) -> decode (encode x) `shouldBe` Just x
    it "HookConfig"         $ property $ \(x :: HookConfig        ) -> decode (encode x) `shouldBe` Just x
    it "Invitation"         $ property $ \(x :: Invitation        ) -> decode (encode x) `shouldBe` Just x
    it "Issue"              $ property $ \(x :: Issue             ) -> decode (encode x) `shouldBe` Just x
    it "IssueComment"       $ property $ \(x :: IssueComment      ) -> decode (encode x) `shouldBe` Just x
    it "Label"              $ property $ \(x :: Label             ) -> decode (encode x) `shouldBe` Just x
    it "Link"               $ property $ \(x :: Link              ) -> decode (encode x) `shouldBe` Just x
    it "Membership"         $ property $ \(x :: Membership        ) -> decode (encode x) `shouldBe` Just x
    it "Milestone"          $ property $ \(x :: Milestone         ) -> decode (encode x) `shouldBe` Just x
    it "Organization"       $ property $ \(x :: Organization      ) -> decode (encode x) `shouldBe` Just x
    it "PageBuild"          $ property $ \(x :: PageBuild         ) -> decode (encode x) `shouldBe` Just x
    it "PageBuildError"     $ property $ \(x :: PageBuildError    ) -> decode (encode x) `shouldBe` Just x
    it "PullRequest"        $ property $ \(x :: PullRequest       ) -> decode (encode x) `shouldBe` Just x
    it "PullRequestLinks"   $ property $ \(x :: PullRequestLinks  ) -> decode (encode x) `shouldBe` Just x
    it "PullRequestRef"     $ property $ \(x :: PullRequestRef    ) -> decode (encode x) `shouldBe` Just x
    it "PushCommit"         $ property $ \(x :: PushCommit        ) -> decode (encode x) `shouldBe` Just x
    it "Release"            $ property $ \(x :: Release           ) -> decode (encode x) `shouldBe` Just x
    it "RepoOwner"          $ property $ \(x :: RepoOwner         ) -> decode (encode x) `shouldBe` Just x
    it "Repository"         $ property $ \(x :: Repository        ) -> decode (encode x) `shouldBe` Just x
    it "Review"             $ property $ \(x :: Review            ) -> decode (encode x) `shouldBe` Just x
    it "ReviewComment"      $ property $ \(x :: ReviewComment     ) -> decode (encode x) `shouldBe` Just x
    it "ReviewCommentLinks" $ property $ \(x :: ReviewCommentLinks) -> decode (encode x) `shouldBe` Just x
    it "ReviewLinks"        $ property $ \(x :: ReviewLinks       ) -> decode (encode x) `shouldBe` Just x
    it "SimplePullRequest"  $ property $ \(x :: SimplePullRequest ) -> decode (encode x) `shouldBe` Just x
    it "StatusCommit"       $ property $ \(x :: StatusCommit      ) -> decode (encode x) `shouldBe` Just x
    it "Team"               $ property $ \(x :: Team              ) -> decode (encode x) `shouldBe` Just x
    it "User"               $ property $ \(x :: User              ) -> decode (encode x) `shouldBe` Just x
    it "UserRef"            $ property $ \(x :: UserRef           ) -> decode (encode x) `shouldBe` Just x
    it "UserStamp"          $ property $ \(x :: UserStamp         ) -> decode (encode x) `shouldBe` Just x
