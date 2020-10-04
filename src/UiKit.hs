module UiKit
( mkUiView
, UIView(..)
, addSubview
, addSubview'
, safeSetFrame
, Rect
, Subview(..)
, Superview(..)
, module UiKitHelpers
) where

import Objc
import UiKitHelpers

newtype UIView = UIView { _rawUiView :: Id } deriving (Show)
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

safeSetFrame (x, y, w, h) (UIView v) = do
 ("setBounds:", (0, 0, w, h)) <.#. v
 ("setCenter:", (x + w/2, y + h/2)) <.%. v
 pure ()

addSubview (Superview superview) (Subview subview) = do
 ("addSubview:", subview) <.@. superview
 pure ()
