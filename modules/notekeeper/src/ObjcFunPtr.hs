module ObjcFunPtr
( fromFunPtr
, toFunPtr
) where

import Foreign
import ObjcTypes

toFunPtr :: Int -> (Id -> Sel -> [Id] -> IO Id) -> IO Imp
toFunPtr noOfArgs f = case noOfArgs of
 0 -> (toFunPtr0 $ \obj sel -> f obj sel []) >>= castFunPtrIO
 1 -> (toFunPtr1 $ \obj sel a1 -> f obj sel [a1]) >>= castFunPtrIO
 2 -> (toFunPtr2 $ \obj sel a1 a2 -> f obj sel [a1, a2]) >>= castFunPtrIO
 3 -> (toFunPtr3 $ \obj sel a1 a2 a3 -> f obj sel [a1, a2, a3]) >>= castFunPtrIO
 4 -> (toFunPtr4 $ \obj sel a1 a2 a3 a4 -> f obj sel [a1, a2, a3, a4]) >>= castFunPtrIO
 5 -> (toFunPtr5 $ \obj sel a1 a2 a3 a4 a5 -> f obj sel [a1, a2, a3, a4, a5]) >>= castFunPtrIO
 6 -> (toFunPtr6 $ \obj sel a1 a2 a3 a4 a5 a6 -> f obj sel [a1, a2, a3, a4, a5, a6]) >>= castFunPtrIO
 7 -> (toFunPtr7 $ \obj sel a1 a2 a3 a4 a5 a6 a7 -> f obj sel [a1, a2, a3, a4, a5, a6, a7]) >>= castFunPtrIO
 8 -> (toFunPtr8 $ \obj sel a1 a2 a3 a4 a5 a6 a7 a8 -> f obj sel [a1, a2, a3, a4, a5, a6, a7, a8]) >>= castFunPtrIO
 9 -> (toFunPtr9 $ \obj sel a1 a2 a3 a4 a5 a6 a7 a8 a9 -> f obj sel [a1, a2, a3, a4, a5, a6, a7, a8, a9]) >>= castFunPtrIO
 10 -> (toFunPtr10 $ \obj sel a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 -> f obj sel [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10]) >>= castFunPtrIO
castFunPtrIO x = return $ castFunPtrToPtr x


fromFunPtr :: Int -> Imp -> (Id -> Sel -> [Id] -> IO Id)
fromFunPtr noOfArgs fImpl' = case noOfArgs of
 0 -> \obj sel [] -> fromFunPtr0 fImpl obj sel
 1 -> \obj sel [a1] -> fromFunPtr1 fImpl obj sel a1
 2 -> \obj sel [a1, a2] -> fromFunPtr2 fImpl obj sel a1 a2
 3 -> \obj sel [a1, a2, a3] -> fromFunPtr3 fImpl obj sel a1 a2 a3
 4 -> \obj sel [a1, a2, a3, a4] -> fromFunPtr4 fImpl obj sel a1 a2 a3 a4
 5 -> \obj sel [a1, a2, a3, a4, a5] -> fromFunPtr5 fImpl obj sel a1 a2 a3 a4 a5
 6 -> \obj sel [a1, a2, a3, a4, a5, a6] -> fromFunPtr6 fImpl obj sel a1 a2 a3 a4 a5 a6
 7 -> \obj sel [a1, a2, a3, a4, a5, a6, a7] -> fromFunPtr7 fImpl obj sel a1 a2 a3 a4 a5 a6 a7
 8 -> \obj sel [a1, a2, a3, a4, a5, a6, a7, a8] -> fromFunPtr8 fImpl obj sel a1 a2 a3 a4 a5 a6 a7 a8
 9 -> \obj sel [a1, a2, a3, a4, a5, a6, a7, a8, a9] -> fromFunPtr9 fImpl obj sel a1 a2 a3 a4 a5 a6 a7 a8 a9
 10 -> \obj sel [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10] -> fromFunPtr10 fImpl obj sel a1 a2 a3 a4 a5 a6 a7 a8 a9 a10
 where
  fImpl = castPtrToFunPtr fImpl'

