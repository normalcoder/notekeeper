module ObjcMsg1
( objc_msgSend1
) where

import ObjcTypes
import ObjcMsgHelpers

objc_msgSend1 obj sel a1 = c_objc_msgSend1 obj sel a1

foreign import ccall safe "objc_msgSend" c_objc_msgSend1 :: Id -> Sel -> Id -> IO Id
