{-# language ScopedTypeVariables, DeriveAnyClass, DerivingStrategies #-}
-- {-# LANGUAGE DefaultSignatures, DeriveAnyClass #-}
module View.View
( ViewSpec(..)
, ViewSpecImpl(..)
, Kind(..)
, isContainer
, View(..)
, ViewTree
, Width(..)
, Height(..)
-- , Subviews(..)
, Direction(..)
, DesiredSize(..)
-- , IsVertical(..)
, build
, build1
, scroll
, stack
, stackH
, overlap
, text
, width
-- , rootUiView
-- , v1Spec
, view
) where

import GHC.Generics
import Control.DeepSeq

import Control.Monad
import Control.Applicative
import Data.Maybe

import Objc
import View.Label
import View.Image
import View.Color
import Tree

import UiKit

import Prelude hiding (Left, Right)

-- ViewSpecWithModel
-- Screen


data SOHandles = SOHandles deriving (Generic, NFData)

data View = View { _spec :: ViewSpecImpl, _viewTree :: ViewTree } deriving (Show)

type ViewTree = Tree UIView

data ViewSpecImpl = ViewSpecImpl {
 _kind :: Kind,
 _color :: Color,
 _desiredSize :: DesiredSize
 -- _padding :: Padding,
 -- _transform :: Transform3D,
 -- _priority :: Priority,
 -- _constraints :: Constraints,
 -- _intrinsicSize :: IntrinsicSize,
 -- _isScreen :: IsScreen,
 -- _pathComps :: [PathComp]
} deriving (Generic, NFData, Show)

data Kind =
   Container (Maybe Tappable) Direction [ViewSpecImpl]
 | Scroll ViewSpecImpl
 | Label Font (Maybe LineCount) BreakMode (GetInfo String)
 | Image Aspect (GetInfo UIImage)
 -- | Image (Maybe (Width, Height)) Aspect (GetInfo UIImage)
 deriving (Generic, NFData, Show)

data Tappable = Tappable (IO ()) deriving (Generic)

instance NFData Tappable where
 rnf _ = ()

newtype GetInfo a = GetInfo (IO a) deriving (Generic)

instance NFData (GetInfo a) where
 rnf _ = ()

instance Show (GetInfo a) where
 show _ = "GetInfo"

instance Show Tappable where
 show _ = "Tappable"

{-
instance Read (GetInfo a) where
 readsPrec _ "GetInfo" = [(GetInfo (pure ()), "")]

instance Read Tappable where
 readsPrec _ "Tappable" = [(Tappable (pure ()), "")]
-}

newtype PathComp = PathComp String deriving stock (Generic, Show) deriving anyclass (NFData)

data Direction = Vertical | Horizontal | Overlap deriving (Generic, NFData, Eq, Show)
data IsScreen = Screen | NotScreen deriving (Generic, NFData, Show)

data Insets = Insets Left Right Top Bottom deriving (Generic, NFData, Show)
newtype Left = Left CGFloat deriving stock (Generic, Show) deriving anyclass (NFData)
newtype Right = Right CGFloat deriving stock (Generic, Show) deriving anyclass (NFData)
newtype Top = Top CGFloat deriving stock (Generic, Show) deriving anyclass (NFData)
newtype Bottom = Bottom CGFloat deriving stock (Generic, Show) deriving anyclass (NFData)


newtype Priority = Priority Double deriving stock (Generic, Show) deriving anyclass (NFData)
data Padding = Padding (Maybe Left) (Maybe Right) (Maybe Top) (Maybe Bottom) deriving (Generic, NFData, Show)
data Constraints = Constraints (Maybe MinWidth) (Maybe MaxWidth) (Maybe MinHeight) (Maybe MaxHeight) deriving (Generic, NFData, Show)
data IntrinsicSize = IntrinsicSize (Maybe Width) (Maybe Height) deriving (Generic, NFData, Show)
data DesiredSize = DesiredSize (Maybe Width) (Maybe Height) deriving (Generic, NFData, Show)
newtype Width = Width CGFloat deriving stock (Generic, Show, Eq, Ord) deriving anyclass (NFData)
newtype Height = Height CGFloat deriving stock (Generic, Show, Eq, Ord) deriving anyclass (NFData)
newtype MinWidth = MinWidth CGFloat deriving stock (Generic, Show, Eq, Ord) deriving anyclass (NFData)
newtype MaxWidth = MaxWidth CGFloat deriving stock (Generic, Show, Eq, Ord) deriving anyclass (NFData)
newtype MinHeight = MinHeight CGFloat deriving stock (Generic, Show, Eq, Ord) deriving anyclass (NFData)
newtype MaxHeight = MaxHeight CGFloat deriving stock (Generic, Show, Eq, Ord) deriving anyclass (NFData)

instance Semigroup DesiredSize where
 (DesiredSize w1 h1) <> (DesiredSize w2 h2) = DesiredSize (w1 <|> w2) (h1 <|> h2)

isContainer kind = case kind of
 Container _ _ _ -> True
 _ -> False

noPadding = Padding Nothing Nothing Nothing Nothing
noSize = DesiredSize Nothing Nothing
idT = Transform3D 1 0 0 0  0 1 0 0  0 0 1 0  0 0 0 1

-- data ViewSpec q = ViewSpec { _impl :: ViewSpecImpl } | Tmp [ViewSpecImpl] deriving (Show)
data ViewSpec q = Tmp DesiredSize [ViewSpecImpl] deriving (Generic, NFData, Show)

-- data Subviews a = Subviews Insets IsVertical [V a]
-- data Subviews a = Subviews Direction [V a]

 -- v <- build $ do
 --  stack $ do
 --   text "title"
 --   text "subtitle"

scroll :: ViewSpec a -> ViewSpec a
--scroll (Tmp _) = undefined
scroll (Tmp _ (impl:_)) = Tmp noSize [ViewSpecImpl (Scroll impl) white noSize]

stack = stack_ Vertical
stackH = stack_ Horizontal
overlap = stack_ Overlap

width :: Double -> ViewSpec a
width w = Tmp (DesiredSize (Just $ Width w) Nothing) []

stack_ :: Direction -> ViewSpec a -> ViewSpec a
stack_ d (Tmp s vs) = Tmp noSize [ViewSpecImpl (Container Nothing d vs) white s]
-- stack_ _ spec = undefined

text :: String -> ViewSpec a
text s = Tmp noSize [ViewSpecImpl (Label defaultFont Nothing TruncatingTail (GetInfo $ pure s)) black noSize]


view :: Color -> ViewSpec a
view color = Tmp noSize [ViewSpecImpl (Container Nothing Vertical []) color noSize]

instance Functor ViewSpec where
 fmap f mx = do
  x <- mx
  pure $ f x

instance Applicative ViewSpec where
 pure _ = Tmp noSize []
 mf <*> mx = do
  f <- mf
  x <- mx
  pure $ f x
 x *> y = case (x,y) of
  (Tmp size1 xs, Tmp size2 ys) -> Tmp (size1 <> size2) $ xs ++ ys
--  (Tmp xs, ViewSpec y) -> Tmp $ xs ++ [y]
--  (ViewSpec x, Tmp ys) -> Tmp $ [x] ++ ys
--  (ViewSpec x, ViewSpec y) -> Tmp [x, y]

instance Monad ViewSpec where
 x >>= f = x >> f undefined
 (>>) = (*>)


-- newtype Tags = Tags { _tags :: [Tag] }
-- data Tag = Tag { _title :: Title, _images :: [Image] }


-- tags = list _tags $ do
--  -- withList _tags
--  tag

-- tag = stackH $ do
--  title ^ do
--   with _title
--  overlap ^ do
--   withElems (take 8 . _images) $ \i -> do 
--    image ^ do
--     rotate $ [30, 60, 15] !! i
--  onTap $ do
--   open tagDetails
--   openAutoMatch tagDetails ^ do
--    transition1
--    transition2
--    ...
--   openMatchById tagDetails ^ do
--    transition1 "view1"
--    transition2 "view2"
--    ...

-- open:
--  vs = old screen views
--  ws = new screen views
--  common = vs /\ ws -- find match for common
--  addSubviews common to new screen (remove from old) + add (ws - common)
--  animate forward ws + animate show new background

-- close:
--  vs = old screen views
--  ws = new screen views
--  common = vs /\ ws -- find match for common
--  addSubviews common to old screen (remove from new) + ...
--  animate backward ws + animate hide new background



-- tagDetails = stack $ do
--  title ^ do
--   with _title
--  grid _images ^ do
--   image 
 


-- expand = do


   -- mapM (\(x,i) -> image & withIndex i >> rotate x) $ zip [30, 60, 15] [0..]


  --  image & rotate 30
  --  image & rotate 60
  --  image & rotate 15

  -- expandingStackH $ do
   

-- cell = do
--  stackH $ do
--   image $ pure ()
--   stack $ do
--    title $ pure ()
--    stackH $ do
--     subtitle $ pure ()
--     year $ do
--      priority 1

-- check = undefined
-- v1Spec = do
--  ViewSpec $ V ()
--   Container
--   red
--   (Constraints Nothing Nothing Nothing Nothing)
--   (IntrinsicSize Nothing Nothing)
--   (Priority 1)
--   (Offset 0 0)
--   (Subviews
--    (Insets (Left 0) (Right 0) (Top 0) (Bottom 0))
--    Vertical
--    [s1, s2])
--   Screen
--   []

-- s1 = do
--  V ()
--   Container
--   green
--   (Constraints Nothing Nothing Nothing Nothing)
--   (IntrinsicSize Nothing Nothing)
--   (Priority 1)
--   (Offset 0 0)
--   (Subviews
--    (Insets (Left 0) (Right 0) (Top 0) (Bottom 0))
--    Vertical
--    [])
--   Screen
--   []

-- s2 = do
--  V ()
--   Container
--   blue
--   (Constraints Nothing Nothing Nothing Nothing)
--   (IntrinsicSize Nothing Nothing)
--   (Priority 1)
--   (Offset 0 0)
--   (Subviews
--    (Insets (Left 0) (Right 0) (Top 0) (Bottom 0))
--    Vertical
--    [])
--   Screen
--   []

--build1 :: ViewSpec q -> IO View
--build1 spec@(Tmp _ (v:_)) = do
build1 spec = do
 -- rawView <- "new" @| "UIView"
 -- pure $ View v $ Node (UIView rawView) []
 View v <$> r
 where
 r = build1' v
 Tmp _ (v:_) = spec
{-
build1 spec@(Tmp _ (v:_)) = do
 putStrLn $ "!!build1 spec: " ++ show spec
 View v <$> build1' v
-}

--build1' :: ViewSpecImpl -> IO ViewTree
--build1' (ViewSpecImpl kind color size) = do

build1' spec = build kind
 where
 build vv = do
  v <- "new" @| r
  pure $ Node (UIView v) []

  where
  r = case vv of
   Scroll _ -> "UILabel"
    

 ViewSpecImpl kind color size = spec
{-
 case kind of
 Label font lineCount breakMode (GetInfo value) -> do
  v <- "new" @| "UILabel"
  ("setText:", getNsString =<< value) <@. v
  ("setNumberOfLines:", fromMaybe 0 $ _rawLineCount <$> lineCount) <./. v
  pure $ Node (UIView v) []
 Image aspect (GetInfo img) -> do
  v <- "new" @| "UIImageView"
  ("setImage:", _rawUiImage <$> img) <@. v
  pure $ Node (UIView v) []
 Container onTap dir vs -> do
  c <- "new" @| "UIView"
  ("setBackgroundColor:", uiColor color) <@. c
  views <- traverse build' vs
  traverse (\(Node (UIView v) _) -> Superview c `addSubview` Subview v) views
  pure $ Node (UIView c) views
 Scroll v -> do
  c <- "new" @| "UIScrollView"
  viewInTree@(Node (UIView v) _) <- build' v
  Superview c `addSubview` Subview v
  pure $ Node (UIView c) [viewInTree]
-}

build :: ViewSpec q -> IO View
build spec@(Tmp _ (v:_)) = do
 putStrLn $ "!!build spec: " ++ show spec
 View v <$> build' v

build' :: ViewSpecImpl -> IO ViewTree
build' (ViewSpecImpl kind color size) = case kind of
 Label font lineCount breakMode (GetInfo value) -> do
  v <- "new" @| "UILabel"
  ("setText:", getNsString =<< value) <@. v
  ("setNumberOfLines:", fromMaybe 0 $ _rawLineCount <$> lineCount) <./. v
  pure $ Node (UIView v) []
 Image aspect (GetInfo img) -> do
  v <- "new" @| "UIImageView"
  ("setImage:", _rawUiImage <$> img) <@. v
  pure $ Node (UIView v) []
 Container onTap dir vs -> do
  c <- "new" @| "UIView"
  ("setBackgroundColor:", uiColor color) <@. c
  views <- traverse build' vs
  traverse (\(Node (UIView v) _) -> Superview c `addSubview` Subview v) views
  pure $ Node (UIView c) views
 Scroll v -> do
  c <- "new" @| "UIScrollView"
  viewInTree@(Node (UIView v) _) <- build' v
  Superview c `addSubview` Subview v
  pure $ Node (UIView c) [viewInTree]


 -- ("setBackgroundColor:", uiColor color) <@. v

 --   Container (Maybe Tappable) Direction [ViewSpecImpl]
 -- | Label Font (Maybe LineCount) BreakMode (IO String)
 -- | Image (Maybe (Width, Height)) Aspect (IO UIImage)

 -- _kind :: Kind,
 -- _color :: Color,
 -- _padding :: Padding,
 -- _transform :: Transform3D

-- build (ViewSpec (V _ k color constr intrSize (Subviews insets isVertical subviewSpecs) isScreen pathComps)) = do

--  v <- "new" @| "UIView"
--  ("setBackgroundColor:", uiColor color) <@. v
--  subviews <- traverse (pure . unview <=< build . ViewSpec) subviewSpecs

--  mapM_ (addSubview (Superview v) . Subview . _uiView . _view) subviews

--  pure $ View $ V (UIView v) k color constr intrSize (Subviews insets isVertical subviews) isScreen pathComps

-- rootUiView = undefined
-- rootUiView (View v) = _uiView . _view $ v
 -- subviews' <- pure . Subviews insets isVertical $ mapM (pure . unview =<< build . map ViewSpec) subviews
 -- pure $ View $ V (UIView v) k color constr subviews' isScreen pathComps

-- layout :: View -> IO ()
-- layout (View (V v k color constr subveiws)) = case k of
--  Container -> 
