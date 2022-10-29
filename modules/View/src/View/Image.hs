{-# language DeriveAnyClass, DerivingStrategies #-}

module View.Image
( UIImage(..)
, Aspect(..)
) where

import GHC.Generics
import Control.DeepSeq

import ObjcTypes

newtype UIImage = UIImage { _rawUiImage :: Id } deriving stock (Generic, Show) deriving anyclass (NFData)

data Aspect = Fit | Fill | Scale | Center deriving (Generic, NFData, Show, Read)
