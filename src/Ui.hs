module Ui
( createUi
) where

import Control.Monad

import Objc
import UiKit
import Camera
import View.View
import View.Color
import View.Layout

ui1 i = stackH $ do
 stack $ do
  view green
  view yellow
  width 50
--  size (50, 60)
 when (odd i) $ do
  overlap $ do
   view darkGray
   text "qwe123 fdjh giowi 9123847 ifd xx ldlkw 123yhjkh j1h23jk"
 when (even i) $ do
  overlap $ do
   view lightGray
   text "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
 stack $ do
  view red
  view cyan

ui = scroll $ stack $ do
 sequence . take 3 $ zipWith ($) (repeat ui1) [0..]

--ui_ = scroll $ do
-- ui


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
