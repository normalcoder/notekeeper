module HsMain () where

import qualified App
import qualified ObjcMixStorage as Mix
import ObjcMsgOps
import Foreign.Ptr
import Foreign.C


--import qualified LoadTester (run)

--import Control.Concurrent (forkIO)

--import Data.Map

--import Control.Concurrent.STM
--import Control.Concurrent
--import Control.Concurrent.MVar

--import ObjC
--import ObjcMsgOps
--import Foreign.Ptr

--import TestGhcWrap

foreign export ccall runHsMain :: CInt -> Ptr() -> IO ()

runHsMain argc argv = do
 --methodReplacements <- getMethodReplacements
 --appendToMethod methodReplacements (Class "UIApplication") (Selector "sendEvent:") (\_ _ args -> (print $ "123123: " ++ show args) >> return nullPtr)
 --appendToMethod methodReplacements (Class "UIApplication") (Selector "sendEvent:") (\_ _ args -> (print $ "456456: " ++ show args) >> return nullPtr)
 --print "2"
 --moduleStorage <- newTVarIO Modules.empty
 ----taskStorage <- newTVarIO Tasks.empty


 ----forkIO $ CrashSignalHandler.run moduleStorage
 --forkIO $ LoadTester.run moduleStorage

 App.run argc argv =<< Mix.create

