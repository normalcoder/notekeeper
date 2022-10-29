module CheckLoading
( checkLoading
) where

import Objc
import Foreign.Ptr
import Foreign.C
--import View.View
import Ui

--import Utils

import Control.Concurrent


foreign import ccall safe "dlopen" c_dlopen :: Ptr () -> CInt -> IO (Ptr ())
foreign import ccall safe "dlclose" c_dlclose :: Ptr () -> IO CInt
foreign import ccall safe "dlsym" c_dlsym :: Ptr () -> Ptr () -> IO (FunPtr (IO ()))
-- extern void * dlsym(void * __handle, const char * __symbol) __DYLDDL_DRIVERKIT_UNAVAILABLE;

c_RTLD_LAZY = 1

foreign import ccall "dynamic"
  mkFun :: FunPtr (IO ()) -> (IO ())

checkLoading = forkIO $ do
 pause
 (unloadLib1, libHandle1) <- loadLib moduleName1
 pause
 unloadLib1
 pause
 closeLib libHandle1

 pause

 (unloadLib2, libHandle2) <- loadLib moduleName2
 pause
 unloadLib2
 pause
 closeLib libHandle2

pause = threadDelay $ 2*10^6

moduleName1 = "Module1"
moduleName2 = "Module2"
moduleName3 = "Module3"

libName moduleName = "libHS" ++ moduleName ++ "-0.1.0.0-inplace-ghc9.5.20221014"

loadLib moduleName = do
 libFileName <- getNsString $ "Frameworks/" ++ (libName moduleName) ++ ".dylib"
 libPath <- "UTF8String" @< ("pathForResource:ofType:", [libFileName, nullPtr]) <.@@ "mainBundle" @| "NSBundle"
 libHandle <- c_dlopen libPath c_RTLD_LAZY
 print $ "!!!libHandle, " ++ moduleName ++ ": " ++ show libHandle
 loadFunName <- "UTF8String" @< getNsString ("load" ++ moduleName)
 unloadFunName <- "UTF8String" @< getNsString ("unload" ++ moduleName)
 loadFun <- mkFun <$> c_dlsym libHandle loadFunName
 unloadFun <- mkFun <$> c_dlsym libHandle unloadFunName
 
 loadFun

 pure (unloadFun, libHandle)

closeLib libHandle = do
 closeResult <- c_dlclose libHandle
 print $ "!!!closeResult: " ++ show closeResult
