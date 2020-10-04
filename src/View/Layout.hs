module View.Layout
( addSubviewAndPin
) where

import Objc
import UiKitHelpers
import UiKit
import View.View

addSubviewAndPin v@(Superview superview) subviewDef@(View _ (ViewTree (UIView subview) _)) = do
 addSubview v (Subview subview)
 setFrameToBounds
 mixAfter superview "layoutSubviews" $ NoRet $ \_ _ _ -> setFrameToBounds
 where
  setFrameToBounds = do
   -- ("setFrame:", ("bounds" #<. superview)) <#. subview
   (x,y,w,h) <- "bounds" #<. superview
   ("setBounds:", (0, 0, w, h)) <.#. subview
   ("setCenter:", (x + w/2, y + h/2)) <.%. subview
   layoutSubviews ((w,h), subviewDef)

layoutSubviews :: ((CGFloat, CGFloat), View) -> IO ()
layoutSubviews ((w,h), View spec (ViewTree view subviews)) = do
 case _kind spec of
  Container _ d specImpls -> do
   sizes <- traverse layoutView $ zip3 [0..] specImpls subviews
   traverse layoutSubviews $ zip sizes $ zipWith View specImpls subviews
   pure ()
   where
   layoutView (i, viewSpec, (ViewTree v _)) = do
    setFrame (x, y, width, height) v
    pure (width, height)
    where
    x = if horizontal then fromIntegral i * width else 0
    y = if vertical then fromIntegral i * height else 0
   width = if horizontal then w / fromIntegral n else w
   height = if vertical then h / fromIntegral n else h
   horizontal = d == Horizontal
   vertical = d == Vertical
  _ -> pure ()
 where
 n = length subviews
