module ObjcHelpers
( getNsObjectDescription
, getNsString
, fromNsString
, getObjectClass
, getObjectClassName
, toNsInteger
, fromNsInteger
, toNsBool
, fromNsBool
, NsNumberable(..)
, floatToPtr
, bitN
, ptrInt
, ptrWord
, ptrBool
, nsArray
, nsDict
, mkDelegate
, nullRet
) where

import Control.Monad

import Foreign
import Foreign.C.String
import Data.Bits hiding (bit)

import ObjcTypes
import ObjcMsg
import ObjcMsgOps
import ObjcClassManipulations

toNsInteger = plusPtr nullPtr

fromNsInteger :: Id -> Int
fromNsInteger p = p `minusPtr` nullPtr

toNsBool True = toNsInteger 1
toNsBool False = toNsInteger 0
fromNsBool = (/= 0) . fromNsInteger

class NsNumberable a where
 mkNsNumber :: a -> IO Id

mkNsNumberCommon sel convert val = (sel, convert val) <.@ "class" @| "NSNumber"

instance NsNumberable Bool where
 mkNsNumber = mkNsNumberCommon "numberWithBool:" toNsBool

instance NsNumberable Int where
 mkNsNumber = mkNsNumberCommon "numberWithInteger:" toNsInteger

instance NsNumberable Float where
 mkNsNumber = mkNsNumberCommon "numberWithFloat:" floatToPtr

foreign import ccall safe "floatToPtr" floatToPtr :: Float -> Ptr ()


getNsObjectDescription o = "UTF8String" @< "description" @<. o >>= peekCString . castPtr
getNsString s = withCString s $ \s -> objc_msgSend_class "NSString" "stringWithUTF8String:" [castPtr s]
fromNsString nsString = "UTF8String" @<. nsString >>= peekCString . castPtr
getObjectClass o = objc_msgSend o "class" []
getObjectClassName o = getObjectClass o >>= getNsObjectDescription


bitN :: Int -> Word64
bitN n = 1 `shiftL` n

ptrInt :: Int -> Ptr ()
ptrInt = plusPtr nullPtr

ptrWord :: Word64 -> Ptr ()
ptrWord = plusPtr nullPtr . fromIntegral

ptrBool :: Bool -> Ptr ()
ptrBool True = plusPtr nullPtr 1
ptrBool False = plusPtr nullPtr 0


nsArray os = do
 a <- "new" @| "NSMutableArray"
 forM_ os $ \o -> do
  ("addObject:", o) <.@. a
 pure a

nsDict kvs = do
 d <- "new" @| "NSMutableDictionary"
 forM_ kvs $ \(k,v) -> do
  ("setValue:forKey:", [v, k]) <.@@. d
 pure d

mkDelegate className methods = do
 registerSubclass "NSObject" className $ map (\(name, action) -> (InstanceMethod, name, action)) methods
 "new" @| className

nullRet a = a >> pure nullPtr
