{-# LANGUAGE OverloadedStrings #-}
module GitHub.WebHook.Handler
  ( Handler (..)
  , Error (..)
  , runHandler
  , removeNulls
  ) where

import           Control.Applicative   (Applicative, pure)
import           Crypto.Hash           (HMAC, SHA1, digestToHexByteString, hmac,
                                        hmacGetDigest)
import           Data.Aeson            (ToJSON (..), Value (..),
                                        eitherDecodeStrict')
import           Data.Aeson.Types      (parseEither)
import           Data.ByteString       (ByteString)
import qualified Data.ByteString.Char8 as BC8
import qualified Data.HashMap.Strict   as HashMap
import           Data.Monoid           ((<>))
import           Data.Text             (Text)
import qualified Data.Text             as Text
import           Data.Text.Encoding    (decodeUtf8)
import           Data.UUID             (UUID, fromASCIIBytes)
import qualified Data.Vector           as Vector

import           GitHub.Types



data Handler m = Handler
    { hSecretKeys :: [String]
      -- ^ Secret keys which are used to authenticate the incoming request.
      -- If the list is empty then no authentication is required. The handler
      -- tries each key until it finds one which works. This makes it easier
      -- to rotate keys because you can have multiple ones active at any given
      -- point in time.

    , hBody       :: m ByteString
      -- ^ Action which is used to read the request body.

    , hHeader     :: ByteString -> m (Maybe ByteString)
      -- ^ Action which is used to retrieve a particular header from the
      -- request.
    }


data Error
    = InvalidRequest
      -- ^ The incoming request is not well-formed. If that happens it means
      -- GitHub screwed something up, or changed the format of the request.

    | ParseError !Text
      -- ^ The request looks valid but we failed to parse the payload. This
      -- could be because our parsing code is wrong, or because GitHub added
      -- a new event type which we don't handle yet.

    | IncompleteParse Value Payload
      -- ^ The request looks valid but we failed to parse the payload. This
      -- could be because our parsing code is wrong, or because GitHub added
      -- a new event type which we don't handle yet.

    | UnsignedRequest
      -- ^ We were expecting a signed request but no signature was included.
      -- Such requests are rejected beause we don't want to accept requests from
      -- untrusted sources.

    | InvalidSignature
      -- ^ A signature was included in the request but it did not match the
      -- secret key which was providid to the handler. Usually points to
      -- a configuration error on either end.


toParseError :: String -> Either Error Payload
toParseError = Left . ParseError . Text.pack


removeNulls :: ToJSON a => a -> Value
removeNulls = go . toJSON
  where
    go (Array  x) = Array . Vector.map go $ x
    go (Object x) = Object . HashMap.map go . HashMap.filter (/= Null) $ x
    go         x  = x


toSuccess :: Value -> Payload -> Either Error Payload
toSuccess value payload =
  if removeNulls payload == removeNulls value
    then Right payload
    else Left $ IncompleteParse value payload


verifySecretKey :: ByteString -> ByteString -> String -> Bool
verifySecretKey rawBody sig key = sig == ("sha1=" <> digestToHexByteString
    (hmacGetDigest (hmac (BC8.pack key) rawBody :: HMAC SHA1)))


runHandler :: (Applicative m, Monad m) => Handler m -> m (Either Error (UUID, Payload))
runHandler h = do
    mbDelivery <- pure . (fromASCIIBytes =<<) =<< hHeader h "X-GitHub-Delivery"

    res <- do
        rawBody     <- hBody h
        mbSignature <- hHeader h "X-Hub-Signature"

        authenticatedBody <- pure $ case (hSecretKeys h, mbSignature) of

            -- No secret key and no signature. Pass along the body unverified.
            ([], Nothing) -> Right rawBody

            -- Signature is available but no secret keys to verify it. This is
            -- not a fatal error, we can still process the event.
            ([], Just _) -> Right rawBody

            -- Secret keys are available but the request is not signed. Reject
            -- the request.
            (_, Nothing) -> Left UnsignedRequest

            -- Both the signature and secret keys are available. Verify the
            -- signature with the first key which works, otherwise reject the
            -- request.
            (secretKeys, Just sig) ->
                if any (verifySecretKey rawBody sig) secretKeys
                    then Right rawBody
                    else Left InvalidSignature

        mbEventName <- hHeader h "X-GitHub-Event"
        pure $ do
            eventName <- maybe (Left InvalidRequest) Right mbEventName
            body      <- authenticatedBody
            case eitherDecodeStrict' body of
                Left e -> toParseError e
                Right value -> either toParseError (toSuccess value) $
                    parseEither (webhookPayloadParser $ decodeUtf8 eventName) value

    pure $ case mbDelivery of
        Nothing   -> Left InvalidRequest
        Just uuid -> fmap ((,) uuid) res
