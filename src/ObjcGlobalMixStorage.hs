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

mix needReplaceResult mixOrder = Mix.mix needReplaceResult mixOrder globalMixStorage
mixBefore = Mix.mixBefore globalMixStorage
mixAfter = Mix.mixAfter globalMixStorage
mixReplace = Mix.mixReplace globalMixStorage
unmix toRemove = Mix.unmix toRemove globalMixStorage
unmixFirst = Mix.unmixFirst globalMixStorage
unmixLast = Mix.unmixLast globalMixStorage
