module View.Label
( Font(..)
, LineCount(..)
, BreakMode(..)
, defaultFont
) where

import ObjcMsgSt

data Font = Font FontName FontSize deriving (Show)
newtype FontName = FontName String deriving (Show)
newtype FontSize = FontSize CGFloat deriving (Show)
newtype LineCount = LineCount { _rawLineCount :: Int } deriving (Show)

defaultFont = Font (FontName "SF") (FontSize 17)

data BreakMode =
   WordWrapping
 | CharWrapping
 | Clipping
 | TruncatingHead
 | TruncatingTail
 | TruncatingMiddle
 deriving (Show)
