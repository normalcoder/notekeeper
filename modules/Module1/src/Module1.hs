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

{-# NOINLINE funPtrVar #-}
funPtrVar :: MVar (FunPtr a)
funPtrVar = unsafePerformIO $ newEmptyMVar

{-# NOINLINE dummyVar #-}
dummyVar :: IORef Int
dummyVar = unsafePerformIO $ newIORef 1

foreign import ccall "&module1_rootView" c_module1_rootView :: Ptr Id

{-
foreign import ccall "&AVMediaTypeVideo" c_AVMediaTypeVideo :: Ptr NSString
{-# NOINLINE video #-}
video = unsafePerformIO $ peek c_AVMediaTypeVideo
-}

addNewUi ui = do
 w <- "keyWindow" @< "sharedApplication" @| "UIApplication"
 vc <- "rootViewController" @<. w
 rootView <- "view" @<. vc
 view@(View spec (Node subview@(UIView rawSubview) _)) <- build ui
 Superview rootView `addSubviewAndPin` view
 unpin rootView
 --Superview rootView `addSubview` Subview rawSubview
 --safeSetFrame (0,0,300,300) (UIView rawSubview)
 pure rawSubview


loadModule1 = do
 print "real_loadModule1"

 f <- onMainThread2 $ do
  v <- addNewUi ui
  poke c_module1_rootView v
  print $ "!!!added ptr: " ++ show v

 threadDelay $ 10^5
 freeHaskellFunPtr f
 print $ "!!!freeHaskellFunPtr 1 called"
  

 {-
 writeIORef dummyVar 2
 putMVar dummyVar 1
 r <- takeMVar dummyVar
 print $ "!!!dummy var: " ++ show r
 f <- onMainThread2 $ do
  v <- "new" @| "UIView"
  pure ()
 -}
 -- putMVar dummyVar 1
 pure ()

 -- addUi (moduleName, ui)
 {-
 onMainThreadWrap2
 onMainThreadWrap $ do
  -- uiHandle <- addUi ui
  -- saveUiHandle uiHandle
  pure ()
  -}

unloadModule1 = do
 print $ "real_unloadModule1"
 v <- peek c_module1_rootView
 print $ "!!!ptr to remove: " ++ show v
 --performGC
 --performMinorGC
 --performMajorGC
 f <- onMainThread2 $ do
  removeFromSuperview v
 threadDelay $ 10^5
 freeHaskellFunPtr f
 print $ "!!!freeHaskellFunPtr 2 called"

 pure ()
 
 {-
 r <- readIORef dummyVar
 print $ "!!!dummy var2: " ++ show r
 putMVar dummyVar 100
 print $ "!!!written to dummy var 100"
 r <- takeMVar dummyVar
 print $ "!!!dummy var2: " ++ show r
 r <- takeMVar dummyVar
 print $ "!!!dummy var: " ++ show r
 f <- takeMVar funPtrVar
 print $ "var taken"
 freeHaskellFunPtr f
 print $ "!!!freeHaskellFunPtr done"
 -}
 -- removeUi moduleName

 -- onMainThread $ do
  -- Just uiHandle <- loadUiHandle
  -- removeUi uiHandle

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
