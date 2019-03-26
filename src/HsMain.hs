module HsMain () where

import qualified App (run)
import qualified ObjcMixStorage

foreign export ccall runHsMain :: IO ()

runHsMain = do
 App.run =<< ObjcMixStorage.create
