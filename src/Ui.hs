module Ui
( createUi
) where

import Objc
import UiKit
import Camera
import View.View
import View.Color
import View.Layout

ui1 = stack $ do
 stackH $ do
  view green
  view yellow
 stackH $ do
  view red
  view cyan

ui = stackH $ do
 sequence $ replicate 10 ui1


createUi :: Id -> IO ()
createUi vc = do
 rootView <- "view" @<. vc

-- camera <- createCameraUi
-- Superview rootView `addSubviewAndPin` Subview camera

 -- v <- _rawUiView . _uiView <$> build ui
 -- Superview rootView `addSubviewAndPin` Subview v
 view <- build ui
 Superview rootView `addSubviewAndPin` view
 pure ()


{-
 view <- build ui

 stack $ do
  view yellow
  view red
  stackH $ do
   view brown
   view cyan

  text "title"
  text "subtitle"
-}
 -- v <- build $ do
 --  stack $ do
 --   text "title"
 --   text "subtitle"

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
