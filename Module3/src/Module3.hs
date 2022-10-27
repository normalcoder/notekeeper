{-# language GHC2021 #-}

module Module3 () where

import Data.IORef
import Control.Concurrent
import Control.Concurrent.MVar
import GHC.IO
import System.Random

import Utils

foreign export ccall loadModule3 :: IO ()
foreign export ccall unloadModule3 :: IO ()


loadModule3 = do
 print "real_loadModule3"

unloadModule3 = do
 print $ "real_unloadModule3"
