module ObjcMsg
( objc_msgSend
, objc_msgSend_class
, objc_msgSend'
) where

import ObjcTypes
import ObjcMsgHelpers

objc_msgSend obj selName args = do
 sel <- getSelByName selName
 objc_msgSend' obj sel args

objc_msgSend_class className selName args = do
 cls <- getClassByName className
 objc_msgSend cls selName args

objc_msgSend' obj sel [] = c_objc_msgSend0 obj sel
objc_msgSend' obj sel [a1] = c_objc_msgSend1 obj sel a1
objc_msgSend' obj sel [a1, a2] = c_objc_msgSend2 obj sel a1 a2
objc_msgSend' obj sel [a1, a2, a3] = c_objc_msgSend3 obj sel a1 a2 a3
objc_msgSend' obj sel [a1, a2, a3, a4] = c_objc_msgSend4 obj sel a1 a2 a3 a4
objc_msgSend' obj sel [a1, a2, a3, a4, a5] = c_objc_msgSend5 obj sel a1 a2 a3 a4 a5
objc_msgSend' obj sel [a1, a2, a3, a4, a5, a6] = c_objc_msgSend6 obj sel a1 a2 a3 a4 a5 a6
objc_msgSend' obj sel [a1, a2, a3, a4, a5, a6, a7] = c_objc_msgSend7 obj sel a1 a2 a3 a4 a5 a6 a7
objc_msgSend' obj sel [a1, a2, a3, a4, a5, a6, a7, a8] = c_objc_msgSend8 obj sel a1 a2 a3 a4 a5 a6 a7 a8
objc_msgSend' obj sel [a1, a2, a3, a4, a5, a6, a7, a8, a9] = c_objc_msgSend9 obj sel a1 a2 a3 a4 a5 a6 a7 a8 a9
objc_msgSend' obj sel [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10] = c_objc_msgSend10 obj sel a1 a2 a3 a4 a5 a6 a7 a8 a9 a10

foreign import ccall safe "objc_msgSend0" c_objc_msgSend0 :: Id -> Sel -> IO Id
foreign import ccall safe "objc_msgSend1" c_objc_msgSend1 :: Id -> Sel -> Id -> IO Id
foreign import ccall safe "objc_msgSend2" c_objc_msgSend2 :: Id -> Sel -> Id -> Id -> IO Id
foreign import ccall safe "objc_msgSend3" c_objc_msgSend3 :: Id -> Sel -> Id -> Id -> Id -> IO Id
foreign import ccall safe "objc_msgSend4" c_objc_msgSend4 :: Id -> Sel -> Id -> Id -> Id -> Id -> IO Id
foreign import ccall safe "objc_msgSend5" c_objc_msgSend5 :: Id -> Sel -> Id -> Id -> Id -> Id -> Id -> IO Id
foreign import ccall safe "objc_msgSend6" c_objc_msgSend6 :: Id -> Sel -> Id -> Id -> Id -> Id -> Id -> Id -> IO Id
foreign import ccall safe "objc_msgSend7" c_objc_msgSend7 :: Id -> Sel -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> IO Id
foreign import ccall safe "objc_msgSend8" c_objc_msgSend8 :: Id -> Sel -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> IO Id
foreign import ccall safe "objc_msgSend9" c_objc_msgSend9 :: Id -> Sel -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> IO Id
foreign import ccall safe "objc_msgSend10" c_objc_msgSend10 :: Id -> Sel -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> IO Id
