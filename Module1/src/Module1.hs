module Module1 () where

foreign export ccall loadModule1 :: IO ()
foreign export ccall unloadModule1 :: IO ()

loadModule1 = do
 print "loadModule1qqq"

unloadModule1 = do
 print "unloadModule1www"
