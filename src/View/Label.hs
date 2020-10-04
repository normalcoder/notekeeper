module View.Label
( Font(..)
, LineCount(..)
, BreakMode(..)
, defaultFont
) where

import ObjcMsgSt

data Font = Font FontName FontSize
newtype FontName = FontName String 
newtype FontSize = FontSize CGFloat
newtype LineCount = LineCount { _rawLineCount :: Int }

defaultFont = Font (FontName "SF") (FontSize 17)

data BreakMode =
   WordWrapping
 | CharWrapping
 | Clipping
 | TruncatingHead
 | TruncatingTail
 | TruncatingMiddle
