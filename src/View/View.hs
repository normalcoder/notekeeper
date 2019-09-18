{-# language ScopedTypeVariables #-}

module View.View
( ViewSpec
, View
, Subviews(..)
, IsVertical(..)
-- , IsVertical(..)
, build
, rootUiView
, v1Spec
) where

import Control.Monad

import Objc
import View.Label
import View.Image
import View.Color

import UiKit

import Prelude hiding (Left, Right)

-- ViewSpecWithModel
-- Screen


newtype ViewSpec = ViewSpec (V ())
newtype View = View (V UIView)
unview (View v) = v

newtype UIView = UIView { _uiView :: Id }

data V a = V {
 _view :: a,
 _kind :: Kind a,
 _color :: Color,
 _padding :: Padding,
 _transform :: Transform3D,
 _priority :: Priority,
 -- _constraints :: Constraints,
 -- _intrinsicSize :: IntrinsicSize,
 -- _subviews :: (Subviews a),
 _isScreen :: IsScreen,
 _pathComps :: [PathComp]
}

-- data Subviews a = Subviews Insets IsVertical [V a]
-- data Subviews a = Subviews Direction [V a]



newtype Tags = Tags { _tags :: [Tag] }
data Tag = Tag { _title :: Title, _images :: [Image] }






tags = list _tags $ do
 -- withList _tags
 tag

tag = stackH $ do
 title ^ do
  with _title
 overlap ^ do
  withElems (take 8 . _images) $ \i -> do 
   image ^ do
    rotate $ [30, 60, 15] !! i
 onTap $ do
  open tagDetails
  openAutoMatch tagDetails ^ do
   transition1
   transition2
   ...
  openMatchById tagDetails ^ do
   transition1 "view1"
   transition2 "view2"
   ...

open:
 vs = old screen views
 ws = new screen views
 common = vs /\ ws -- find match for common
 addSubviews common to new screen (remove from old) + add (ws - common)
 animate forward ws + animate show new background

close:
 vs = old screen views
 ws = new screen views
 common = vs /\ ws -- find match for common
 addSubviews common to old screen (remove from new) + ...
 animate backward ws + animate hide new background



common



tagDetails = stack $ do
 title ^ do
  with _title
 grid _images ^ do
  image 
 


-- expand = do


   -- mapM (\(x,i) -> image & withIndex i >> rotate x) $ zip [30, 60, 15] [0..]


  --  image & rotate 30
  --  image & rotate 60
  --  image & rotate 15

  -- expandingStackH $ do
   

-- cell = do
--  stackH $ do
--   image $ pure ()
--   stack $ do
--    title $ pure ()
--    stackH $ do
--     subtitle $ pure ()
--     year $ do
--      priority 1

data Kind a =
   Container (Maybe Tappable) Direction [V a]
 | Label Font (Maybe LineCount) BreakMode (IO String)
 | Image (Maybe (Width, Height)) Aspect (IO UIImage)

data Tappable = Tappable (IO ())

newtype PathComp = PathComp String

data Direction = Vertical | Horizontal | Overlap
data IsScreen = Screen | NotScreen

data Insets = Insets Left Right Top Bottom
newtype Left = Left CGFloat
newtype Right = Right CGFloat
newtype Top = Top CGFloat
newtype Bottom = Bottom CGFloat


newtype Priority = Priority Double
data Padding = Padding (Maybe Left) (Maybe Right) (Maybe Top) (Maybe Bottom)
data Constraints = Constraints (Maybe MinWidth) (Maybe MaxWidth) (Maybe MinHeight) (Maybe MaxHeight)
data IntrinsicSize = IntrinsicSize (Maybe Width) (Maybe Height)
newtype Width = Width CGFloat
newtype Height = Height CGFloat
newtype MinWidth = MinWidth CGFloat
newtype MaxWidth = MaxWidth CGFloat
newtype MinHeight = MinHeight CGFloat
newtype MaxHeight = MaxHeight CGFloat

-- check = undefined
v1Spec = do
 ViewSpec $ V ()
  Container
  red
  (Constraints Nothing Nothing Nothing Nothing)
  (IntrinsicSize Nothing Nothing)
  (Priority 1)
  (Offset 0 0)
  (Subviews
   (Insets (Left 0) (Right 0) (Top 0) (Bottom 0))
   Vertical
   [s1, s2])
  Screen
  []

s1 = do
 V ()
  Container
  green
  (Constraints Nothing Nothing Nothing Nothing)
  (IntrinsicSize Nothing Nothing)
  (Priority 1)
  (Offset 0 0)
  (Subviews
   (Insets (Left 0) (Right 0) (Top 0) (Bottom 0))
   Vertical
   [])
  Screen
  []

s2 = do
 V ()
  Container
  blue
  (Constraints Nothing Nothing Nothing Nothing)
  (IntrinsicSize Nothing Nothing)
  (Priority 1)
  (Offset 0 0)
  (Subviews
   (Insets (Left 0) (Right 0) (Top 0) (Bottom 0))
   Vertical
   [])
  Screen
  []

build :: ViewSpec -> IO View
build (ViewSpec (V _ k color constr intrSize (Subviews insets isVertical subviewSpecs) isScreen pathComps)) = do

 v <- "new" @| "UIView"
 ("setBackgroundColor:", uiColor color) <@. v
 subviews <- traverse (pure . unview <=< build . ViewSpec) subviewSpecs

 mapM_ (addSubview (Superview v) . Subview . _uiView . _view) subviews

 pure $ View $ V (UIView v) k color constr intrSize (Subviews insets isVertical subviews) isScreen pathComps

rootUiView (View v) = _uiView . _view $ v
 -- subviews' <- pure . Subviews insets isVertical $ mapM (pure . unview =<< build . map ViewSpec) subviews
 -- pure $ View $ V (UIView v) k color constr subviews' isScreen pathComps

-- layout :: View -> IO ()
-- layout (View (V v k color constr subveiws)) = case k of
--  Container -> 
