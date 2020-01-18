module UiKit
( mkUiView
, addSubview
, addSubview'
, addSubviewAndPin
, Rect
, Subview(..)
, Superview(..)
) where

import Objc

-- newtype UiView = UiView Id
newtype Subview = Subview Id
newtype Superview = Superview Id


type Rect = (CGFloat, CGFloat, CGFloat, CGFloat)


mkUiView = do
 v <- "new" @| "UIView"
 pure v


addSubview' :: Superview -> Subview -> (Rect -> Rect) -> IO ()
addSubview' (Superview superview) (Subview subview) calcFrame = do
 -- ("setFrame:", calcFrame <$> ("bounds" #<. superview)) <#. view
 (x,y,w,h) <- calcFrame <$> ("bounds" #<. superview)
 ("setBounds:", (0, 0, w, h)) <.#. subview
 ("setCenter:", (x + w/2, y + h/2)) <.%. subview
 -- mixAfter mixStorage superview "layoutSubviews" $ NoRet $ \_ _ _ -> do
 --  ("setFrame:", calcFrame <$> ("bounds" #<. superview)) <#. view
 --  pure ()
 ("addSubview:", subview) <.@. superview
 pure ()

addSubviewAndPin v@(Superview superview) w@(Subview subview) = do
 addSubview v w
 setFrameToBounds
 mixAfter superview "layoutSubviews" $ NoRet $ \_ _ _ -> setFrameToBounds
 where
  setFrameToBounds = do
   -- ("setFrame:", ("bounds" #<. superview)) <#. subview
   (x,y,w,h) <- "bounds" #<. superview
   ("setBounds:", (0, 0, w, h)) <.#. subview
   ("setCenter:", (x + w/2, y + h/2)) <.%. subview
   pure ()

addSubview (Superview superview) (Subview subview) = do
 ("addSubview:", subview) <.@. superview
 pure ()
