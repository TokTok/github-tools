module GitHub.Types.PayloadParser where

import           Data.Aeson          (FromJSON (..), ToJSON (..))
import           Data.Aeson.Types    (Parser, Value (..))
import qualified Data.List           as List
import           Data.Text           (Text)
import qualified Data.Text           as Text

import           GitHub.Types.Event
import           GitHub.Types.Events


data Payload
    = CommitCommentEventPayload            CommitCommentEvent
    | CreateEventPayload                   CreateEvent
    | DeleteEventPayload                   DeleteEvent
    | DeploymentEventPayload               DeploymentEvent
    | DeploymentStatusEventPayload         DeploymentStatusEvent
    | ForkEventPayload                     ForkEvent
    | GollumEventPayload                   GollumEvent
    | IssueCommentEventPayload             IssueCommentEvent
    | IssuesEventPayload                   IssuesEvent
    | LabelEventPayload                    LabelEvent
    | MemberEventPayload                   MemberEvent
    | MembershipEventPayload               MembershipEvent
    | MilestoneEventPayload                MilestoneEvent
    | OrganizationEventPayload             OrganizationEvent
    | PageBuildEventPayload                PageBuildEvent
    | PingEventPayload                     PingEvent
    | PullRequestEventPayload              PullRequestEvent
    | PullRequestReviewCommentEventPayload PullRequestReviewCommentEvent
    | PullRequestReviewEventPayload        PullRequestReviewEvent
    | PushEventPayload                     PushEvent
    | ReleaseEventPayload                  ReleaseEvent
    | RepositoryEventPayload               RepositoryEvent
    | StatusEventPayload                   StatusEvent
    | WatchEventPayload                    WatchEvent
    deriving (Eq, Show, Read)


instance ToJSON Payload where
    toJSON (CommitCommentEventPayload            x) = toJSON x
    toJSON (CreateEventPayload                   x) = toJSON x
    toJSON (DeleteEventPayload                   x) = toJSON x
    toJSON (DeploymentEventPayload               x) = toJSON x
    toJSON (DeploymentStatusEventPayload         x) = toJSON x
    toJSON (ForkEventPayload                     x) = toJSON x
    toJSON (GollumEventPayload                   x) = toJSON x
    toJSON (IssueCommentEventPayload             x) = toJSON x
    toJSON (IssuesEventPayload                   x) = toJSON x
    toJSON (LabelEventPayload                    x) = toJSON x
    toJSON (MemberEventPayload                   x) = toJSON x
    toJSON (MembershipEventPayload               x) = toJSON x
    toJSON (MilestoneEventPayload                x) = toJSON x
    toJSON (OrganizationEventPayload             x) = toJSON x
    toJSON (PageBuildEventPayload                x) = toJSON x
    toJSON (PingEventPayload                     x) = toJSON x
    toJSON (PullRequestEventPayload              x) = toJSON x
    toJSON (PullRequestReviewCommentEventPayload x) = toJSON x
    toJSON (PullRequestReviewEventPayload        x) = toJSON x
    toJSON (PushEventPayload                     x) = toJSON x
    toJSON (ReleaseEventPayload                  x) = toJSON x
    toJSON (RepositoryEventPayload               x) = toJSON x
    toJSON (StatusEventPayload                   x) = toJSON x
    toJSON (WatchEventPayload                    x) = toJSON x


data PayloadParser = PayloadParser
    { payloadParserTypeName    :: Text
    , payloadParserWebhookName :: Text
    , payloadParser            :: Value -> Parser Payload
    }


payloadParsers :: [PayloadParser]
payloadParsers =
    [ eventParser CommitCommentEventPayload
    , eventParser CreateEventPayload
    , eventParser DeleteEventPayload
    , eventParser DeploymentEventPayload
    , eventParser DeploymentStatusEventPayload
    , eventParser ForkEventPayload
    , eventParser GollumEventPayload
    , eventParser IssueCommentEventPayload
    , eventParser IssuesEventPayload
    , eventParser LabelEventPayload
    , eventParser MemberEventPayload
    , eventParser MembershipEventPayload
    , eventParser MilestoneEventPayload
    , eventParser OrganizationEventPayload
    , eventParser PageBuildEventPayload
    , eventParser PingEventPayload
    , eventParser PullRequestEventPayload
    , eventParser PullRequestReviewCommentEventPayload
    , eventParser PullRequestReviewEventPayload
    , eventParser PushEventPayload
    , eventParser ReleaseEventPayload
    , eventParser RepositoryEventPayload
    , eventParser StatusEventPayload
    , eventParser WatchEventPayload
    ]
  where
    eventParser' :: (FromJSON a, Event a) => TypeName a -> EventName a -> (a -> Payload) -> PayloadParser
    eventParser' (TypeName ty) (EventName ev) tycon =
      PayloadParser ty ev (fmap tycon . parseJSON)

    eventParser :: (FromJSON a, Event a) => (a -> Payload) -> PayloadParser
    eventParser = eventParser' typeName eventName



eventPayloadParser :: Text -> Value -> Parser Payload
eventPayloadParser eventType x =
  case List.find ((== eventType) . payloadParserTypeName) payloadParsers of
    Nothing -> fail $ "eventPayloadParser: unknown event type: " ++ Text.unpack eventType
    Just p  -> payloadParser p x

-- | Since the event type is included through different means (X-GitHub-Event
-- header, or inline in the JSON object), it's not possible to make 'Event'
-- an instance of 'FromJSON'. But if you know the type, you can use this
-- parser.
webhookPayloadParser :: Text -> Value -> Parser Payload
webhookPayloadParser eventType x =
  case List.find ((== eventType) . payloadParserWebhookName) payloadParsers of
    Nothing -> fail $ "webhookPayloadParser: unknown event type: " ++ Text.unpack eventType
    Just p  -> payloadParser p x
