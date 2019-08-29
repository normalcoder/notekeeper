{-# language ScopedTypeVariables #-}

module View.View
( ViewSpec
, View
, Subviews(..)
, IsVertical(..)
-- , IsVertical(..)
, check
) where

import Control.Monad

import Objc
import View.Label
import View.Image
import View.Color

-- ViewSpecWithModel
-- Screen


newtype ViewSpec = ViewSpec (V ())
newtype View = View (V UIView)
unview (View v) = v

newtype UIView = UIView Id

data V a = V a Kind Color Constraints (Subviews a) IsScreen [PathComp]
data Subviews a = Subviews Insets IsVertical [V a]

newtype PathComp = PathComp String

data IsVertical = Vertical | Horizontal
data IsScreen = Screen | NotScreen

data Insets = Insets Left Right Top Bottom
newtype Left = Left CGFloat
newtype Right = Right CGFloat
newtype Top = Top CGFloat
newtype Bottom = Bottom CGFloat

data Constraints = Constraints (Maybe MinWidth) (Maybe MaxWidth) (Maybe MinHeight) (Maybe MaxHeight)
newtype MinWidth = MinWidth CGFloat
newtype MaxWidth = MaxWidth CGFloat
newtype MinHeight = MinHeight CGFloat
newtype MaxHeight = MaxHeight CGFloat

data Kind =
   Container
 | Label Font LineCount BreakMode (IO String)
 | Image Aspect (IO UIImage)
 | Button (IO ())

check = undefined
-- check = do
--  build $ ViewSpec $ V () Container (Constraints (Maybe MinWidth) (Maybe MaxWidth) (Maybe MinHeight) (Maybe MaxHeight))

build :: ViewSpec -> IO View
build (ViewSpec (V _ k color constr (Subviews insets isVertical subviews) isScreen pathComps)) = do
 v <- "new" @| "UIView"
 subviews <- traverse (pure . unview <=< build . ViewSpec) subviews
 pure $ View $ V (UIView v) k color constr (Subviews insets isVertical subviews) isScreen pathComps

 -- subviews' <- pure . Subviews insets isVertical $ mapM (pure . unview =<< build . map ViewSpec) subviews
 -- pure $ View $ V (UIView v) k color constr subviews' isScreen pathComps

-- layout :: View -> IO ()
-- layout (View (V v k color constr subveiws)) = case k of
--  Container -> 
