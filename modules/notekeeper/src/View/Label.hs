module View.Label
( Font(..)
, FontName(..)
, FontSize(..)
, LineCount(..)
, BreakMode(..)
, defaultFont
, textSize
) where

import Foreign
import Numeric.Limits
import Data.Bits

import ObjcTypes
import ObjcMsgOps
import ObjcMsgSt
import ObjcHelpers
import UiKitText

data Font = Font FontName FontSize deriving (Show)
newtype FontName = FontName String deriving (Show)
newtype FontSize = FontSize CGFloat deriving (Show)
newtype LineCount = LineCount { _rawLineCount :: Int } deriving (Show)

-- SF
defaultFont = Font (FontName ".SFUI-Regular") (FontSize 17)

data BreakMode =
   WordWrapping
 | CharWrapping
 | Clipping
 | TruncatingHead
 | TruncatingTail
 | TruncatingMiddle
 deriving (Show)


textSize text (Font (FontName name) (FontSize fontSize)) width = do
 -- font <- ("systemFontOfSize:", fontSize) <.+ "class" @| "UIFont"
 nsStringName <- getNsString name
 font <- ("fontWithName:size:", nsStringName, fontSize) <.@+ "class" @| "UIFont"

 _cNSFontAttributeName <- peek cNSFontAttributeName
 attributes <- nsDict [(_cNSFontAttributeName, font)]
 let options = wordPtrToPtr $ usesLineFragmentOrigin .|. usesFontLeading
 boundingRect text (width, maxValue) options attributes nullPtr
 
 



{-
boundingRect text size options attributes context = do
 nsString <- getNsString text
 ("boundingRectWithSize:options:attributes:context:", size, options, attributes, context) #<.%@@@. nsString


        CGSize maximumLabelSize = CGSizeMake(310, CGFLOAT_MAX);
        CGRect textRect = [s boundingRectWithSize:maximumLabelSize
                                                 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                              attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17]}
                                                 context:nil];

-}
