module View.View
( ViewSpec
, View
-- , Subviews(..)
-- , IsVertical(..)
-- , IsVertical(..)
) where

import ObjcMsgSt
import View.Label
import View.Image
import View.Color

newtype ViewSpec = ViewSpec (V ())
newtype View = View (V UIView)

data V a = V a Kind Color Constraints (Subviews a)
data Subviews a = Subviews Insets IsVertical [V a]

data IsVertical = Vertical | Horizontal

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



build :: ViewSpec -> View
build (ViewSpec (V k color constr)) = 


layout :: View -> IO ()
layout (View (V v k color constr subveiws)) = case k of
 Container -> 
