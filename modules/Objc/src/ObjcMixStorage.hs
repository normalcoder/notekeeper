module ObjcMixStorage
( 
  MixStorage(..)
, create
, mix
, mixBefore
, mixAfter
, mixReplace
, unmix
, unmixFirst
, unmixLast
, WhichRemove(..)
, CommonCallFunc(..)
, MixTag(..)
, MixOrder(..)
, NeedReplaceResult(..)
) where

import ObjcTypes
import ObjcFunPtr
import ObjcHelpers
import ObjcMsg
import ObjcMsgHelpers
import ObjcClassManipulations

import Data.Map hiding (filter, map)
import qualified Data.Map as M
import Data.Maybe
import Control.Concurrent.MVar
import Foreign

data MixStorage = MixStorage (MVar Mixes)

data Mixes = Mixes (Map (Class, Sel) (Map Id MixCalls, OrigImplF)) deriving (Show)
data MixCalls = BeforeAndAfterCalls [Call] [Call] | ReplacingCalls [Call] deriving (Show)
data Call = Call { _callFunc :: CallFunc, _needReplaceResult :: NeedReplaceResult, _mixTag :: MixTag } deriving (Show)
data CallFunc = CallFunc (Id -> Sel -> [Id] -> IO Id)
instance Show CallFunc where
 show _ = "CallFunc"

newtype MixTag = MixTag Id deriving (Show, Eq)

data MixOrder = Before | After | Replace deriving (Show)
data NeedReplaceResult = ReplaceResult | DontReplaceResult deriving (Show, Eq)

data IsMixLatest = LatestMix | NotLatestMix deriving (Show)

data WhichRemove = RemoveFirst | RemoveLast | RemoveByTag MixTag deriving (Show)
data WasLastMixForClassRemoved = NotLastMixForClassWasRemoved | LastMixForClassWasRemoved OrigImplF deriving (Show)

type OrigImplF = Imp
type SelName = String

data CommonCallFunc = Ret (Id -> Sel -> [Id] -> IO Id) | NoRet (Id -> Sel -> [Id] -> IO ())

mixBefore = mix' Before
mixAfter = mix' After
mixReplace = mix' Replace

mix' = mix DontReplaceResult

mix :: NeedReplaceResult -> MixOrder -> MixTag -> MixStorage -> Id -> SelName -> CommonCallFunc -> IO ()
mix resultReplace order tag mixStorage obj selName commonCall = mixForRet resultReplace order tag mixStorage obj selName fixedNewImpl
 where
  fixedNewImpl = case commonCall of
   Ret newImpl -> newImpl
   NoRet newImpl -> \obj sel args -> newImpl obj sel args >> return nullPtr

mixForRet :: NeedReplaceResult -> MixOrder -> MixTag -> MixStorage -> Id -> SelName -> (Id -> Sel -> [Id] -> IO Id) -> IO ()
mixForRet resultReplace order tag (MixStorage mixesVar) obj selName newImpl = do
 sel <- getSelByName selName
 let argsCnt = noOfColonsInSelectorName selName

 cls <- getObjectClass obj
 (Mixes initialMixesMap) <- readMVar mixesVar

 let
  k = (cls, sel, obj)

  createMixedImpl :: Imp -> IO (Id -> Sel -> [Id] -> IO Id)
  createMixedImpl origImplF = return $ \obj sel args -> do
   (Mixes mixesMap) <- readMVar mixesVar

   let
    origImpl = fromFunPtr argsCnt origImplF

    calls = case M.lookup obj . fst . fromJust . M.lookup (cls, sel) $ mixesMap of
     Just (BeforeAndAfterCalls before after) -> before ++ origCall ++ after
     Just (ReplacingCalls replacing) -> replacing
     _ -> origCall
     where
      origCall = case origImplF == nullPtr of
       True -> []
       _ -> [Call (CallFunc origImpl) ReplaceResult tag]

   let (acts, replaces) = unzip $ map (\(Call (CallFunc f) replace tag) -> (f obj sel args, replace)) calls
   results <- sequence acts
   return $ fst . last . filter ((==ReplaceResult) . snd) $ zip results replaces

  createMix origImplF = do
   modifyMVar_ mixesVar $ \mixes -> return $ createNew k (CallFunc newImpl) resultReplace order tag origImplF mixes
   mixedImpl <- createMixedImpl origImplF
   toFunPtr argsCnt mixedImpl

  updateMix = modifyMVar_ mixesVar $ \mixes -> return $ updateWithImpl k (CallFunc newImpl) resultReplace order tag mixes

  isImplAlreadyReplaced = isJust $ M.lookup (cls, sel) initialMixesMap

 if isImplAlreadyReplaced
 then updateMix
 else replaceObjcMethod cls sel createMix

