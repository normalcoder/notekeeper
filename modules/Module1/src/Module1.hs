module Module1 () where

--import Data.IORef
--import Control.Concurrent
--import Control.Concurrent.MVar
--import GHC.IO
--import System.Random

foreign export ccall loadModule1 :: IO ()
foreign export ccall unloadModule1 :: IO ()

loadModule1 = do
 print "real_loadModule1"
 print "!!!one more print from real module123"

{-
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

-}

unloadModule1 = do
 --threadId <- takeMVar threadIdVar
 -- print $ "real_unloadModule1: " ++ show threadId
 print $ "real_unloadModule1"

{-
{-# NOINLINE threadIdVar #-}
threadIdVar :: MVar ThreadId
threadIdVar = unsafePerformIO $ newEmptyMVar
-}
