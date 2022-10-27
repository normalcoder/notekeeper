{-# language GHC2021 #-}

module Module1 () where

import Data.IORef
import Control.Concurrent
import Control.Concurrent.MVar
import GHC.IO
import System.Random

import Utils
import Ui

foreign export ccall loadModule1 :: IO ()
foreign export ccall unloadModule1 :: IO ()


loadModule1 = do
 print "real_loadModule1"
 uiHandle <- addUi ui
 putMVar uiHandleVar uiHandle

unloadModule1 = do
 print $ "real_unloadModule1"
 uiHandle <- takeMVar uiHandleVar
 removeUi uiHandle

ui = undefined
{-
ui1 i = stackH $ do
 stack $ do
  view green
  view yellow
  width 50
--  size (50, 60)
 when (odd i) $ do
  overlap $ do
   view darkGray
   text "qwe123 fdjh giowi 9123847 ifd xx ldlkw 123yhjkh j1h23jk"
 when (even i) $ do
  overlap $ do
   view lightGray
   text "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
 stack $ do
  view red
  view cyan

ui = scroll $ stack $ do
 sequence . take 3 $ zipWith ($) (repeat ui1) [0..]
-}

{-# NOINLINE uiHandleVar #-}
uiHandleVar :: MVar UiHandle
uiHandleVar = unsafePerformIO $ newEmptyMVar
