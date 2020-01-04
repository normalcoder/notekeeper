newtype Id a = Id a

instance Functor Id where
 fmap f (Id x) = Id $ f x

instance Applicative Id where
 pure x = Id x
 (Id f) <*> (Id x) = Id $ f x

instance Monad Id where
 (Id a) >>= f = f a




newtype ViewSpec = ViewSpec (V ())
newtype View = View (V UIView)
unview (View v) = v

newtype UIView = UIView { _uiView :: Id }

data V a = V {
 _view :: a,
 _kind :: Kind a,
 _color :: Color,
 _padding :: Padding,
 _transform :: Transform3D
 -- _priority :: Priority,
 -- _constraints :: Constraints,
 -- _intrinsicSize :: IntrinsicSize,
 -- _isScreen :: IsScreen,
 -- _pathComps :: [PathComp]
}

-- data Subviews a = Subviews Insets IsVertical [V a]
data Subviews a = Subviews Direction [V a]


-- build :: ViewSpec -> IO View
-- stack :: ViewList -> ViewSpec
-- text :: String -> ViewSpec

newtype ViewList = ViewList [ViewSpec]

data Kind a =
   Container (Maybe Tappable) Direction [V a]
 | Label Font (Maybe LineCount) BreakMode (IO String)
 | Image (Maybe (Width, Height)) Aspect (IO UIImage)

data Tappable = Tappable (IO ())

newtype PathComp = PathComp String

data Direction = Vertical | Horizontal | Overlap
data IsScreen = Screen | NotScreen

data Insets = Insets Left Right Top Bottom
newtype Left = Left CGFloat
newtype Right = Right CGFloat
newtype Top = Top CGFloat
newtype Bottom = Bottom CGFloat


newtype Priority = Priority Double
data Padding = Padding (Maybe Left) (Maybe Right) (Maybe Top) (Maybe Bottom)
data Constraints = Constraints (Maybe MinWidth) (Maybe MaxWidth) (Maybe MinHeight) (Maybe MaxHeight)
data IntrinsicSize = IntrinsicSize (Maybe Width) (Maybe Height)
newtype Width = Width CGFloat
newtype Height = Height CGFloat
newtype MinWidth = MinWidth CGFloat
newtype MaxWidth = MaxWidth CGFloat
newtype MinHeight = MinHeight CGFloat
newtype MaxHeight = MaxHeight CGFloat

type CGFloat = Double
type CGFloat2 = (CGFloat, CGFloat)
type CGFloat4 = (CGFloat, CGFloat, CGFloat, CGFloat)


instance Functor ViewList where
 fmap f (ViewList ss) = undefined

instance Applicative ViewList where
 pure x = undefined
 (<*>) = undefined

instance Monad ViewList where
 (>>=) = undefined
 (ViewList xs) >> (ViewList ys) = ViewList $ xs ++ ys
