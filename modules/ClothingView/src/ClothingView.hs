module ClothingView () where

import Data.IORef
import Control.Concurrent
import Control.Concurrent.MVar
import GHC.IO
--import System.Random

import Foreign.Ptr
import Foreign
import System.Mem

import Utils

import Objc
import Ui
import Gcd
import View.View
import UiKit

foreign export ccall loadClothingView :: IO ()
foreign export ccall unloadClothingView :: IO ()

moduleName = "ClothingView"

addNewUi ui = do
 w <- "keyWindow" @< "sharedApplication" @| "UIApplication"
 vc <- "rootViewController" @<. w
 rootView <- "view" @<. vc
 view@(View spec (Node subview@(UIView rawSubview) _)) <- build ui
 Superview rootView `addSubviewAndPin` view
 pure rawSubview


loadClothingView = do
 print "loadClothingView"
 onMainThread $ do
  v <- addNewUi ui
  saveView v

unloadClothingView = do
 print $ "unloadClothingView"
 v <- loadView
 onMainThreadSync $ do
  unpinAndRemoveFromSuperview v

boots = undefined

ui1 i = stackH $ do
 stack $ do
  view yellow
  view green
 when (odd i) $ do
  overlap $ do
   view darkGray
   text moduleName
 stack $ do
  view red
  -- boots
  view cyan

ui = scroll $ stack $ do
 sequence . take 3 $ zipWith ($) (repeat ui1) [0..]
