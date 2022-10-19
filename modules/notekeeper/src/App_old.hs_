module App
( run
) where

import Foreign.Ptr
import Foreign.C
import ObjcTypes
import ObjcMsg
import ObjcMsgHelpers
import ObjcMsgSt
import ObjcMsgOps
import ObjcHelpers
import ObjcClassManipulations

import Window
import Menu
import Ui

import Control.Concurrent
import Foreign.Marshal.Alloc

foreign import ccall safe "NSApplicationMain" c_NSApplicationMain :: CInt -> Ptr () -> IO ()

appDelegateClassName = "AppDelegate"

run argc argv mix = do
 createAppDelegate mix appDelegateClassName
 ("setDelegate:", "new" @| appDelegateClassName) <@ "sharedApplication" @| "NSApplication"
 c_NSApplicationMain argc argv

createAppDelegate mix className = do
 registerSubclass "NSObject" className $
  [ (InstanceMethod, "applicationDidFinishLaunching:", didFinishLaunching mix)
  , (InstanceMethod, "applicationWillTerminate:", \_ _ _ -> pure nullPtr)
  , (InstanceMethod, "applicationShouldTerminateAfterLastWindowClosed:", \_ _ _ -> pure $ ptrInt 1)
  ]

didFinishLaunching mixStorage _ _ _ = do
 setupMenu
 v <- setupWindow
 createUi v
 pure nullPtr

