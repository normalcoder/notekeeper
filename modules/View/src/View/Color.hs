{-# language DeriveAnyClass, DerivingStrategies #-}

module View.Color
( Color(..)
, R(..)
, G(..)
, B(..)
, A(..)
, black
, white
, red
, green
, blue
, yellow
, cyan
, lightGray
, darkGray
, uiColor
) where

import GHC.Generics hiding (R)
import Control.DeepSeq

import Objc

data Color = Color R G B A deriving (Generic, NFData, Show, Read)
newtype R = R CGFloat deriving stock (Generic, Show, Read) deriving anyclass (NFData)
newtype G = G CGFloat deriving stock (Generic, Show, Read) deriving anyclass (NFData)
newtype B = B CGFloat deriving stock (Generic, Show, Read) deriving anyclass (NFData)
newtype A = A CGFloat deriving stock (Generic, Show, Read) deriving anyclass (NFData)

black = Color (R 0) (G 0) (B 0) (A 1)
white = Color (R 1) (G 1) (B 1) (A 1)
red = Color (R 1) (G 0) (B 0) (A 1)
green = Color (R 0) (G 1) (B 0) (A 1)
blue = Color (R 0) (G 0) (B 1) (A 1)
yellow = Color (R 1) (G 1) (B 0) (A 1)
cyan = Color (R 0) (G 1) (B 1) (A 1)
lightGray = let r = 2/3 in Color (R r) (G r) (B r) (A 1)
darkGray = let r = 1/3 in Color (R r) (G r) (B r) (A 1)

uiColor (Color (R r) (G g) (B b) (A a)) = do
 colorClass <- "class" @| "UIColor"
 objc_msgSend_apply_CGFloat_x4 colorClass "colorWithRed:green:blue:alpha:" r g b a
