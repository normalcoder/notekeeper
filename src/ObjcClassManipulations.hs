module ObjcClassManipulations
( replaceObjcMethod
, registerSubclass
, MethodType(..)
) where

import ObjcTypes
import ObjcMsgHelpers
import ObjcFunPtr
import Foreign.C.String
import Foreign.Ptr

data MethodType = ClassMethod | InstanceMethod deriving (Show)

replaceObjcMethod cls sel newImplFBuilder = do
 origMethod <- c_class_getInstanceMethod cls sel
 origImplF <- case origMethod == nullPtr of
  True -> return nullPtr
  _ -> c_class_getMethodImplementation cls sel
  
 typeEncoding <- do
  enc <- c_method_getTypeEncoding origMethod
  case enc == nullPtr of
   True -> selTypeEncodingForNoOfArgs 0
   _ -> return $ enc

 newImplF <- newImplFBuilder origImplF
 c_class_replaceMethod cls sel newImplF typeEncoding
 return ()

registerSubclass baseClassName subclassName methods = do
 baseClass <- getClassByName baseClassName
 subclass <- withCString subclassName $ \s -> c_objc_allocateClassPair baseClass s 0
 c_objc_registerClassPair subclass

 subclassMeta <- object_getClass subclass

 let
  addMethod (methodType, selectorName, act) = do
   sel <- getSelByName selectorName

   method <- c_class_getInstanceMethod baseClass sel
   encoding <- case method == nullPtr of
    True -> selTypeEncodingForNoOfArgs $ noOfColonsInSelectorName selectorName
    _ -> c_method_getTypeEncoding method

   let
    classToAddMethodTo = case methodType of
     ClassMethod -> subclassMeta
     _ -> subclass

   imp <- toFunPtr (noOfColonsInSelectorName selectorName) act
   c_class_addMethod classToAddMethodTo sel imp encoding

 mapM_ addMethod methods


foreign import ccall safe "class_getInstanceMethod" c_class_getInstanceMethod :: Class -> Sel -> IO Method
foreign import ccall safe "class_getMethodImplementation" c_class_getMethodImplementation :: Class -> Sel -> IO Imp
foreign import ccall safe "method_getTypeEncoding" c_method_getTypeEncoding :: Method -> IO TypeEncoding
foreign import ccall safe "class_replaceMethod" c_class_replaceMethod :: Class -> Sel -> Imp -> TypeEncoding -> IO Imp

foreign import ccall safe "objc_allocateClassPair" c_objc_allocateClassPair :: Class -> CString -> Int -> IO Class
foreign import ccall safe "class_addMethod" c_class_addMethod :: Class -> Sel -> Imp -> TypeEncoding -> IO ()
foreign import ccall safe "objc_registerClassPair" c_objc_registerClassPair :: Class -> IO ()
