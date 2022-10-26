module App
( run
) where

import Objc
import Foreign.Ptr
import Foreign.C
--import View.View
import Ui

import Utils


import Control.Concurrent


foreign import ccall safe "UIApplicationMain" c_UIApplicationMain :: Int -> Ptr () -> Id -> Id -> IO ()

foreign import ccall safe "dlopen" c_dlopen :: Ptr () -> CInt -> IO (Ptr ())
foreign import ccall safe "dlclose" c_dlclose :: Ptr () -> IO CInt
foreign import ccall safe "dlsym" c_dlsym :: Ptr () -> Ptr () -> IO (FunPtr (IO ()))
-- extern void * dlsym(void * __handle, const char * __symbol) __DYLDDL_DRIVERKIT_UNAVAILABLE;

foreign import ccall "dynamic"
  mkFun :: FunPtr (IO ()) -> (IO ())

c_RTLD_LAZY = 1

appDelegateClassName = "AppDelegate"

run = do
 libFileName <- getNsString "Frameworks/libHSModule1-0.1.0.0-inplace-ghc9.5.20221014.dylib"

 forkIO $ do

  -- print $ "!!!libFileName: " ++ show libFileName
  libPath <- "UTF8String" @< ("pathForResource:ofType:", [libFileName, nullPtr]) <.@@ "mainBundle" @| "NSBundle"
  libHandle <- c_dlopen libPath c_RTLD_LAZY
  print $ "!!!libHandle: " ++ show libHandle
  loadFunName <- "UTF8String" @< getNsString "loadModule1"
  unloadFunName <- "UTF8String" @< getNsString "unloadModule1"
  loadFun <- mkFun <$> c_dlsym libHandle loadFunName
  unloadFun <- mkFun <$> c_dlsym libHandle unloadFunName

  loadFun

  threadDelay $ 10*10^6

  module1ThreadId <- loadThreadId "m1"
  print $ "!!!will unload"
  killThread module1ThreadId
  print $ "!!!killed"

  
  --unloadFun
  threadDelay $ 5*10^6
  print $ "!!!will close module"
  closeResult <- c_dlclose libHandle
  print $ "!!!closeResult: " ++ show closeResult


 --forkIO $ mapM_ (\_ -> print "!!2simple_string123422") [1..1000000]
 createAppDelegate appDelegateClassName
 c_UIApplicationMain 0 nullPtr nullPtr =<< getNsString appDelegateClassName

createAppDelegate className = do
 registerSubclass "UIResponder" className $
  [ (InstanceMethod, "application:didFinishLaunchingWithOptions:", didFinishLaunching)
  ]

didFinishLaunching _ _ _ = do
 w <- ("initWithFrame:", "bounds" #< "mainScreen" @| "UIScreen") <# "alloc" @| "UIWindow"
 ("setBackgroundColor:", "blackColor" @| "UIColor") <@. w
 ("setOpaque:", toNsBool True) <.@. w
 vc <- "new" @| "UIViewController"
 ("setRootViewController:", vc) <.@. w
 ("setBackgroundColor:", "whiteColor" @| "UIColor") <@ "view" @<. vc
 "makeKeyAndVisible" @<. w
 createUi vc
 pure $ toNsBool True
