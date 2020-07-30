module App
( run
) where

import Objc
import Foreign.Ptr
--import View.View
import Ui

import Control.Concurrent


foreign import ccall safe "UIApplicationMain" c_UIApplicationMain :: Int -> Ptr () -> Id -> Id -> IO ()

appDelegateClassName = "AppDelegate"

run = do
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
