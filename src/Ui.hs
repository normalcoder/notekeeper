module Ui
( createUi
) where

import Objc
import UiKit
import Foreign.Ptr
-- import View.View

import Gcd

import Control.Concurrent
import Control.Concurrent.MVar
import Data.IORef
import Control.Monad
import Prelude hiding ((<*))
import Data.List

import Foreign.Storable

foreign import ccall unsafe "&kCAFillModeForwards" kCAFillModeForwards :: Ptr Id

foreign import ccall safe "startCapturing" c_startCapturing :: IO ()


startCapturing = do
 c_startCapturing

manyColors = take 20 $ cycle ["blueColor", "redColor", "greenColor", "grayColor", "lightGrayColor", "darkGrayColor", "brownColor"]


createUi :: Id -> IO ()
createUi vc = do
 -- rootView <- "view" @<. vc

 -- q <- build v1Spec
 -- v <- build $ overlap $ do
 --  capture >>= tags

 -- v <- mkUiView  -- "new" @| "UIView"

 -- (Superview rootView) `addSubviewAndPin` (Subview $ rootUiView q)


 -- registerSubclass "NSObject" "AnimDel" $
 --  [ (InstanceMethod, "animationDidStop:finished:", \_ _ _ -> pure nullPtr)
 --  ]
 -- -- v1 <- check

 -- startCapturing

 -- v <- "view" @<. vc

 -- createList v [["blackColor"], ["cyanColor"], ["redColor", "greenColor"], manyColors]
 
 pure ()

 -- q <- "new" @| "UIView"
 -- setBackgroundColor' "redColor" q
 -- addSubview' (Superview v) (Subview q) (\_ -> (100, 100, 100, 100))
 -- animateT (translate (-90,-90)) q
 -- forkIO $ do
 --  threadDelay $ 5*10^6
 --  onMainThread $ animateT (rotate $ pi/4) q



listWidth = 200
rowHeight = 30

imageWidth = 20
imageHeight = 20
imageRightSpace = 10
imageLeftSpace = 10

labelLeftSpace = 10

-- createImagePicker vc = do
--  mixAfter vc "viewWillAppear:" $ NoRet $ \_ _ _ -> do
--   showImagePicker vc
--   print "open "
--  --mixAfter vc "viewDidAppear:" $ NoRet $ \_ _ _ -> do
--  -- showImagePicker vc

setBackgroundColor' c v = do
 ("setBackgroundColor:", c @| "UIColor") <@. v
 pure ()

createList v rows = do
 list <- "new" @| "UIView"
 addSubview' (Superview v) (Subview list) (\(_,_,w,_) -> (w - listWidth, 100, listWidth, rowHeight*(fromIntegral $ length rows)))
 expansion <- newEmptyMVar
 mapM_ (uncurry $ createRow expansion v list) $ zip [0..] rows

createRow expansion mainView list i rowData = do
 row <- "new" @| "UIView"
 addSubview' (Superview list) (Subview row) (\_ -> (0, rowHeight*(fromIntegral i), listWidth, rowHeight))

 label <- "new" @| "UILabel"
 ("setTextAlignment:", ptrInt 2) <.@. label
 ("setText:", getNsString $ head rowData) <@. label
 addSubview' (Superview row) (Subview label) (\_ -> (labelLeftSpace, 0, listWidth - labelLeftSpace - imageLeftSpace - imageWidth - imageRightSpace, rowHeight))

 -- mapM (createImage row) $ zip (map Left [0..]) $ lastN 8 rowData
 images <- mapM (createImage row) $ zip (map Left [0..]) $ lastN 8 rowData


 started <- newMVar False

 onTap started row $ do
  e <- tryTakeMVar expansion
  case e of
   Just (t, fold, j) -> do
    if i == j
    then do
     print $ "again: " ++ show i
     killThread t

     let
      animate img i j = do
       print (i,j)
       t <- imgTransform mainView row img (i,j)
       animateT t img

     otherImages <- mapM (createImage row) $ zip (cycle $ map Right [0..3]) $ takeButN 8 rowData

     let imgGroups = zipWithRevInds $ chunks 4 $ otherImages ++ images

     mapM_ (\(i,g) -> mapM_ (\(j,img) -> animate img i j) $ zipWithRevInds g) imgGroups

    else do
     killThread t
     fold
     fold <- expand label images
     t <- forkIO $ threadDelay (200*10^6) >> (onMainThread $ fold >> tryTakeMVar expansion >> pure ())
     putMVar expansion $ (t, fold, i)
   _ -> do
    fold <- expand label images
    t <- forkIO $ threadDelay (200*10^6) >> (onMainThread $ fold >> tryTakeMVar expansion >> pure ())
    putMVar expansion $ (t, fold, i)

  -- fold <- expand label images
  -- t <- forkIO $ threadDelay (200*10^6) >> (onMainThread $ fold >> tryTakeMVar expansion >> pure ())
  -- tappedAgain <- fmap join $ traverse (\(t, fold, j) -> killThread t >>
  --  if i /= j then fold >> pure Nothing else pure (Just j)) =<< tryTakeMVar expansion
  -- case tappedAgain of
  --  Just i -> do
  --   print $ "again: " ++ show i
  --   killThread t

  --   let
  --    animate img i j = do
  --     print (i,j)
  --     -- animateT idT img

  --   let imgGroups = zip [0..] $ chunks 4 images
  --   mapM_ (\(i,g) -> mapM_ (\(j,img) -> animate img i j) $ zip [0..] g) imgGroups

  --  _ -> pure ()
  -- putMVar expansion $ (t, fold, i)