unmix :: WhichRemove -> MixStorage -> Id -> SelName -> IO ()
unmix whichRemove (MixStorage mixesVar) obj selName = do
 sel <- getSelByName selName
 cls <- getObjectClass obj
 mixes@(Mixes mixesMap) <- takeMVar mixesVar

 let (wasLastMixForClassRemoved, mixes') = deleteImpl (cls, sel, obj) whichRemove mixes

 case wasLastMixForClassRemoved of
  LastMixForClassWasRemoved origImplF -> replaceObjcMethod cls sel $ \_ -> return origImplF
  _ -> return ()

 putMVar mixesVar mixes'

unmixFirst = unmix RemoveFirst
unmixLast = unmix RemoveLast
unmixByTag = unmix . RemoveByTag

createNew (cls, sel, obj) newImpl resultReplace order tag origImplF (Mixes m) = Mixes $ M.insert (cls, sel) (M.singleton obj calls, origImplF) m
 where
  calls = newCalls newImpl resultReplace order tag

newCalls = updatedCalls $ BeforeAndAfterCalls [] []

updateWithImpl (cls, sel, obj) newImpl resultReplace order tag (Mixes m) = Mixes $ M.adjust f (cls, sel) m
 where
  f (callsMap, origImplF) = (M.alter g obj callsMap, origImplF)
  g (Just mixCalls) = Just $ updatedCalls mixCalls newImpl resultReplace order tag
  g _ = Just $ newCalls newImpl resultReplace order tag

updatedCalls mixCalls newImpl resultReplace order tag = case (mixCalls, order) of
 (BeforeAndAfterCalls before after, Before) -> BeforeAndAfterCalls (call:before) after
 (BeforeAndAfterCalls before after, After) -> BeforeAndAfterCalls before (after ++ [call])
 (ReplacingCalls replacing, Before) -> ReplacingCalls $ call:replacing
 (ReplacingCalls replacing, After) -> ReplacingCalls $ replacing ++ [call]
 _ -> ReplacingCalls $ [call]
 where
  call = Call newImpl resultReplace tag

deleteImpl (cls, sel, obj) whichRemove (Mixes mixesMap) = (status, Mixes mixesMap')
 where
  status = case M.lookup (cls, sel) mixesMap of
   Just (mixMap, origImplF) -> case M.lookup obj mixMap of
    Just (BeforeAndAfterCalls [_] []) -> lastCallStatus
    Just (BeforeAndAfterCalls [] [_]) -> lastCallStatus
    Just (ReplacingCalls [_]) -> lastCallStatus
    _ -> NotLastMixForClassWasRemoved
    where
     lastCallStatus = if isLastMixMapForThisClass then LastMixForClassWasRemoved origImplF else NotLastMixForClassWasRemoved
     isLastMixMapForThisClass = M.size mixMap == 1
   _ -> NotLastMixForClassWasRemoved

  mixesMap' = M.update f (cls, sel) mixesMap
  f (mixMap, origImplF) = case status of
   LastMixForClassWasRemoved _ -> Nothing
   _ -> Just (mixMap', origImplF)
   where
    mixMap' = M.update (Just . g) obj mixMap

  g (BeforeAndAfterCalls before []) = BeforeAndAfterCalls (removeFunc before) []
  g (BeforeAndAfterCalls [] after) = BeforeAndAfterCalls [] (removeFunc after)
  g (BeforeAndAfterCalls before after) = case whichRemove of
   RemoveFirst -> BeforeAndAfterCalls (tail before) after
   RemoveLast -> BeforeAndAfterCalls before (init after)
   RemoveByTag tag -> BeforeAndAfterCalls (removeByTag tag before) (removeByTag tag after)
  g (ReplacingCalls replacing) = ReplacingCalls (removeFunc replacing)

  removeFunc = case whichRemove of { RemoveFirst -> tail ; RemoveLast -> init ; RemoveByTag tag -> removeByTag tag }
  removeByTag tag = filter (\call -> _mixTag call == tag)

initial = Mixes M.empty

create = do
 v <- newMVar initial
 return $ MixStorage v
