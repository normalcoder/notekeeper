module Tree
( Tree(..)
, zipTree
, zipTree3
) where

data Tree a = Node a [Tree a] deriving (Show)

instance Functor Tree where
 fmap f (Node x ts) = Node (f x) (map (fmap f) ts)

instance Foldable Tree where
 foldMap f (Node x ts) = f x <> foldMap (foldMap f) ts

instance Traversable Tree where
 traverse f (Node x ts) = Node <$> f x <*> traverse (traverse f) ts

zipTree (Node x xs) (Node y ys) = Node (x,y) $ map (uncurry zipTree) $ zip xs ys
zipTree3 (Node x xs) (Node y ys) (Node z zs) = Node (x,y,z) $ map (\(x,y,z) -> zipTree3 x y z) $ zip3 xs ys zs
