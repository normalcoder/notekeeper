module App
( run
) where

import Foreign.Ptr
import ObjcTypes
import ObjcMsg
import ObjcMsgHelpers
import ObjcMsgSt
import ObjcMsgOps
import ObjcHelpers
import ObjcClassManipulations
--import Ui

import Control.Concurrent
import Foreign.Marshal.Alloc

foreign import ccall safe "UIApplicationMain" c_UIApplicationMain :: Int -> Ptr () -> Id -> Id -> IO ()

appDelegateClassName = "AppDelegate"

run mixStorage = do
 createAppDelegate mixStorage appDelegateClassName
 getNsString appDelegateClassName >>= c_UIApplicationMain 0 nullPtr nullPtr

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
 "makeKeyAndVisible" @<. w
 ("setBackgroundColor:", "greenColor" @| "UIColor") <@ "view" @<. vc
 --"removeFromSuperview" @< "view" @< "rootViewController" @<. w

-- createUi mixStorage w

 return nullPtr
