module Utils (
  saveView,
  loadView,
  saveThreadId,
  loadThreadId,
  saveUiHandle,
  loadUiHandle,
  onMainThreadWrap,
  onMainThreadWrap2
) where

import Data.IORef
import Control.Concurrent
import Control.Concurrent.MVar
import GHC.IO
import System.Random

import Objc
import Ui

import Gcd

onMainThreadWrap act = do
 onMainThread act

onMainThreadWrap2 = do
 forkIO $ do
  onMainThread $ print "action in main"
 pure ()


saveView view = do
 putMVar viewVar view

loadView = do
 view <- takeMVar viewVar
 pure view


saveUiHandle uiHandle = do
 print $ "!!saving uiHandle" ++ show uiHandle
 writeIORef uiHandleVar (Just uiHandle)
 print $ "!!saved"

loadUiHandle = do
 print "!!!loading uiHandle..."
 uiHandle <- readIORef uiHandleVar
 writeIORef uiHandleVar Nothing
 print "!!!removed uiHandle"
 pure uiHandle

saveThreadId key threadId = do
 print $ "!!saving threadId" ++ show threadId
 writeIORef threadIdVar (Just threadId)
 savedThreadId <- loadThreadId key
 print $ "!!savedThreadId" ++ show savedThreadId


loadThreadId key = do
 print "!!!loading threadId..."
 Just threadId <- readIORef threadIdVar
 pure threadId


{-

foreign export ccall loadModule1 :: IO ()
foreign export ccall unloadModule1 :: IO ()

loadModule1 = do
 print "real_loadModule1"
 print "!!!one more print from real module123"

 threadId <- forkIO q
 putMVar threadIdVar threadId
 forkIO $ do
  x <- getX
  print $ "qqqq:" ++ show x

getXs _ = [1..]

getX = do
 r <- randomRIO (1, 10)
 pure $ (getXs 0) !! ((3*10^7) + r)

q = do
 x <- getX
 print $ "qwe: " ++ (show x)
 q

unloadModule1 = do
 threadId <- takeMVar threadIdVar
  print $ "real_unloadModule1: " ++ show threadId
 print $ "real_unloadModule1"

-}

{-# NOINLINE uiHandleVar #-}
uiHandleVar :: IORef (Maybe UiHandle)
uiHandleVar = unsafePerformIO $ newIORef Nothing

{-# NOINLINE threadIdVar #-}
threadIdVar :: IORef (Maybe ThreadId)
threadIdVar = unsafePerformIO $ newIORef Nothing

{-# NOINLINE viewVar #-}
viewVar :: MVar Id
viewVar = unsafePerformIO $ newEmptyMVar
