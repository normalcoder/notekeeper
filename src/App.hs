module App
( run
) where

import Objc
import Foreign.Ptr
--import View.View
import Ui


foreign import ccall safe "UIApplicationMain" c_UIApplicationMain :: Int -> Ptr () -> Id -> Id -> IO ()

appDelegateClassName = "AppDelegate"

run mixStorage = do
 createAppDelegate mixStorage appDelegateClassName
 c_UIApplicationMain 0 nullPtr nullPtr =<< getNsString appDelegateClassName

createAppDelegate mixStorage className = do
 registerSubclass "UIResponder" className $
  [ (InstanceMethod, "application:didFinishLaunchingWithOptions:", didFinishLaunching mixStorage)
  ]

didFinishLaunching mixStorage _ _ _ = do
 w <- ("initWithFrame:", "bounds" #< "mainScreen" @| "UIScreen") <# "alloc" @| "UIWindow"
 ("setBackgroundColor:", "blackColor" @| "UIColor") <@. w
 ("setOpaque:", toNsBool True) <.@. w
 vc <- "new" @| "UIViewController"
 ("setRootViewController:", vc) <.@. w
 ("setBackgroundColor:", "whiteColor" @| "UIColor") <@ "view" @<. vc
 "makeKeyAndVisible" @<. w
 createUi mixStorage vc
 pure $ toNsBool True
