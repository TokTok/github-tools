{-# LANGUAGE OverloadedStrings #-}
module Main (main) where

import           Control.Applicative   ((<$>))
import qualified Data.ByteString.Char8 as BS8
import qualified Data.Text             as Text
import qualified GitHub
import           System.Environment    (getEnv, lookupEnv)

import           PullStatus


main :: IO ()
main = do
  -- Get auth token from the $GITHUB_TOKEN environment variable.
  auth <- Just . GitHub.OAuth . BS8.pack <$> getEnv "GITHUB_TOKEN"

  -- Check if we need to produce HTML or ASCII art.
  wantHtml <- (/= Nothing) <$> lookupEnv "GITHUB_WANT_HTML"

  putStrLn . Text.unpack =<< getPullStatus "TokTok" "TokTok" wantHtml auth
