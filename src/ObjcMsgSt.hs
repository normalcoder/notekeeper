{-# language FlexibleInstances #-}

module ObjcMsgSt
( AffineTransform(..)
, Transform3D(..)
, CGFloat
, CGFloat2
, CGFloat4
, Float2
, Double2

, objc_msgSend_stapply_CGFloat
, objc_msgSend_stapply_CGFloat2
, objc_msgSend_stapply_CGFloat4
, objc_msgSend_stapply_CGFloat6
, objc_msgSend_stapply_CGFloat16
, objc_msgSend_stapply_Float2
, objc_msgSend_stapply_Double2
, objc_msgSend_stapply_Double
, objc_msgSend_stapply_Float

, objc_msgSend_apply_CGFloat_x4

, objc_msgSend_stret_CGFloat2
, objc_msgSend_stret_CGFloat2_apply_ptr
, objc_msgSend_stret_CGFloat4
, objc_msgSend_stret_CGFloat4_apply_ptr
, objc_msgSend_stret_CGFloat6
, objc_msgSend_stret_CGFloat6_apply_ptr
, objc_msgSend_stret_CGFloat16
, objc_msgSend_stret_CGFloat16_apply_ptr
, objc_msgSend_stret_Float2
, objc_msgSend_stret_Float2_apply_ptr
, objc_msgSend_stret_Double2
, objc_msgSend_stret_Double2_apply_ptr
--, objc_msgSend_stret_Float
--, objc_msgSend_stret_Float_apply_ptr
, objc_msgSend_stret_CGFloat2_apply_CGFloat2_apply_ptr
, objc_msgSend_apply_ptr_apply_block
) where

import ObjcTypes
import ObjcMsg
import ObjcMsgHelpers
import Foreign.Ptr
import Foreign.Marshal.Alloc
import Foreign.Storable
import Foreign.C.Types
import GHC.Float

type SelName = String

type StArgPtr = Ptr ()
type StRetPtr = Ptr ()

type CGFloat = Double
type CGFloat2 = (CGFloat, CGFloat)
type CGFloat4 = (CGFloat, CGFloat, CGFloat, CGFloat)
data AffineTransform = AffineTransform { a, b, c, d, tx, ty :: CGFloat } deriving (Show, Eq)
data Transform3D = Transform3D { m11, m12, m13, m14, m21, m22, m23, m24, m31, m32, m33, m34, m41, m42, m43, m44 :: CGFloat } deriving (Show, Eq)
type Float2 = (Float, Float)
type Double2 = (Double, Double)

instance Storable a => Storable (a, a) where
 alignment _ = 8
 sizeOf _ = 2 * 8 -- (sizeOf (undefined :: a))
 peek p = (,) <$> peekElemOff (castPtr p) 0 <*> peekElemOff (castPtr p) 1
 poke p (a,b) = pokeElemOff (castPtr p) 0 a >> pokeElemOff (castPtr p) 1 b


data FpValue = FpFloat CGFloat | FpDouble CGFloat deriving (Show) -- FpValue is a wrapper which helps to peek and poke float of double

fpValueSize (FpFloat _) = 4
fpValueSize (FpDouble _) = 8

instance Storable FpValue where
 alignment _ = 8
 sizeOf (FpFloat _) = sizeOfFloat
 sizeOf (FpDouble _) = sizeOfDouble
 peek _ = error "34536633"
 poke ptr (FpFloat f) = poke (castPtr ptr) (double2Float f)
 poke ptr (FpDouble d) = poke (castPtr ptr) d

sizeOfFloat = 4
sizeOfDouble = 8

peekFpValue size ptr
 | size == sizeOfFloat = peek (castPtr ptr) >>= \r -> return $ FpFloat $ float2Double r
 | size == sizeOfDouble = peek (castPtr ptr) >>= \r -> return $ FpDouble r

-- in the user code we will use Doubles for CGFloat values, so we need such converters
floatToFpValue cgFloat
 | c_sizeOfCGFloat == sizeOfFloat = FpFloat cgFloat
 | c_sizeOfCGFloat == sizeOfDouble = FpDouble cgFloat

fpValueToFloat (FpFloat f) = f
fpValueToFloat (FpDouble d) = d

fpValueStrictlyToFloat (FpFloat f) = f
fpValueStrictlyToDouble (FpDouble d) = d



objc_msgSend_stapply_CGFloat :: Id -> SelName -> CGFloat -> IO Id
objc_msgSend_stapply_CGFloat obj selName x =
 common_stapply obj selName c_objc_msgSend_stapply_CGFloat $ map floatToFpValue [x]
objc_msgSend_stapply_CGFloat2 obj selName (x,y) =
 common_stapply obj selName c_objc_msgSend_stapply_CGFloat2 $ map floatToFpValue [x,y]
objc_msgSend_stapply_CGFloat4 obj selName (x,y,w,h) =
 common_stapply obj selName c_objc_msgSend_stapply_CGFloat4 $ map floatToFpValue [x,y,w,h]
objc_msgSend_stapply_CGFloat6 obj selName (AffineTransform a b c d tx ty) =
 common_stapply obj selName c_objc_msgSend_stapply_CGFloat6 $ map floatToFpValue [a,b,c,d,tx,ty]
objc_msgSend_stapply_CGFloat16 obj selName (Transform3D m11 m12 m13 m14 m21 m22 m23 m24 m31 m32 m33 m34 m41 m42 m43 m44) =
 common_stapply obj selName c_objc_msgSend_stapply_CGFloat16 $ map floatToFpValue [m11,m12,m13,m14,m21,m22,m23,m24,m31,m32,m33,m34,m41,m42,m43,m44]
objc_msgSend_stapply_Float2 obj selName (x,y) =
 common_stapply obj selName c_objc_msgSend_stapply_Float2 $ map FpFloat [x,y]
objc_msgSend_stapply_Double2 obj selName (x,y) =
 common_stapply obj selName c_objc_msgSend_stapply_Double2 $ map FpDouble [x,y]

objc_msgSend_apply_CGFloat_x4 :: Id -> SelName -> CGFloat -> CGFloat -> CGFloat -> CGFloat -> IO Id
objc_msgSend_apply_CGFloat_x4 obj selName x y z w = do
 sel <- getSelByName selName
 c_objc_msgSend_apply_CGFloat_x4 obj sel x y z w


objc_msgSend_stapply_Double :: Id -> SelName -> Double -> IO Id
objc_msgSend_stapply_Double obj selName x = do
 sel <- getSelByName selName
 allocaBytes sizeOfFloat $ \structBuffer -> do
  pokeElemOff structBuffer 0 x
  c_objc_msgSend_stapply_Double obj sel $ castPtr structBuffer

objc_msgSend_stapply_Float :: Id -> SelName -> Float -> IO Id
objc_msgSend_stapply_Float obj selName x = do
 sel <- getSelByName selName
 allocaBytes sizeOfFloat $ \structBuffer -> do
  pokeElemOff structBuffer 0 x
  c_objc_msgSend_stapply_Float obj sel $ castPtr structBuffer


--objc_msgSend_stapply_Float obj selName x =
-- common_stapply obj selName c_objc_msgSend_stapply_Float $ map FpFloat [x]

common_stapply obj selName f fpValues@(firstFpValue:_) = do
 sel <- getSelByName selName
 allocaBytes (length fpValues * sizeOfFpValue) $ \structBuffer -> do
  mapM_ (\(off, v) -> pokeElemOff structBuffer off v) $ zip [0..] fpValues
  f obj sel $ castPtr structBuffer
  where
   sizeOfFpValue = fpValueSize firstFpValue

objc_msgSend_stret_CGFloat2 :: Id -> SelName -> IO CGFloat2
objc_msgSend_stret_CGFloat2 obj selName = do
 sel <- getSelByName selName
 alloca $ \rPtr -> do
  c_objc_msgSend_stret_CGFloat2 obj sel rPtr
  peek rPtr

objc_msgSend_stret_CGFloat2_apply_ptr :: Id -> SelName -> Id -> IO CGFloat2
objc_msgSend_stret_CGFloat2_apply_ptr obj selName arg1 = do
 sel <- getSelByName selName
 alloca $ \rPtr -> do
  c_objc_msgSend_stret_CGFloat2_apply_ptr obj sel rPtr arg1
  peek rPtr

-- objc_msgSend_stret_CGFloat2 obj selName = objc_msgSend_stret_CGFloat2_apply_ptr obj selName nullPtr
-- objc_msgSend_stret_CGFloat2_apply_ptr obj selName arg1 = do
--  [x,y] <- common_stret_cgfloats obj selName c_objc_msgSend_stret_CGFloat2 2 arg1
--  return (x,y)

objc_msgSend_stret_CGFloat4 obj selName = objc_msgSend_stret_CGFloat4_apply_ptr obj selName nullPtr
objc_msgSend_stret_CGFloat4_apply_ptr obj selName arg1 = do
 [x,y,w,h] <- common_stret_cgfloats obj selName c_objc_msgSend_stret_CGFloat4 4 arg1
 return (x,y,w,h)

objc_msgSend_stret_CGFloat6 obj selName = objc_msgSend_stret_CGFloat6_apply_ptr obj selName nullPtr
objc_msgSend_stret_CGFloat6_apply_ptr obj selName arg1 = do
 [a,b,c,d,tx,ty] <- common_stret_cgfloats obj selName c_objc_msgSend_stret_CGFloat6 6 arg1
 return $ AffineTransform a b c d tx ty

objc_msgSend_stret_CGFloat16 obj selName = objc_msgSend_stret_CGFloat16_apply_ptr obj selName nullPtr
objc_msgSend_stret_CGFloat16_apply_ptr obj selName arg1 = do
 [m11, m12, m13, m14, m21, m22, m23, m24, m31, m32, m33, m34, m41, m42, m43, m44]
  <- common_stret_cgfloats obj selName c_objc_msgSend_stret_CGFloat16 16 arg1
 return $ Transform3D m11 m12 m13 m14 m21 m22 m23 m24 m31 m32 m33 m34 m41 m42 m43 m44

objc_msgSend_stret_Float2 obj selName = objc_msgSend_stret_Float2_apply_ptr obj selName nullPtr
objc_msgSend_stret_Float2_apply_ptr obj selName arg1 = do
 [x,y] <- common_stret_floats obj selName c_objc_msgSend_stret_Float2 2 arg1
 return (x,y)

objc_msgSend_stret_Double2 obj selName = objc_msgSend_stret_Double2_apply_ptr obj selName nullPtr
objc_msgSend_stret_Double2_apply_ptr obj selName arg1 = do
 [x,y] <- common_stret_floats obj selName c_objc_msgSend_stret_Double2 2 arg1
 return (x,y)

--objc_msgSend_stret_Float obj selName = objc_msgSend_stret_Float_apply_ptr obj selName nullPtr
--objc_msgSend_stret_Float_apply_ptr obj selName arg1 = do
-- [x] <- common_stret_floats obj selName c_objc_msgSend_stret_Float 1 arg1
-- return x

common_stret sizeOfFpValue obj selName f numOfFpValues arg1 = do
 sel <- getSelByName selName
 allocaBytes (numOfFpValues * sizeOfFpValue) $ \structBuffer -> do
  f obj sel (castPtr structBuffer) arg1
  mapM (\off -> peekFpValue sizeOfFpValue $ structBuffer `plusPtr` (off * sizeOfFpValue)) [0..numOfFpValues-1]

common_stret_cgfloats obj selName f numOfFpValues arg1 = do
 fpValues <- common_stret c_sizeOfCGFloat obj selName f numOfFpValues arg1
 return $ map fpValueToFloat fpValues

common_stret_floats obj selName f numOfFpValues arg1 = do
 fpValues <- common_stret sizeOfFloat obj selName f numOfFpValues arg1
 return $ map fpValueStrictlyToFloat fpValues

common_stret_doubles obj selName f numOfFpValues arg1 = do
 fpValues <- common_stret sizeOfDouble obj selName f numOfFpValues arg1
 return $ map fpValueStrictlyToDouble fpValues


foreign import ccall safe "sizeOfCGFloat" c_sizeOfCGFloat :: Int

foreign import ccall safe "objc_msgSend_stapply_CGFloat" c_objc_msgSend_stapply_CGFloat :: Id -> Sel -> StArgPtr -> IO Id
foreign import ccall safe "objc_msgSend_stapply_CGFloat2" c_objc_msgSend_stapply_CGFloat2 :: Id -> Sel -> StArgPtr -> IO Id
foreign import ccall safe "objc_msgSend_stapply_CGFloat4" c_objc_msgSend_stapply_CGFloat4 :: Id -> Sel -> StArgPtr -> IO Id
foreign import ccall safe "objc_msgSend_stapply_CGFloat6" c_objc_msgSend_stapply_CGFloat6 :: Id -> Sel -> StArgPtr -> IO Id
foreign import ccall safe "objc_msgSend_stapply_CGFloat16" c_objc_msgSend_stapply_CGFloat16 :: Id -> Sel -> StArgPtr -> IO Id
foreign import ccall safe "objc_msgSend_stapply_Float2" c_objc_msgSend_stapply_Float2 :: Id -> Sel -> StArgPtr -> IO Id
foreign import ccall safe "objc_msgSend_stapply_Double2" c_objc_msgSend_stapply_Double2 :: Id -> Sel -> StArgPtr -> IO Id
foreign import ccall safe "objc_msgSend_stapply_Double" c_objc_msgSend_stapply_Double :: Id -> Sel -> StArgPtr -> IO Id
foreign import ccall safe "objc_msgSend_stapply_Float" c_objc_msgSend_stapply_Float :: Id -> Sel -> StArgPtr -> IO Id

foreign import ccall safe "objc_msgSend_apply_CGFloat_x4" c_objc_msgSend_apply_CGFloat_x4 :: Id -> Sel -> CGFloat -> CGFloat -> CGFloat -> CGFloat -> IO Id


foreign import ccall safe "objc_msgSend_stret_CGFloat2" c_objc_msgSend_stret_CGFloat2 :: Id -> Sel -> Ptr CGFloat2 -> IO ()
foreign import ccall safe "objc_msgSend_stret_CGFloat2_apply_ptr" c_objc_msgSend_stret_CGFloat2_apply_ptr :: Id -> Sel -> Ptr CGFloat2 -> Id -> IO ()
foreign import ccall safe "objc_msgSend_stret_CGFloat4" c_objc_msgSend_stret_CGFloat4 :: Id -> Sel -> StRetPtr -> Id -> IO ()
foreign import ccall safe "objc_msgSend_stret_CGFloat6" c_objc_msgSend_stret_CGFloat6 :: Id -> Sel -> StRetPtr -> Id -> IO ()
foreign import ccall safe "objc_msgSend_stret_CGFloat16" c_objc_msgSend_stret_CGFloat16 :: Id -> Sel -> StRetPtr -> Id -> IO ()
foreign import ccall safe "objc_msgSend_stret_Float2" c_objc_msgSend_stret_Float2 :: Id -> Sel -> StRetPtr -> Id -> IO ()
foreign import ccall safe "objc_msgSend_stret_Double2" c_objc_msgSend_stret_Double2 :: Id -> Sel -> StRetPtr -> Id -> IO ()
--foreign import ccall safe "objc_msgSend_stret_Float" c_objc_msgSend_stret_Float :: Id -> Sel -> StRetPtr -> Id -> IO ()

foreign import ccall safe "objc_msgSend_stret_CGFloat2_apply_CGFloat2_apply_ptr" c_objc_msgSend_stret_CGFloat2_apply_CGFloat2_apply_ptr :: Id -> Sel -> Ptr CGFloat2 -> Ptr CGFloat2 -> Id -> IO ()

objc_msgSend_stret_CGFloat2_apply_CGFloat2_apply_ptr :: Id -> SelName -> CGFloat2 -> Id -> IO CGFloat2
objc_msgSend_stret_CGFloat2_apply_CGFloat2_apply_ptr obj selName arg1 arg2 = do
 sel <- getSelByName selName
 alloca $ \arg1Buffer -> do
  alloca $ \rBuffer -> do
   poke arg1Buffer arg1
   c_objc_msgSend_stret_CGFloat2_apply_CGFloat2_apply_ptr obj sel rBuffer arg1Buffer arg2
   peek rBuffer

foreign import ccall safe "objc_msgSend_apply_ptr_apply_block" c_objc_msgSend_apply_ptr_apply_block :: Id -> Sel -> Id -> FunPtr (Id -> IO ()) -> IO ()

foreign import ccall "wrapper" toCompletionArg1 :: (Id -> IO ()) -> IO (FunPtr (Id -> IO ()))

objc_msgSend_apply_ptr_apply_block :: Id -> SelName -> Id -> (Id -> IO ()) -> IO ()
objc_msgSend_apply_ptr_apply_block obj selName arg1 block = do
 sel <- getSelByName selName
 blockFunPtr <- toCompletionArg1 block
 c_objc_msgSend_apply_ptr_apply_block obj sel arg1 blockFunPtr
