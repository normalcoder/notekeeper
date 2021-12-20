module HsMain () where

import qualified App (run)

import Control.Concurrent
import Data.Time.Clock

foreign export ccall runHsMain :: IO ()

runHsMain = do
 -- checkPerf
 App.run


checkPerf = forkIO $ do
 print $ "!!!!start test"
 t1 <- getCurrentTime
 print $ "!!!!sum: " ++ show (sum [1..10^9])
 t2 <- getCurrentTime
 print $ "!!!!timeDiff: " ++ show (diffUTCTime t2 t1)
