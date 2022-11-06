module ObjcGlobalMixStorage
( mix
, mixBefore
, mixAfter
, mixReplace
, unmix
, unmixFirst
, unmixLast
) where

import System.IO.Unsafe
-- import ObjcMixStorage
import qualified ObjcMixStorage as Mix

globalMixStorage :: Mix.MixStorage
{-# NOINLINE globalMixStorage #-}
globalMixStorage = unsafePerformIO Mix.create

mix needReplaceResult tag mixOrder = Mix.mix needReplaceResult mixOrder tag globalMixStorage
mixBefore tag = Mix.mixBefore tag globalMixStorage
mixAfter tag = Mix.mixAfter tag globalMixStorage
mixReplace tag = Mix.mixReplace tag globalMixStorage
unmix toRemove = Mix.unmix toRemove globalMixStorage
unmixFirst = Mix.unmixFirst globalMixStorage
unmixLast = Mix.unmixLast globalMixStorage
