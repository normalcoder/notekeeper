module Module1 () where

foreign export ccall loadModule1 :: IO ()
foreign export ccall unloadModule1 :: IO ()

loadModule1 = do
 print "real_loadModule1"
 print "!!!one more print from real module"

unloadModule1 = do
 print "real_unloadModule1"
