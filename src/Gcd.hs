module Gcd
( onMainThread
) where

import Foreign.Ptr

type GcdQueue = Ptr ()
type GcdDispatchFunction = FunPtr (IO ())

onMainThread a = do
 f <- toFunPtr1 a
 let mainQueue = c__dispatch_main_q
 c_dispatch_async_f mainQueue nullPtr f
 return ()

-- dispatch_async_f(dispatch_get_main_queue(), void *context, dispatch_function_t work)

foreign import ccall "wrapper" toFunPtr1 :: IO () -> IO GcdDispatchFunction

--foreign import ccall "dispatch_get_main_queue" c_dispatch_get_main_queue :: IO GcdQueue

foreign import ccall "&_dispatch_main_q" c__dispatch_main_q :: GcdQueue
foreign import ccall "dispatch_async_f" c_dispatch_async_f :: GcdQueue -> Ptr () -> GcdDispatchFunction -> IO GcdQueue

