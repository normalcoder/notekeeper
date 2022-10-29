{-# language DeriveAnyClass, DerivingStrategies #-}

module View.Label
( Font(..)
, FontName(..)
, FontSize(..)
, LineCount(..)
, BreakMode(..)
, defaultFont
, textSize
) where

import GHC.Generics hiding (R)
import Control.DeepSeq

import Foreign
import Numeric.Limits
import Data.Bits

import ObjcTypes
import ObjcMsgOps
import ObjcMsgSt
import ObjcHelpers
import UiKitText

data Font = Font FontName FontSize deriving (Generic, NFData, Show, Read)
newtype FontName = FontName String deriving stock (Generic, Show, Read) deriving anyclass (NFData)
newtype FontSize = FontSize CGFloat deriving stock (Generic, Show, Read) deriving anyclass (NFData)
newtype LineCount = LineCount { _rawLineCount :: Int } deriving stock (Generic, Show, Read) deriving anyclass (NFData)

-- SF
defaultFont = Font (FontName ".SFUI-Regular") (FontSize 17)

data BreakMode =
   WordWrapping
 | CharWrapping
 | Clipping
 | TruncatingHead
 | TruncatingTail
 | TruncatingMiddle
 deriving (Generic, NFData, Show, Read)


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
