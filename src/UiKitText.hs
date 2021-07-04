module UiKitText
( usesLineFragmentOrigin
, usesFontLeading
, boundingRect
, cNSFontAttributeName
) where

import Foreign.Ptr
import Data.Bits

import ObjcTypes
import ObjcHelpers
import ObjcMsgOps


-- NSStringDrawingUsesLineFragmentOrigin = 1 << 0
usesLineFragmentOrigin = 1 `shiftL` 0 :: WordPtr

-- NSStringDrawingUsesFontLeading = 1 << 1
usesFontLeading = 1 `shiftL` 1 :: WordPtr


boundingRect text size options attributes context = do
 nsString <- getNsString text
 ("boundingRectWithSize:options:attributes:context:", size, options, attributes, context) #<.%@@@. nsString

foreign import ccall unsafe "&NSFontAttributeName" cNSFontAttributeName :: Ptr Id
