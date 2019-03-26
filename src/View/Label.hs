module View.Label
( Font
, LineCount
, BreakMode
) where

import ObjcMsgSt

data Font = Font FontName FontSize
newtype FontName = FontName String 
newtype FontSize = FontSize CGFloat
newtype LineCount = LineCount Int

data BreakMode =
   WordWrapping
 | CharWrapping
 | Clipping
 | TruncatingHead
 | TruncatingTail
 | TruncatingMiddle
