module App
( run
) where

import Objc
import Foreign.Ptr
--import View.View

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

createUi mixStorage vc = do
 t <- "new" @| "UITableView"
 v <- "view" @<. vc
 ("setFrame:", "bounds" #<. v) <#. t
 ("addSubview:", t) <.@. v
 d <- mkDataSource
 ("setDataSource:", d) <.@. t

mkDataSource = do
 let c = "TagsTableViewDataSource"
 registerSubclass "NSObject" c $
  [ (InstanceMethod, "tableView:numberOfRowsInSection:", numberOfRows)
  , (InstanceMethod, "tableView:cellForRowAtIndexPath:", cellForRow)
  ]
 "new" @| c

numberOfRows _ _ _ = do
 pure $ toNsInteger 1

cellForRow _ _ _ = do
 c <- "new" @| "UITableViewCell"
 ("setText:", getNsString "123") <@ "textLabel" @<. c
 pure c



----storage

--data Storage =
-- Storage
-- { _tags :: Vector Tag
-- , _images :: Map Tag (Vector Image)
-- }

--data Image =
-- Image
-- { _file :: File
-- , _done :: Bool
-- }

--newtype File = File String
