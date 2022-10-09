module Module1 () where

foreign export ccall loadModule1 :: IO ()
foreign export ccall unloadModule1 :: IO ()

loadModule1 = do
 print "fake_loadModule1"

unloadModule1 = do
 print "fake_unloadModule1"