foreign import ccall "wrapper" toFunPtr0 :: (Id -> Sel -> IO Id) -> IO (FunPtr (Id -> Sel -> IO Id))
foreign import ccall "wrapper" toFunPtr1 :: (Id -> Sel -> Id -> IO Id) -> IO (FunPtr (Id -> Sel -> Id -> IO Id))
foreign import ccall "wrapper" toFunPtr2 :: (Id -> Sel -> Id -> Id -> IO Id) -> IO (FunPtr (Id -> Sel -> Id -> Id -> IO Id))
foreign import ccall "wrapper" toFunPtr3 :: (Id -> Sel -> Id -> Id -> Id -> IO Id) -> IO (FunPtr (Id -> Sel -> Id -> Id -> Id -> IO Id))
foreign import ccall "wrapper" toFunPtr4 :: (Id -> Sel -> Id -> Id -> Id -> Id -> IO Id) -> IO (FunPtr (Id -> Sel -> Id -> Id -> Id -> Id -> IO Id))
foreign import ccall "wrapper" toFunPtr5 :: (Id -> Sel -> Id -> Id -> Id -> Id -> Id -> IO Id) -> IO (FunPtr (Id -> Sel -> Id -> Id -> Id -> Id -> Id -> IO Id))
foreign import ccall "wrapper" toFunPtr6 :: (Id -> Sel -> Id -> Id -> Id -> Id -> Id -> Id -> IO Id) -> IO (FunPtr (Id -> Sel -> Id -> Id -> Id -> Id -> Id -> Id -> IO Id))
foreign import ccall "wrapper" toFunPtr7 :: (Id -> Sel -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> IO Id) -> IO (FunPtr (Id -> Sel -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> IO Id))
foreign import ccall "wrapper" toFunPtr8 :: (Id -> Sel -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> IO Id) -> IO (FunPtr (Id -> Sel -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> IO Id))
foreign import ccall "wrapper" toFunPtr9 :: (Id -> Sel -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> IO Id) -> IO (FunPtr (Id -> Sel -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> IO Id))
foreign import ccall "wrapper" toFunPtr10 :: (Id -> Sel -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> IO Id) -> IO (FunPtr (Id -> Sel -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> IO Id))

foreign import ccall "dynamic" fromFunPtr0 :: FunPtr (Id -> Sel -> IO Id) -> (Id -> Sel -> IO Id)
foreign import ccall "dynamic" fromFunPtr1 :: FunPtr (Id -> Sel -> Id -> IO Id) -> (Id -> Sel -> Id -> IO Id)
foreign import ccall "dynamic" fromFunPtr2 :: FunPtr (Id -> Sel -> Id -> Id -> IO Id) -> (Id -> Sel -> Id -> Id -> IO Id)
foreign import ccall "dynamic" fromFunPtr3 :: FunPtr (Id -> Sel -> Id -> Id -> Id -> IO Id) -> (Id -> Sel -> Id -> Id -> Id -> IO Id)
foreign import ccall "dynamic" fromFunPtr4 :: FunPtr (Id -> Sel -> Id -> Id -> Id -> Id -> IO Id) -> (Id -> Sel -> Id -> Id -> Id -> Id -> IO Id)
foreign import ccall "dynamic" fromFunPtr5 :: FunPtr (Id -> Sel -> Id -> Id -> Id -> Id -> Id -> IO Id) -> (Id -> Sel -> Id -> Id -> Id -> Id -> Id -> IO Id)
foreign import ccall "dynamic" fromFunPtr6 :: FunPtr (Id -> Sel -> Id -> Id -> Id -> Id -> Id -> Id -> IO Id) -> (Id -> Sel -> Id -> Id -> Id -> Id -> Id -> Id -> IO Id)
foreign import ccall "dynamic" fromFunPtr7 :: FunPtr (Id -> Sel -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> IO Id) -> (Id -> Sel -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> IO Id)
foreign import ccall "dynamic" fromFunPtr8 :: FunPtr (Id -> Sel -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> IO Id) -> (Id -> Sel -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> IO Id)
foreign import ccall "dynamic" fromFunPtr9 :: FunPtr (Id -> Sel -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> IO Id) -> (Id -> Sel -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> IO Id)
foreign import ccall "dynamic" fromFunPtr10 :: FunPtr (Id -> Sel -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> IO Id) -> (Id -> Sel -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> Id -> IO Id)
