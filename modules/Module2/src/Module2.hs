module Module2 () where

foreign export ccall loadModule2 :: IO ()
foreign export ccall unloadModule2 :: IO ()

loadModule2 = do
 print "real_loadModule2"
 print "!!!one more print from real module2"

unloadModule2 = do
 print $ "real_unloadModule2"
