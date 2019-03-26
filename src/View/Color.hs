module View.Color
( Color(..)
) where

import ObjcMsgSt

data Color = Color R G B A
newtype R = R CGFloat
newtype G = G CGFloat
newtype B = B CGFloat
newtype A = A CGFloat
