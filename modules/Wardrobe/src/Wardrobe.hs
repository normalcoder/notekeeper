module Wardrobe () where

import Data.IORef
import Control.Concurrent
import Control.Concurrent.MVar
import GHC.IO
--import System.Random

import Foreign.Ptr
import Foreign
import Foreign.StablePtr
import System.Mem

import Utils

import Objc
import Ui
import Gcd
import View.View
import UiKit

foreign export ccall loadWardrobe :: IO ()
foreign export ccall unloadWardrobe :: IO ()

moduleName = "Wardrobe"

addNewUi ui = do
 w <- "keyWindow" @< "sharedApplication" @| "UIApplication"
 vc <- "rootViewController" @<. w
 rootView <- "view" @<. vc
 view@(View spec (Node subview@(UIView rawSubview) _)) <- build ui
 Superview rootView `addSubviewAndPin` view
 pure rawSubview

{-
data WardrobeData = WardrobeDataInt Int | WardrobeDataFunc (Int -> Int)
data WardrobeData1 = WardrobeDataInt1 Int Int | WardrobeDataFunc1 (Int -> Int)
-}

loadWardrobe = do
 print "loadWardrobe"

{-
 let
{-
  dataBuilder d = case d of
   WardrobeDataInt x -> WardrobeDataInt (x + 1000)
   WardrobeDataFunc f -> WardrobeDataFunc (f . (+2000))
-}
  dataBuilder d = case d of
   WardrobeDataInt x -> WardrobeDataInt1 (x + 1000) (x + 4000)
   WardrobeDataFunc f -> WardrobeDataFunc1 ((+2000) . f)
 -- let f1Builder x = 11 :: Int

 dataBuilderPtr <- newStablePtr dataBuilder
 let simpleDataBuilderPtr = castStablePtrToPtr dataBuilderPtr
 print $ "!!!simpleDataBuilderPtr: " ++ show simpleDataBuilderPtr


 let newDataBuilderPtr = castPtrToStablePtr simpleDataBuilderPtr
 newDataBuilder <- deRefStablePtr newDataBuilderPtr
 -- let newData = newDataBuilder (WardrobeDataInt 15)
 let newData = newDataBuilder (WardrobeDataFunc (*11))
 case newData of
  WardrobeDataInt x -> print $ "it was WardrobeDataInt with x = " ++ show x
  WardrobeDataFunc f -> print $ "it was WardrobeDataFunc with f which does f(5) = " ++ show (f 5)

 freeStablePtr dataBuilderPtr
-}
 onMainThread $ do
  v <- addNewUi ui
  saveView v

unloadWardrobe = do
 print $ "unloadWardrobe"
 v <- loadView
 onMainThreadSync $ do
  unpinAndRemoveFromSuperview v

{-
--------
setUiPtr moduleName uiPtr = do
 insert storageMap moduleName uiPtr

getUiPtr moduleName = do
 uiPtr <- lookup storageMap moduleName
 pure uiPtr


-------
let moduleName = "ClothingView"

loadClothingView = do
 uiStablePtr <- newStablePtr ui -- ui accepts viewParams
 let uiPtr = castStablePtrToPtr uiStablePtr
 setUiPtr moduleName uiPtr -- notifies all ClothingView users, and forces them to rebuild ClothingView ui part

unloadClothingView = do
 freeSpecStablePtr moduleName
 


-------
let moduleName = "Wardrobe"

boots viewParams = do
 dynSpec "ClothingView" viewParams

dynSpec moduleName viewParams = do
 when (not $ libLoaded moduleName) $ do
  unload <- loadLib moduleName
  setLibLoadedAndSaveUnload moduleName unload
 uiPtr <- getUiPtr moduleName
 ui <- deRefStablePtr (castPtrToStablePtr uiPtr :: (StablePtr (ViewParams -> ViewSpec q))
 pure $ ui viewParams

 !when all uses of ui are removed then unload lib
 -}
 

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
  --boots
  view cyan

ui = scroll $ stack $ do
 sequence . take 3 $ zipWith ($) (repeat ui1) [0..]
