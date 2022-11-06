module UiKit
( mkUiView
, UIView(..)
, UIScrollView(..)
, addSubview
, addSubview'
, removeFromSuperview
, superview
, safeSetFrame
, setContentSize
, Rect
, Subview(..)
, Superview(..)
, module UiKitHelpers
) where


import GHC.Generics
import Control.DeepSeq

import Objc
import UiKitHelpers

newtype UIView = UIView { _rawUiView :: Id } deriving (Generic, NFData, Show)
newtype UIScrollView = UIScrollView UIView deriving (Generic, NFData, Show)
-- newtype UiView = UiView Id
newtype Subview = Subview Id deriving (Show, Generic, NFData)
newtype Superview = Superview Id deriving (Show, Generic, NFData)


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

removeFromSuperview view = do
 "removeFromSuperview" @<. view
 pure ()

superview view = do
 "superview" @<. view

setContentSize size (UIScrollView (UIView v)) = do
 ("setContentSize:", size) <.%. v
 pure ()
