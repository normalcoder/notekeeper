module View.Image
( UIImage(..)
, Aspect(..)
) where

import ObjcTypes

newtype UIImage = UIImage Id

data Aspect = Fit | Fill | Scale | Center
