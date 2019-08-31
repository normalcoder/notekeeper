module View.Color
( Color(..)
, R(..)
, G(..)
, B(..)
, A(..)
, white
) where

import ObjcMsgSt

data Color = Color R G B A
newtype R = R CGFloat
newtype G = G CGFloat
newtype B = B CGFloat
newtype A = A CGFloat

white = Color (R 1) (G 1) (B 1) (A 1)
