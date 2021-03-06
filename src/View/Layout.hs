module View.Layout
( addSubviewAndPin
) where

import Control.Monad

import Objc
import UiKitHelpers
import UiKit
import View.View

addSubviewAndPin v@(Superview superview) subviewDef@(View spec (ViewTree subview@(UIView rawSubview) _)) = do
 addSubview v (Subview rawSubview)
 setFrameToBounds
 mixAfter superview "layoutSubviews" $ NoRet $ \_ _ _ -> setFrameToBounds
 where
  setFrameToBounds = do
   f@(x,y,w,h) <- "bounds" #<. superview
   when (not . isContainer $ _kind spec) $ do
    safeSetFrame f subview
   layoutSubviews ((w,h), subviewDef)

layoutSubviews ((w,h), View spec (ViewTree view subviews)) = do
 case _kind spec of
  Container _ d specImpls -> do
   sizes <- traverse layoutView $ zip3 [0..] specImpls subviews
   traverse layoutSubviews $ zip sizes $ zipWith View specImpls subviews
   pure ()
   where
   layoutView (i, viewSpec, (ViewTree v _)) = do
    safeSetFrame (x, y, width, height) v
    pure (width, height)
    where
    x = if horizontal then fromIntegral i * width else 0
    y = if vertical then fromIntegral i * height else 0
   width = if horizontal then w / fromIntegral n else w
   height = if vertical then h / fromIntegral n else h
   horizontal = d == Horizontal
   vertical = d == Vertical
  Scroll specImpl -> do
   let subviewInTree@(ViewTree subview _) = head subviews
   safeSetFrame (0, 0, w, h) subview
   setContentSize (0, 1000) (UIScrollView view)
   layoutSubviews ((w,h), View specImpl subviewInTree)
   pure ()

  _ -> pure ()
 where
 n = length subviews
