module View.Image
( UIImage(..)
, Aspect(..)
) where

import ObjcTypes

newtype UIImage = UIImage { _rawUiImage :: Id }

data Aspect = Fit | Fill | Scale | Center
