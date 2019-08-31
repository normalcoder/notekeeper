module HsMain () where

import qualified App (run)

foreign export ccall runHsMain :: IO ()

runHsMain = do
 App.run
