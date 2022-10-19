module ObjcMsgHelpers
( noOfColonsInSelectorName
, selTypeEncodingForNoOfArgs
, getClassByName
, getSelByName
, object_getClass
) where

import ObjcTypes
import Foreign.C.String

getClassByName name = withCString name c_objc_getClass
getSelByName name = withCString name c_sel_registerName
object_getClass = c_object_getClass

noOfColonsInSelectorName name = length $ filter (== ':') name

{-
- (id)m2:(id)o1 :(id)o2
@32@0:8@16@24
@@:@@
-} 
selTypeEncodingForNoOfArgs noOfArgs = newCString $ "@@:" ++ (take noOfArgs $ cycle "@")

foreign import ccall safe "objc_getClass" c_objc_getClass :: CString -> IO Class
foreign import ccall safe "object_getClass" c_object_getClass :: Id -> IO Class
foreign import ccall safe "sel_registerName" c_sel_registerName :: CString -> IO Sel
