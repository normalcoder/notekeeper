module Gcd
( onMainThread
, onMainThread1
, onMainThread2
, getBackgroundQueue
) where

import Foreign.Ptr
import Foreign.C.Types

type GcdQueue = Ptr ()
type GcdDispatchFunction = FunPtr (IO ())

onMainThread1 :: IO () -> IO ()
onMainThread1 a = do
 pure ()

onMainThread2 a = do
 f <- toFunPtr1 a
 let mainQueue = c__dispatch_main_q
 c_dispatch_async_f mainQueue nullPtr f
 pure f

onMainThread a = do
 f <- toFunPtr1 a
 let mainQueue = c__dispatch_main_q
 c_dispatch_async_f mainQueue nullPtr f
 pure ()

-- dispatch_async_f(dispatch_get_main_queue(), void *context, dispatch_function_t work)

foreign import ccall "wrapper" toFunPtr1 :: IO () -> IO GcdDispatchFunction

--foreign import ccall "dispatch_get_main_queue" c_dispatch_get_main_queue :: IO GcdQueue

foreign import ccall "&_dispatch_main_q" c__dispatch_main_q :: GcdQueue
foreign import ccall "dispatch_async_f" c_dispatch_async_f :: GcdQueue -> Ptr () -> GcdDispatchFunction -> IO GcdQueue

foreign import ccall "dispatch_get_global_queue" c_dispatch_get_global_queue :: CInt -> CUInt -> IO (Ptr ())

c_DISPATCH_QUEUE_PRIORITY_BACKGROUND = -32768

getBackgroundQueue = c_dispatch_get_global_queue c_DISPATCH_QUEUE_PRIORITY_BACKGROUND 0
