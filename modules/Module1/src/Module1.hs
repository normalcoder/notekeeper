{-# language GHC2021 #-}

module Module1 () where

import Data.IORef
import Control.Concurrent
import Control.Concurrent.MVar
import GHC.IO
import System.Random

import Utils

foreign export ccall loadModule1 :: IO ()
foreign export ccall unloadModule1 :: IO ()


loadModule1 = do
 print "real_loadModule1"
 print "!!!one more print from real module123"

 threadId <- forkIO q

 -- putMVar threadIdVar threadId
 saveThreadId "m1" threadId
 
 print "!!thread started"
{-
getXs _ = [(1 :: Integer)..]

getX = do
 (r :: Int) <- randomRIO (1, 10)
 pure $ (getXs 0) !! ((3*10^7) + r) :: IO Integer
-}
q = do
-- x <- getX
-- print $ "qwe: " ++ (show x)
 threadDelay $ 10^6
 print "1"
 q

unloadModule1 = do
 print "!!!will get thread id"
 threadId <- loadThreadId "m1"
 print $ "!!!got thread id" ++ show threadId
 killThread threadId
 print "!!!killed from module"
 --threadId <- takeMVar threadIdVar
 -- print $ "real_unloadModule1: " ++ show threadId
 -- print $ "real_unloadModule1"
