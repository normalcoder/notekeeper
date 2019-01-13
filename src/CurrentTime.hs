module CurrentTime
( getCurrentTime
) where

import Data.Word

foreign import ccall safe "getCurrentTime" c_getCurrentTime :: IO Word64

getCurrentTime = c_getCurrentTime
