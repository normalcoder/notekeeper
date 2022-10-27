module UiKitHelpers
( onEvent
, normal
, custom
, system
, touchUpInside
, setTitle
, newButton
-- , setFrame
-- , addSubview
) where

import ObjcMsg
import ObjcHelpers
import ObjcMsgHelpers
import ObjcTypes
import ObjcMsgOps
import ObjcMixStorage
import Foreign
import Foreign.C.String
import System.Random

chars = ['a' .. 'z']

getRandomAlphanumericString n = do
 nums <- sequence $ take n $ cycle [randomIO]
 return $ map ((chars !!) . (`mod` length chars)) nums

onEvent mixStorage control controlEvent action = do
 methodName <- getRandomAlphanumericString 10
 mix ReplaceResult Replace mixStorage control methodName (NoRet $ \_ _ _ -> action)
 getSelByName methodName >>= \actSel -> ("addTarget:action:forControlEvents:", [control, actSel, touchUpInside]) <.@@. control

setTitle control state t = getNsString t >>= \t -> ("setTitle:forState:", [t, state]) <.@@. control

newButton = ("buttonWithType:", system) <.@ "class" @| "UIButton"

-- setFrame v f = ("setFrame:", f) <.#. v

-- addSubview v b = ("addSubview:", b) <.@. v


-- UIControlStateNormal = 0
normal = nullPtr

-- UIButtonTypeCustom = 0
custom = nullPtr
-- UIButtonTypeSystem = 1
system = nullPtr `plusPtr` 1

-- UIControlEventTouchUpInside = 1 <<  6,
touchUpInside = nullPtr `plusPtr` (2^6)