takeButN n = reverse . drop n . reverse
lastN n = foldl' (const . drop 1) <*> drop n

zipWithRevInds = zipWithRev [0..]
zipWithRev inds = (\(is,xs) -> zip (reverse is) xs) . unzip . zip inds

space = 5

convert from to p = do
 ("convertPoint:toView:", p, to) %<.%@. from

imgTransform mainView row img (i,j) = do
 (_,_,a0,_) <- "bounds" #<. img
 (_,_,w,h) <- "bounds" #<. mainView
 let a = (w - 5*space)/4
 let coord i = space + a/2 + (space + a)*i
 let (x,y) = (coord j, coord i)
 (x0,y0) <- convert row mainView =<< ("center" %<. img)
 pure $ scale (a/a0) `mul` translate (x - x0, y - y0)

onTap started v act = do
 -- mixAfter v "touchesBegan:withEvent:" $ NoRet $ \_ _ (touches:_) -> do
 --  putMVar started True

 mixAfter v "touchesEnded:withEvent:" $ NoRet $ \_ _ (touches:_) -> do
  t <- "anyObject" @<. touches
  -- inside <- isInside t v
  -- isStarted <- takeMVar started
  -- when (inside && isStarted) act
  act
  -- putMVar started False

isInside t v = do
 -- print 1
 (x,y) <- ("locationInView:", v) %<.@. t
 -- let (x,y) = (0,0)
 -- print 2
 (_,_,w,h) <- "bounds" #<. v
 -- print 3
 pure $ x <= w && y <= h

animateT t v = do
 print $ "animateT: " ++ show v
 l <- "layer" @<. v
 a <- "animation" @| "CABasicAnimation"
 ("setKeyPath:", getNsString "transform") <@. a
 ("setFromValue:", ("valueWithCATransform3D:", "transform" *<. l) <* "class" @| "NSValue") <@. a
 ("setToValue:", ("valueWithCATransform3D:", t) <.* "class" @| "NSValue") <@. a
 ("setDuration:", 0.25) <.:. a

 ("setFillMode:", peek kCAFillModeForwards) <@. a
 ("setRemovedOnCompletion:", ptrBool False) <.@. a
 

 k <- getNsString "animateT"
 o <- "new" @| "AnimDel"
 mixAfter o "animationDidStop:finished:" $ NoRet $ \_ _ _ -> do
  unmixLast o "animationDidStop:finished:"
  setTransform t v
  print $ "animationDidStop:finished: " ++ show v
  ("removeAnimationForKey:", k) <.@. l
  "release" @<. o
  pure ()
 ("setDelegate:", o) <.@. a

 ("addAnimation:forKey:", [a, k]) <.@@. l
 pure ()

expand label images = do
 animate offsetT (offsetT $ length images - 1)
 -- animate (const idT) (offsetT $ length images - 1)
 pure $ animate transformForI idT
 where
  animate imgT labelT = do
   mapM_ (\(i, image) -> animateT (imgT i) image) $ zip [0..] images
   animateT labelT label


