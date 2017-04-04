{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE Rank2Types #-}

module XMonadConfig.Shelly
  ( XMonadKeyMode (..)
  , switchKeyModeTo
  , currentKeyModeIs
  ) where

import Control.Monad.IO.Class (liftIO)
import Data.String (IsString)
import Data.Text (Text)
import Shelly (shelly, run_, lastExitCode)
import System.EasyFile (doesFileExist)
import XMonad.Core (X, spawn)
import qualified Data.Text as T

type FilePath'     = forall s. IsString s => s
data XMonadKeyMode = Common | UnixKeymap


unixKeymapModeFlagFile :: FilePath'
unixKeymapModeFlagFile = "/tmp/xmonad-keymode-UnixKeymap"


switchKeyModeTo :: XMonadKeyMode -> X ()
switchKeyModeTo UnixKeymap = liftIO . shelly $ do
  run_ "touch" [unixKeymapModeFlagFile]
  a <- lastExitCode
  run_ "xmonad" ["--restart"]
  b <- lastExitCode
  if a == 0 && b == 0
    then run_ "notify-send" ["XMonad", "Restarted"]
    else run_ "notify-send" ["XMonad", "xmonad restarting is failure"]

switchKeyModeTo Common = liftIO . shelly $ do
  run_ "rm" ["-f", unixKeymapModeFlagFile]
  run_ "xmonad" ["--restart"]
  a <- lastExitCode
  if a == 0
    then run_ "notify-send" ["XMonad", "Restarted"]
    else run_ "notify-send" ["XMonad", "xmonad restarting is failure"]


currentKeyModeIs :: XMonadKeyMode -> IO Bool
currentKeyModeIs UnixKeymap = doesFileExist unixKeymapModeFlagFile
currentKeyModeIs Common     = not <$> doesFileExist unixKeymapModeFlagFile
