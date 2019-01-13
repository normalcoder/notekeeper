module HsMain () where

import qualified App (run)
--import qualified LoadTester (run)

import Control.Concurrent (forkIO, threadDelay)

--import Data.Map

--import Control.Concurrent.STM
--import Control.Concurrent
--import Control.Concurrent.MVar
--import qualified ModuleStorage
import qualified ObjcMixStorage
--import qualified Terminal (run)
--import Terminal

--import ObjC
--import ObjcMsgOps
--import Foreign.Ptr

--import TestGhcWrap

foreign export ccall runHsMain :: IO ()

runHsMain = do
 --methodReplacements <- getMethodReplacements
 --appendToMethod methodReplacements (Class "UIApplication") (Selector "sendEvent:") (\_ _ args -> (print $ "123123: " ++ show args) >> return nullPtr)
 --appendToMethod methodReplacements (Class "UIApplication") (Selector "sendEvent:") (\_ _ args -> (print $ "456456: " ++ show args) >> return nullPtr)
 --print "2"
 --moduleStorage <- newTVarIO Modules.empty
 ----taskStorage <- newTVarIO Tasks.empty


 ----forkIO $ CrashSignalHandler.run moduleStorage
 --forkIO $ LoadTester.run moduleStorage
 forkIO $ q
 --moduleStorage <- ModuleStorage.create
 mixStorage <- ObjcMixStorage.create
 --forkIO $ Terminal.run moduleStorage mixStorage
 App.run mixStorage


q = do
 print 3
 threadDelay $ 10^6
 q