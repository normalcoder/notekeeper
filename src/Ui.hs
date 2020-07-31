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
5. Open note from notes grid
6. Add tag
7. Delete tag
8. Delete note
9. Assign tag to note

-}

createUi :: Id -> IO ()
createUi vc = do
 rootView <- "view" @<. vc
 createCameraUi rootView
