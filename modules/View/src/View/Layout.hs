{-# language DeriveAnyClass, DerivingStrategies #-}

module View.Layout
( addSubviewAndPin
, unpin
) where

import GHC.Generics
import Control.DeepSeq

import Control.Monad
import Data.Foldable
import Data.List

import Objc
import UiKitHelpers
import UiKit
import View.View
import Tree

import Data.IORef


addSubviewAndPin v@(Superview superview) subviewDef@(View spec (Node subview@(UIView rawSubview) _)) = do
 addSubview v (Subview rawSubview)
 setFrameToBounds
 mixAfter superview "layoutSubviews" $ NoRet $ \_ _ _ -> setFrameToBounds
 where
  setFrameToBounds = do
   f@(x,y,w,h) <- "bounds" #<. superview
   when (not . isContainer $ _kind spec) $ do
    safeSetFrame f subview

   -- widthRest <- newIORef
   layoutSubviews ((w,h), subviewDef)

unpin superview = unmixLast superview "layoutSubviews"

{-
| text1 |       |
| text1 | text2 |
| text1 |       |
-----------------
|       |       |

textSizeForWidth :: String -> Double -> IO (Double, Double)

layout :: ViewSpecImpl -> ViewSpecImpl

layout :: View -> IO View
layout (View spec _)



layoutSubviews
 traverse tree to calc all sizes
 

 case kind of
  Container _ d specImpls -> do
     desiredWidths = map _desiredWidth specImpls
     restWidth = containerWidth - sum desiredWidths
     freeViews = filter isFree specImpls
     freeViewsCount = length freeViews
     widthForSingleFree = restWidth / freeViewsCount
     
     
  Scroll specImpl -> do
  Label f lineCount breakMode getStr -> do
  Image aspect getImg -> do
  
-}



-- data LayoutType a = HasSize (LayoutSize a) | Unlimited deriving (Show)
data LayoutSize a = Resolved a | Suggested a | Unlimited deriving (Generic, NFData, Show, Read, Ord, Eq)


isResolved (Resolved _) = True
isResolved _ = False


split p xs = (filter p xs, filter (not . p) xs)
mapZip f xs = zip xs $ map f xs

{-
vertical container:
1. conainer width resolved
-}

widths :: LayoutSize Width -> ViewSpecImpl -> Tree (LayoutSize Width)
widths layoutType (ViewSpecImpl kind _ (DesiredSize desiredWidth _)) = case kind of
 Label _ _ _ _ -> simple
 Image _ _ -> simple
 Scroll (ViewSpecImpl kind _ (DesiredSize desiredWidth _)) -> case kind of
  Container _ d specImpls -> case d of
   Vertical -> Node width $ map (widths width) specImpls
   Horizontal -> Node width $ map (widths Unlimited) specImpls
   Overlap -> error "scroll should wrap Vertical or Horizontal container (not Overlap)"
  _ -> error "scroll should wrap a container"
 Container _ d specImpls -> case d of
  Vertical -> r
   where
   r
    | null resolved = error "null resolved"
    | otherwise = Node maxWidth $ map (snd . snd) $ sortOn fst $ resolved ++ recalculatedNotResolved
    
   (resolved, notResolved) = split (\(_,(_,(Node w _))) -> isResolved w) $ zip [0..] $ mapZip (widths width) specImpls
   
   (_,(_,(Node maxWidth _))) = maximumBy (\(_,(_,(Node w1 _))) (_,(_,(Node w2 _))) -> compare w1 w2) resolved
   
   recalculatedNotResolved = map (\(i, (spec, _)) -> (i, (spec, widths maxWidth spec))) notResolved

  Horizontal -> error "Horizontal unimplemented"
  Overlap -> error "Overlap unimplemented"
 where
 simple = Node width []
 width = case layoutType of
  resolved@(Resolved _) -> resolved
  suggested@(Suggested _) -> case desiredWidth of
   Just w -> Suggested w
   Nothing -> suggested
  Unlimited -> Unlimited
{-
widthTree layoutSize (ViewSpecImpl kind _ (DesiredSize w _)) = case (kind, w, layoutSize) of
 !!! Label, Image
 (Just w, Suggested suggestedW) -> Node w []
 (Nothing, Suggested suggestedW) -> Node suggestedW []
 (Just w, Resolved resolvedW) -> Node resolvedW []
 (Nothing, Resolved resolvedW) -> Node resolvedW []
 
 !!! Container _ d specImpls, stack
 
 childrenWidths = map (widthTree layoutSize) specImpls
 (resolved, suggested) = split isResolved childrenWidths
 
 | null resolved =
  | layoutSize is Resolved = Node layoutSize $ map toResolved suggested
  | otherwise = Node layoutSize childrenWidth
 | otherwise = let newSize = maximum resolved in Node $ resolved ++ map (widthTree newSize) suggestedSpecImpls

 !!! Container, stackH
 
 n = length specImpls
 w_n = case layoutSize of
  Resolved w -> Suggested w/n
  Suggested w -> Suggested w/n
  Unlimited -> Unlimited
 childrenWidths = map (widthTree w_n) specImpls
 Node layoutSize childrenWidth

 !!! Scroll
 
 set Unlimited for corresponding direction
-}

type Size = (Double, Double)
type TreeSize = Tree Size

calcTextSize' :: ViewSpecImpl -> Tree (LayoutSize Width) -> IO (Tree (CGFloat, CGFloat))
calcTextSize' = undefined

calcTextSize :: ViewSpecImpl -> Width -> IO (Width, Height)
calcTextSize = undefined
-- textSize text (Font (FontName name) (FontSize fontSize)) width



origins = undefined

layoutSubviews ((w,h), q@(View spec@(ViewSpecImpl kind color (DesiredSize desiredWidth desiredHeight)) views@(Node view subviews))) = do
{-
 print $ "!!!layoutSubviews: " ++ show q
 let ws = widths (Resolved $ Width w) spec
 print $ "!!!width calculated: " ++ show ws
 sizes <- calcTextSize' spec ws
 print $ "!!!sizes calculated by calcTextSize': " ++ show sizes
 traverse_ setFrame $ zipTree3 views (origins sizes) sizes
 where
 setFrame (view, (x,y), (w,h)) = safeSetFrame (x,y,w,h) view
-}

 case kind of
  Container _ d specImpls -> do
--   map _desiredSize specImpls
  
   sizes <- traverse layoutView $ zip3 [0..] specImpls subviews
   traverse layoutSubviews $ zip sizes $ zipWith View specImpls subviews
   pure ()
   where
   layoutView (i, viewSpec, (Node v _)) = do
    safeSetFrame (x, y, width, height) v
    pure (width, height)
    where
    x = if horizontal then fromIntegral i * width else 0
    y = if vertical then fromIntegral i * height else 0
   width = if horizontal then w / fromIntegral n else w
   height = if vertical then h / fromIntegral n else h
   horizontal = d == Horizontal
   vertical = d == Vertical
  Scroll specImpl -> do
   let subviewInTree@(Node subview _) = head subviews
   safeSetFrame (0, 0, w, h) subview
   setContentSize (0, 1000) (UIScrollView view)
   layoutSubviews ((w,h), View specImpl subviewInTree)
   pure ()
  -- Label Font (Maybe LineCount) BreakMode (IO String)
  Label f lineCount breakMode getStr -> do
   pure ()
  -- Image (Maybe (Width, Height)) Aspect (IO UIImage)
  Image aspect getImg -> do
   pure ()
 where
 n = length subviews
