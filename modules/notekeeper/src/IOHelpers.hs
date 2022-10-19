module IOHelpers
( guard'
, ignore
) where

import Control.Monad
import Control.Exception
import Control.Applicative

guard' True _ = pure ()
guard' False s = print s >> empty

ignore = void . (try :: IO a -> IO (Either SomeException a))