-- offset i = setTransform . offsetT
offsetT i = translate (-(fromIntegral i)*(imageLeftSpace + imageWidth), 0)

-- on folded tap: expand new, fold old
-- on expanded tap: open photos
-- on expanded after 2 seconds: fold

tForI i = case i of
 Left i -> transformForI i
 Right i -> offsetT i

createImage row (i, imageData) = do
 image <- "new" @| "UIImageView"
 setTransform (tForI i) image
 ("setBackgroundColor:", imageData @| "UIColor") <@. image
 addSubview' (Superview row) (Subview image) (\_ -> (listWidth - imageRightSpace - imageWidth, (rowHeight - imageHeight)/2, imageWidth, imageHeight))
 pure image

setTransform t v = do
 ("setTransform:", t) <.* "layer" @<. v
 pure ()
transformForI i = head . drop i . map rotate $ cycle [-pi/18, pi/32, -pi/10]
translate (x,y) = Transform3D 1 0 0 0  0 1 0 0  0 0 1 0  x y 0 1
idT = Transform3D 1 0 0 0  0 1 0 0  0 0 1 0  0 0 0 1
rotate a = Transform3D (cos a) (-(sin a)) 0 0  ((sin a)) (cos a) 0 0  0 0 1 0  0 0 0 1
scale k = Transform3D k 0 0 0  0 k 0 0  0 0 1 0  0 0 0 1

mul :: Transform3D -> Transform3D -> Transform3D
mul a b = Transform3D
 ((m11 a)*(m11 b) + (m12 a)*(m21 b) + (m13 a)*(m31 b) + (m14 a)*(m41 b))
 ((m11 a)*(m12 b) + (m12 a)*(m22 b) + (m13 a)*(m32 b) + (m14 a)*(m42 b))
 ((m11 a)*(m13 b) + (m12 a)*(m23 b) + (m13 a)*(m33 b) + (m14 a)*(m43 b))
 ((m11 a)*(m14 b) + (m12 a)*(m24 b) + (m13 a)*(m34 b) + (m14 a)*(m44 b))
 ((m21 a)*(m11 b) + (m22 a)*(m21 b) + (m23 a)*(m31 b) + (m24 a)*(m41 b))
 ((m21 a)*(m12 b) + (m22 a)*(m22 b) + (m23 a)*(m32 b) + (m24 a)*(m42 b))
 ((m21 a)*(m13 b) + (m22 a)*(m23 b) + (m23 a)*(m33 b) + (m24 a)*(m43 b))
 ((m21 a)*(m14 b) + (m22 a)*(m24 b) + (m23 a)*(m34 b) + (m24 a)*(m44 b))
 ((m31 a)*(m11 b) + (m32 a)*(m21 b) + (m33 a)*(m31 b) + (m34 a)*(m41 b))
 ((m31 a)*(m12 b) + (m32 a)*(m22 b) + (m33 a)*(m32 b) + (m34 a)*(m42 b))
 ((m31 a)*(m13 b) + (m32 a)*(m23 b) + (m33 a)*(m33 b) + (m34 a)*(m43 b))
 ((m31 a)*(m14 b) + (m32 a)*(m24 b) + (m33 a)*(m34 b) + (m34 a)*(m44 b))
 ((m41 a)*(m11 b) + (m42 a)*(m21 b) + (m43 a)*(m31 b) + (m44 a)*(m41 b))
 ((m41 a)*(m12 b) + (m42 a)*(m22 b) + (m43 a)*(m32 b) + (m44 a)*(m42 b))
 ((m41 a)*(m13 b) + (m42 a)*(m23 b) + (m43 a)*(m33 b) + (m44 a)*(m43 b))
 ((m41 a)*(m14 b) + (m42 a)*(m24 b) + (m43 a)*(m34 b) + (m44 a)*(m44 b))

chunks n xs = takeWhile (not . null) $ unfoldr (Just . splitAt n) xs

----storage

--data Storage =
-- Storage
-- { _tags :: Vector Tag
-- , _images :: Map Tag (Vector Image)
-- }

--data Image =
-- Image
-- { _file :: File
-- , _done :: Bool
-- }

--newtype File = File String
