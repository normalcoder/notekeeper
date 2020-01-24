module Ui
( createUi
) where

import Objc
import UiKit
import Camera

createUi :: Id -> IO ()
createUi vc = do
 rootView <- "view" @<. vc
 createCameraUi rootView
