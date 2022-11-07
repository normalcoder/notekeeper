module ClothingList () where

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

addNewUi ui = do
 w <- "keyWindow" @< "sharedApplication" @| "UIApplication"
 vc <- "rootViewController" @<. w
 rootView <- "view" @<. vc
 view@(View spec (Node subview@(UIView rawSubview) _)) <- build ui
 Superview rootView `addSubviewAndPin` view
 pure rawSubview


loadModule1 = do
 print "loadModule1"
 onMainThread $ do
  v <- addNewUi ui
  saveView v

unloadModule1 = do
 print $ "unloadModule1"
 v <- loadView
 onMainThreadSync $ do
  unpinAndRemoveFromSuperview v

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
