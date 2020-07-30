module Ui
( createUi
) where

import Objc
import UiKit
import Camera

{-

note = picture

1. List tags
 - show list
  -- describe view
   --- describe model
  -- make list
 - local persistent
 - sync with server (download/upload)
2. Select active tag

3. Take note with some tag
4. Open notes with tag
5. Add tag
6. Delete tag
7. Delete note
8. Assign tag to note

-}

createUi :: Id -> IO ()
createUi vc = do
 rootView <- "view" @<. vc
 createCameraUi rootView
