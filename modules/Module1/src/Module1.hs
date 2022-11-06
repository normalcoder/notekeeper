{-# language GHC2021 #-}

module Module1 () where

import Data.IORef
import Control.Concurrent
import Control.Concurrent.MVar
import GHC.IO
import System.Random

import Foreign.Ptr
import Foreign
import System.Mem

import Utils

import Objc
import Ui
import Gcd
import View.View
import UiKit

foreign export ccall loadModule1 :: IO ()
foreign export ccall unloadModule1 :: IO ()

moduleName = "Module1"

foreign import ccall "&module1_rootView" c_module1_rootView :: Ptr Id

addNewUi ui = do
 w <- "keyWindow" @< "sharedApplication" @| "UIApplication"
 vc <- "rootViewController" @<. w
 rootView <- "view" @<. vc
 view@(View spec (Node subview@(UIView rawSubview) _)) <- build ui
 Superview rootView `addSubviewAndPin` view
 unpin rootView
 pure rawSubview

loadModule1 = do
 print "real_loadModule1"

 onMainThread3 $ do
  v <- addNewUi ui
  -- poke c_module1_rootView v
  saveView v
  print $ "!!!added ptr: " ++ show v

 -- threadDelay $ 10^5
 -- freeHaskellFunPtr f
 print $ "!!!freeHaskellFunPtr 1 called"

unloadModule1 = do
 print $ "real_unloadModule1"
 -- v <- peek c_module1_rootView
 v <- loadView
 print $ "!!!ptr to remove: " ++ show v

 finishedVar <- newEmptyMVar
 onMainThread3 $ do
  removeFromSuperview v
  putMVar finishedVar True
 -- threadDelay $ 10^5
 -- freeHaskellFunPtr f

 _ <- takeMVar finishedVar
 print $ "!!!freeHaskellFunPtr 2 called"

ui1 i = stackH $ do
 stack $ do
  view yellow
  view green
  width 50
 when (odd i) $ do
  overlap $ do
   view darkGray
   text "module 1"
 stack $ do
  view red
  view cyan

ui = scroll $ stack $ do
 sequence . take 3 $ zipWith ($) (repeat ui1) [0..]
