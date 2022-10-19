module View.Image
( UIImage(..)
, Aspect(..)
) where

import ObjcTypes

newtype UIImage = UIImage { _rawUiImage :: Id } deriving (Show)

data Aspect = Fit | Fill | Scale | Center deriving (Show)
