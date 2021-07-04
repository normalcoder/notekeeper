{-

@<
@<.
%<
%.<.
#<

@ - object
% - cgfloat2
# - cgfloat4
& - affinetransform
* - transform3d
! - float2
^ - double2
-- !! - float
: - double

example:
#<.@.
(#) (<) (.@) (.)

# - result will be CGFloat4
< - send message to object
.@ - pass unIOed argument with message
. - object is unIOed

-}

module ObjcMsgOps
( (@|), op_class

, (@<), op_IOed_obj
, (@<.), op_unIOed_obj

, (<@), op_apply_IOed_arg_IOed_obj
, (<@.), op_apply_IOed_arg_unIOed_obj
, (<.@), op_apply_unIOed_arg_IOed_obj
, (<.@.), op_apply_unIOed_arg_unIOed_obj

, (<.@@), op_apply_unIOed_args_IOed_obj
, (<.@@.), op_apply_unIOed_args_unIOed_obj

, (</), op_apply_Int_IOed_arg_IOed_obj
, (</.), op_apply_Int_IOed_arg_unIOed_obj
, (<./), op_apply_Int_unIOed_arg_IOed_obj
, (<./.), op_apply_Int_unIOed_arg_unIOed_obj

, (%<), op_stret_CGFloat2_IOed_obj
, (%<.), op_stret_CGFloat2_unIOed_obj

, (#<), op_stret_CGFloat4_IOed_obj
, (#<.), op_stret_CGFloat4_unIOed_obj

, (&<), op_stret_CGFloat6_IOed_obj
, (&<.), op_stret_CGFloat6_unIOed_obj

, (*<), op_stret_CGFloat16_IOed_obj
, (*<.), op_stret_CGFloat16_unIOed_obj

, (!<), op_stret_Float2_IOed_obj
, (!<.), op_stret_Float2_unIOed_obj

, (^<), op_stret_Double2_IOed_obj
, (^<.), op_stret_Double2_unIOed_obj


, (%<@), op_stret_CGFloat2_apply_IOed_arg_IOed_obj
, (%<@.), op_stret_CGFloat2_apply_IOed_arg_unIOed_obj
, (%<.@), op_stret_CGFloat2_apply_unIOed_arg_IOed_obj
, (%<.@.), op_stret_CGFloat2_apply_unIOed_arg_unIOed_obj

, (%<.%@.), op_stret_CGFloat2_apply_unIOed_arg_CGFloat2_unIOed_arg_ptr_unIOed_obj

, (#<@), op_stret_CGFloat4_apply_IOed_arg_IOed_obj
, (#<@.), op_stret_CGFloat4_apply_IOed_arg_unIOed_obj
, (#<.@), op_stret_CGFloat4_apply_unIOed_arg_IOed_obj
, (#<.@.), op_stret_CGFloat4_apply_unIOed_arg_unIOed_obj

, (#<.%@@@.), op_stret_CGFloat4_apply_unIOed_arg_CGFloat2_unIOed_arg_ptr_unIOed_arg_ptr_unIOed_arg_ptr_unIOed_obj

, (&<@), op_stret_CGFloat6_apply_IOed_arg_IOed_obj
, (&<@.), op_stret_CGFloat6_apply_IOed_arg_unIOed_obj
, (&<.@), op_stret_CGFloat6_apply_unIOed_arg_IOed_obj
, (&<.@.), op_stret_CGFloat6_apply_unIOed_arg_unIOed_obj

, (*<@), op_stret_CGFloat16_apply_IOed_arg_IOed_obj
, (*<@.), op_stret_CGFloat16_apply_IOed_arg_unIOed_obj
, (*<.@), op_stret_CGFloat16_apply_unIOed_arg_IOed_obj
, (*<.@.), op_stret_CGFloat16_apply_unIOed_arg_unIOed_obj

, (!<@), op_stret_Float2_apply_IOed_arg_IOed_obj
, (!<@.), op_stret_Float2_apply_IOed_arg_unIOed_obj
, (!<.@), op_stret_Float2_apply_unIOed_arg_IOed_obj
, (!<.@.), op_stret_Float2_apply_unIOed_arg_unIOed_obj

, (^<@), op_stret_Double2_apply_IOed_arg_IOed_obj
, (^<@.), op_stret_Double2_apply_IOed_arg_unIOed_obj
, (^<.@), op_stret_Double2_apply_unIOed_arg_IOed_obj
, (^<.@.), op_stret_Double2_apply_unIOed_arg_unIOed_obj

, (<%), op_stapply_CGFloat2_IOed_arg_IOed_obj
, (<%.), op_stapply_CGFloat2_IOed_arg_unIOed_obj
, (<.%), op_stapply_CGFloat2_unIOed_arg_IOed_obj
, (<.%.), op_stapply_CGFloat2_unIOed_arg_unIOed_obj

, (<#), op_stapply_CGFloat4_IOed_arg_IOed_obj
, (<#.), op_stapply_CGFloat4_IOed_arg_unIOed_obj
, (<.#), op_stapply_CGFloat4_unIOed_arg_IOed_obj
, (<.#.), op_stapply_CGFloat4_unIOed_arg_unIOed_obj

, (<&), op_stapply_CGFloat6_IOed_arg_IOed_obj
, (<&.), op_stapply_CGFloat6_IOed_arg_unIOed_obj
, (<.&), op_stapply_CGFloat6_unIOed_arg_IOed_obj
, (<.&.), op_stapply_CGFloat6_unIOed_arg_unIOed_obj

, (<*), op_stapply_CGFloat16_IOed_arg_IOed_obj
, (<*.), op_stapply_CGFloat16_IOed_arg_unIOed_obj
, (<.*), op_stapply_CGFloat16_unIOed_arg_IOed_obj
, (<.*.), op_stapply_CGFloat16_unIOed_arg_unIOed_obj

, (<!), op_stapply_Float2_IOed_arg_IOed_obj
, (<!.), op_stapply_Float2_IOed_arg_unIOed_obj
, (<.!), op_stapply_Float2_unIOed_arg_IOed_obj
, (<.!.), op_stapply_Float2_unIOed_arg_unIOed_obj

, (<^), op_stapply_Double2_IOed_arg_IOed_obj
, (<^.), op_stapply_Double2_IOed_arg_unIOed_obj
, (<.^), op_stapply_Double2_unIOed_arg_IOed_obj
, (<.^.), op_stapply_Double2_unIOed_arg_unIOed_obj

--, (<!!), op_stapply_Float_IOed_arg_IOed_obj
--, (<!!.), op_stapply_Float_IOed_arg_unIOed_obj
--, (<.!!), op_stapply_Float_unIOed_arg_IOed_obj
--, (<.!!.), op_stapply_Float_unIOed_arg_unIOed_obj

, (<:), op_stapply_Double_IOed_arg_IOed_obj
, (<:.), op_stapply_Double_IOed_arg_unIOed_obj
, (<.:), op_stapply_Double_unIOed_arg_IOed_obj
, (<.:.), op_stapply_Double_unIOed_arg_unIOed_obj

, (<+), op_stapply_CGFloat_IOed_arg_IOed_obj
, (<+.), op_stapply_CGFloat_IOed_arg_unIOed_obj
, (<.+), op_stapply_CGFloat_unIOed_arg_IOed_obj
, (<.+.), op_stapply_CGFloat_unIOed_arg_unIOed_obj

) where

import Foreign.Ptr

import Prelude hiding ((<*))
import ObjcTypes
import ObjcMsg
import ObjcMsgSt

type ClassName = String
type SelName = String

op_class :: SelName -> ClassName -> IO Id
op_class selName className = objc_msgSend_class className selName []
(@|) = op_class
infixr 5 @|

op_IOed_obj :: SelName -> IO Id -> IO Id
op_unIOed_obj :: SelName -> Id -> IO Id

op_IOed_obj = (=<<) . op_unIOed_obj
(@<) = op_IOed_obj
infixr 5 @<
op_unIOed_obj selName obj = objc_msgSend obj selName []
(@<.) = op_unIOed_obj
infixr 5 @<.


op_apply_IOed_arg_IOed_obj :: (SelName, IO Id) -> IO Id -> IO Id
op_apply_IOed_arg_unIOed_obj :: (SelName, IO Id) -> Id -> IO Id
op_apply_unIOed_arg_IOed_obj :: (SelName, Id) -> IO Id -> IO Id
op_apply_unIOed_arg_unIOed_obj :: (SelName, Id) -> Id -> IO Id

op_apply_IOed_arg_IOed_obj (selName, argAct) objAct = argAct >>= \arg -> op_apply_unIOed_arg_IOed_obj (selName, arg) objAct
(<@) = op_apply_IOed_arg_IOed_obj
infixr 5 <@
op_apply_IOed_arg_unIOed_obj (selName, argAct) obj = argAct >>= \arg -> op_apply_unIOed_arg_unIOed_obj (selName, arg) obj
(<@.) = op_apply_IOed_arg_unIOed_obj
infixr 5 <@.
op_apply_unIOed_arg_IOed_obj = (=<<) . op_apply_unIOed_arg_unIOed_obj
(<.@) = op_apply_unIOed_arg_IOed_obj
infixr 5 <.@
op_apply_unIOed_arg_unIOed_obj (selName, arg) obj = objc_msgSend obj selName [arg]
(<.@.) = op_apply_unIOed_arg_unIOed_obj
infixr 5 <.@.


op_apply_unIOed_args_IOed_obj :: (SelName, [Id]) -> IO Id -> IO Id
op_apply_unIOed_args_unIOed_obj :: (SelName, [Id]) -> Id -> IO Id

op_apply_unIOed_args_IOed_obj = (=<<) . op_apply_unIOed_args_unIOed_obj
(<.@@) = op_apply_unIOed_args_IOed_obj
infixr 5 <.@@
op_apply_unIOed_args_unIOed_obj (selName, args) obj = objc_msgSend obj selName args
(<.@@.) = op_apply_unIOed_args_unIOed_obj
infixr 5 <.@@.


op_apply_Int_IOed_arg_IOed_obj (selName, argAct) objAct = argAct >>= \arg -> op_apply_Int_unIOed_arg_IOed_obj (selName, arg) objAct
(</) = op_apply_Int_IOed_arg_IOed_obj
infixr 5 </
op_apply_Int_IOed_arg_unIOed_obj (selName, argAct) obj = argAct >>= \arg -> op_apply_Int_unIOed_arg_unIOed_obj (selName, arg) obj
(</.) = op_apply_Int_IOed_arg_unIOed_obj
infixr 5 </.
op_apply_Int_unIOed_arg_IOed_obj = (=<<) . op_apply_Int_unIOed_arg_unIOed_obj
(<./) = op_apply_Int_unIOed_arg_IOed_obj
infixr 5 <./
op_apply_Int_unIOed_arg_unIOed_obj (selName, arg) obj = objc_msgSend obj selName [nullPtr `plusPtr` arg]
(<./.) = op_apply_Int_unIOed_arg_unIOed_obj
infixr 5 <./.


op_stret_CGFloat2_IOed_obj :: SelName -> (IO Id) -> IO CGFloat2
op_stret_CGFloat2_unIOed_obj :: SelName -> Id -> IO CGFloat2

op_stret_CGFloat2_IOed_obj = (=<<) . op_stret_CGFloat2_unIOed_obj
(%<) = op_stret_CGFloat2_IOed_obj
infixr 5 %<
op_stret_CGFloat2_unIOed_obj = flip objc_msgSend_stret_CGFloat2
(%<.) = op_stret_CGFloat2_unIOed_obj
infixr 5 %<.

op_stret_CGFloat4_IOed_obj = (=<<) . op_stret_CGFloat4_unIOed_obj
(#<) = op_stret_CGFloat4_IOed_obj
infixr 5 #<
op_stret_CGFloat4_unIOed_obj = flip objc_msgSend_stret_CGFloat4
(#<.) = op_stret_CGFloat4_unIOed_obj
infixr 5 #<.

op_stret_CGFloat6_IOed_obj = (=<<) . op_stret_CGFloat6_unIOed_obj
(&<) = op_stret_CGFloat6_IOed_obj
infixr 5 &<
op_stret_CGFloat6_unIOed_obj = flip objc_msgSend_stret_CGFloat6
(&<.) = op_stret_CGFloat6_unIOed_obj
infixr 5 &<.

op_stret_CGFloat16_IOed_obj = (=<<) . op_stret_CGFloat16_unIOed_obj
(*<) = op_stret_CGFloat16_IOed_obj
infixr 5 *<
op_stret_CGFloat16_unIOed_obj = flip objc_msgSend_stret_CGFloat16
(*<.) = op_stret_CGFloat16_unIOed_obj
infixr 5 *<.

op_stret_Float2_IOed_obj = (=<<) . op_stret_Float2_unIOed_obj
(!<) = op_stret_Float2_IOed_obj
infixr 5 !<
op_stret_Float2_unIOed_obj = flip objc_msgSend_stret_Float2
(!<.) = op_stret_Float2_unIOed_obj
infixr 5 !<.

op_stret_Double2_IOed_obj = (=<<) . op_stret_Double2_unIOed_obj
(^<) = op_stret_Double2_IOed_obj
infixr 5 ^<
op_stret_Double2_unIOed_obj = flip objc_msgSend_stret_Double2
(^<.) = op_stret_Double2_unIOed_obj
infixr 5 ^<.


op_stret_CGFloat2_apply_IOed_arg_IOed_obj :: (SelName, IO Id) -> IO Id -> IO CGFloat2
op_stret_CGFloat2_apply_IOed_arg_unIOed_obj :: (SelName, IO Id) -> Id -> IO CGFloat2
op_stret_CGFloat2_apply_unIOed_arg_IOed_obj :: (SelName, Id) -> IO Id -> IO CGFloat2
op_stret_CGFloat2_apply_unIOed_arg_unIOed_obj :: (SelName, Id) -> Id -> IO CGFloat2

op_stret_CGFloat2_apply_IOed_arg_IOed_obj (selName, argAct) objAct = argAct >>= \arg -> op_stret_CGFloat2_apply_unIOed_arg_IOed_obj (selName, arg) objAct
(%<@) = op_stret_CGFloat2_apply_IOed_arg_IOed_obj
infixr 5 %<@
op_stret_CGFloat2_apply_IOed_arg_unIOed_obj (selName, argAct) obj = argAct >>= \arg -> op_stret_CGFloat2_apply_unIOed_arg_unIOed_obj (selName, arg) obj
(%<@.) = op_stret_CGFloat2_apply_IOed_arg_unIOed_obj
infixr 5 %<@.
op_stret_CGFloat2_apply_unIOed_arg_IOed_obj = (=<<) . op_stret_CGFloat2_apply_unIOed_arg_unIOed_obj
(%<.@) = op_stret_CGFloat2_apply_unIOed_arg_IOed_obj
infixr 5 %<.@
op_stret_CGFloat2_apply_unIOed_arg_unIOed_obj (selName, arg) obj = objc_msgSend_stret_CGFloat2_apply_ptr obj selName arg
(%<.@.) = op_stret_CGFloat2_apply_unIOed_arg_unIOed_obj
infixr 5 %<.@.

op_stret_CGFloat2_apply_unIOed_arg_CGFloat2_unIOed_arg_ptr_unIOed_obj (selName, arg1, arg2) obj = objc_msgSend_stret_CGFloat2_apply_CGFloat2_apply_ptr obj selName arg1 arg2
(%<.%@.) = op_stret_CGFloat2_apply_unIOed_arg_CGFloat2_unIOed_arg_ptr_unIOed_obj
infixr 5 %<.%@.

op_stret_CGFloat4_apply_IOed_arg_IOed_obj (selName, argAct) objAct = argAct >>= \arg -> op_stret_CGFloat4_apply_unIOed_arg_IOed_obj (selName, arg) objAct
(#<@) = op_stret_CGFloat4_apply_IOed_arg_IOed_obj
infixr 5 #<@
op_stret_CGFloat4_apply_IOed_arg_unIOed_obj (selName, argAct) obj = argAct >>= \arg -> op_stret_CGFloat4_apply_unIOed_arg_unIOed_obj (selName, arg) obj
(#<@.) = op_stret_CGFloat4_apply_IOed_arg_unIOed_obj
infixr 5 #<@.
op_stret_CGFloat4_apply_unIOed_arg_IOed_obj = (=<<) . op_stret_CGFloat4_apply_unIOed_arg_unIOed_obj
(#<.@) = op_stret_CGFloat4_apply_unIOed_arg_IOed_obj
infixr 5 #<.@
op_stret_CGFloat4_apply_unIOed_arg_unIOed_obj (selName, arg) obj = objc_msgSend_stret_CGFloat4_apply_ptr obj selName arg
(#<.@.) = op_stret_CGFloat4_apply_unIOed_arg_unIOed_obj
infixr 5 #<.@.

op_stret_CGFloat4_apply_unIOed_arg_CGFloat2_unIOed_arg_ptr_unIOed_arg_ptr_unIOed_arg_ptr_unIOed_obj (selName, arg1, arg2, arg3, arg4) obj = objc_msgSend_stret_CGFloat4_apply_CGFloat2_apply_ptr_apply_ptr_apply_ptr obj selName arg1 arg2 arg3 arg4
(#<.%@@@.) = op_stret_CGFloat4_apply_unIOed_arg_CGFloat2_unIOed_arg_ptr_unIOed_arg_ptr_unIOed_arg_ptr_unIOed_obj
infixr 5 #<.%@@@.


op_stret_CGFloat6_apply_IOed_arg_IOed_obj (selName, argAct) objAct = argAct >>= \arg -> op_stret_CGFloat6_apply_unIOed_arg_IOed_obj (selName, arg) objAct
(&<@) = op_stret_CGFloat6_apply_IOed_arg_IOed_obj
infixr 5 &<@
op_stret_CGFloat6_apply_IOed_arg_unIOed_obj (selName, argAct) obj = argAct >>= \arg -> op_stret_CGFloat6_apply_unIOed_arg_unIOed_obj (selName, arg) obj
(&<@.) = op_stret_CGFloat6_apply_IOed_arg_unIOed_obj
infixr 5 &<@.
op_stret_CGFloat6_apply_unIOed_arg_IOed_obj = (=<<) . op_stret_CGFloat6_apply_unIOed_arg_unIOed_obj
(&<.@) = op_stret_CGFloat6_apply_unIOed_arg_IOed_obj
infixr 5 &<.@
op_stret_CGFloat6_apply_unIOed_arg_unIOed_obj (selName, arg) obj = objc_msgSend_stret_CGFloat6_apply_ptr obj selName arg
(&<.@.) = op_stret_CGFloat6_apply_unIOed_arg_unIOed_obj
infixr 5 &<.@.

op_stret_CGFloat16_apply_IOed_arg_IOed_obj (selName, argAct) objAct = argAct >>= \arg -> op_stret_CGFloat16_apply_unIOed_arg_IOed_obj (selName, arg) objAct
(*<@) = op_stret_CGFloat16_apply_IOed_arg_IOed_obj
infixr 5 *<@
op_stret_CGFloat16_apply_IOed_arg_unIOed_obj (selName, argAct) obj = argAct >>= \arg -> op_stret_CGFloat16_apply_unIOed_arg_unIOed_obj (selName, arg) obj
(*<@.) = op_stret_CGFloat16_apply_IOed_arg_unIOed_obj
infixr 5 *<@.
op_stret_CGFloat16_apply_unIOed_arg_IOed_obj = (=<<) . op_stret_CGFloat16_apply_unIOed_arg_unIOed_obj
(*<.@) = op_stret_CGFloat16_apply_unIOed_arg_IOed_obj
infixr 5 *<.@
op_stret_CGFloat16_apply_unIOed_arg_unIOed_obj (selName, arg) obj = objc_msgSend_stret_CGFloat16_apply_ptr obj selName arg
(*<.@.) = op_stret_CGFloat16_apply_unIOed_arg_unIOed_obj
infixr 5 *<.@.

op_stret_Float2_apply_IOed_arg_IOed_obj (selName, argAct) objAct = argAct >>= \arg -> op_stret_Float2_apply_unIOed_arg_IOed_obj (selName, arg) objAct
(!<@) = op_stret_Float2_apply_IOed_arg_IOed_obj
infixr 5 !<@
op_stret_Float2_apply_IOed_arg_unIOed_obj (selName, argAct) obj = argAct >>= \arg -> op_stret_Float2_apply_unIOed_arg_unIOed_obj (selName, arg) obj
(!<@.) = op_stret_Float2_apply_IOed_arg_unIOed_obj
infixr 5 !<@.
op_stret_Float2_apply_unIOed_arg_IOed_obj = (=<<) . op_stret_Float2_apply_unIOed_arg_unIOed_obj
(!<.@) = op_stret_Float2_apply_unIOed_arg_IOed_obj
infixr 5 !<.@
op_stret_Float2_apply_unIOed_arg_unIOed_obj (selName, arg) obj = objc_msgSend_stret_Float2_apply_ptr obj selName arg
(!<.@.) = op_stret_Float2_apply_unIOed_arg_unIOed_obj
infixr 5 !<.@.

op_stret_Double2_apply_IOed_arg_IOed_obj (selName, argAct) objAct = argAct >>= \arg -> op_stret_Double2_apply_unIOed_arg_IOed_obj (selName, arg) objAct
(^<@) = op_stret_Double2_apply_IOed_arg_IOed_obj
infixr 5 ^<@
op_stret_Double2_apply_IOed_arg_unIOed_obj (selName, argAct) obj = argAct >>= \arg -> op_stret_Double2_apply_unIOed_arg_unIOed_obj (selName, arg) obj
(^<@.) = op_stret_Double2_apply_IOed_arg_unIOed_obj
infixr 5 ^<@.
op_stret_Double2_apply_unIOed_arg_IOed_obj = (=<<) . op_stret_Double2_apply_unIOed_arg_unIOed_obj
(^<.@) = op_stret_Double2_apply_unIOed_arg_IOed_obj
infixr 5 ^<.@
op_stret_Double2_apply_unIOed_arg_unIOed_obj (selName, arg) obj = objc_msgSend_stret_Double2_apply_ptr obj selName arg
(^<.@.) = op_stret_Double2_apply_unIOed_arg_unIOed_obj
infixr 5 ^<.@.


op_stapply_CGFloat2_IOed_arg_IOed_obj :: (SelName, IO CGFloat2) -> IO Id -> IO Id
op_stapply_CGFloat2_IOed_arg_unIOed_obj :: (SelName, IO CGFloat2) -> Id -> IO Id
op_stapply_CGFloat2_unIOed_arg_IOed_obj :: (SelName, CGFloat2) -> IO Id -> IO Id
op_stapply_CGFloat2_unIOed_arg_unIOed_obj :: (SelName, CGFloat2) -> Id -> IO Id

op_stapply_CGFloat2_IOed_arg_IOed_obj (selName, argAct) objAct = argAct >>= \arg -> op_stapply_CGFloat2_unIOed_arg_IOed_obj (selName, arg) objAct
(<%) = op_stapply_CGFloat2_IOed_arg_IOed_obj
infixr 5 <%
op_stapply_CGFloat2_IOed_arg_unIOed_obj (selName, argAct) obj = argAct >>= \arg -> op_stapply_CGFloat2_unIOed_arg_unIOed_obj (selName, arg) obj
(<%.) = op_stapply_CGFloat2_IOed_arg_unIOed_obj
infixr 5 <%.
op_stapply_CGFloat2_unIOed_arg_IOed_obj = (=<<) . op_stapply_CGFloat2_unIOed_arg_unIOed_obj
(<.%) = op_stapply_CGFloat2_unIOed_arg_IOed_obj
infixr 5 <.%
op_stapply_CGFloat2_unIOed_arg_unIOed_obj (selName, arg) obj = objc_msgSend_stapply_CGFloat2 obj selName arg
(<.%.) = op_stapply_CGFloat2_unIOed_arg_unIOed_obj
infixr 5 <.%.

op_stapply_CGFloat4_IOed_arg_IOed_obj (selName, argAct) objAct = argAct >>= \arg -> op_stapply_CGFloat4_unIOed_arg_IOed_obj (selName, arg) objAct
(<#) = op_stapply_CGFloat4_IOed_arg_IOed_obj
infixr 5 <#
op_stapply_CGFloat4_IOed_arg_unIOed_obj (selName, argAct) obj = argAct >>= \arg -> op_stapply_CGFloat4_unIOed_arg_unIOed_obj (selName, arg) obj
(<#.) = op_stapply_CGFloat4_IOed_arg_unIOed_obj
infixr 5 <#.
op_stapply_CGFloat4_unIOed_arg_IOed_obj = (=<<) . op_stapply_CGFloat4_unIOed_arg_unIOed_obj
(<.#) = op_stapply_CGFloat4_unIOed_arg_IOed_obj
infixr 5 <.#
op_stapply_CGFloat4_unIOed_arg_unIOed_obj (selName, arg) obj = objc_msgSend_stapply_CGFloat4 obj selName arg
(<.#.) = op_stapply_CGFloat4_unIOed_arg_unIOed_obj
infixr 5 <.#.

op_stapply_CGFloat6_IOed_arg_IOed_obj (selName, argAct) objAct = argAct >>= \arg -> op_stapply_CGFloat6_unIOed_arg_IOed_obj (selName, arg) objAct
(<&) = op_stapply_CGFloat6_IOed_arg_IOed_obj
infixr 5 <&
op_stapply_CGFloat6_IOed_arg_unIOed_obj (selName, argAct) obj = argAct >>= \arg -> op_stapply_CGFloat6_unIOed_arg_unIOed_obj (selName, arg) obj
(<&.) = op_stapply_CGFloat6_IOed_arg_unIOed_obj
infixr 5 <&.
op_stapply_CGFloat6_unIOed_arg_IOed_obj = (=<<) . op_stapply_CGFloat6_unIOed_arg_unIOed_obj
(<.&) = op_stapply_CGFloat6_unIOed_arg_IOed_obj
infixr 5 <.&
op_stapply_CGFloat6_unIOed_arg_unIOed_obj (selName, arg) obj = objc_msgSend_stapply_CGFloat6 obj selName arg
(<.&.) = op_stapply_CGFloat6_unIOed_arg_unIOed_obj
infixr 5 <.&.

op_stapply_CGFloat16_IOed_arg_IOed_obj (selName, argAct) objAct = argAct >>= \arg -> op_stapply_CGFloat16_unIOed_arg_IOed_obj (selName, arg) objAct
(<*) = op_stapply_CGFloat16_IOed_arg_IOed_obj
infixr 5 <*
op_stapply_CGFloat16_IOed_arg_unIOed_obj (selName, argAct) obj = argAct >>= \arg -> op_stapply_CGFloat16_unIOed_arg_unIOed_obj (selName, arg) obj
(<*.) = op_stapply_CGFloat16_IOed_arg_unIOed_obj
infixr 5 <*.
op_stapply_CGFloat16_unIOed_arg_IOed_obj = (=<<) . op_stapply_CGFloat16_unIOed_arg_unIOed_obj
(<.*) = op_stapply_CGFloat16_unIOed_arg_IOed_obj
infixr 5 <.*
op_stapply_CGFloat16_unIOed_arg_unIOed_obj (selName, arg) obj = objc_msgSend_stapply_CGFloat16 obj selName arg
(<.*.) = op_stapply_CGFloat16_unIOed_arg_unIOed_obj
infixr 5 <.*.

op_stapply_Float2_IOed_arg_IOed_obj (selName, argAct) objAct = argAct >>= \arg -> op_stapply_Float2_unIOed_arg_IOed_obj (selName, arg) objAct
(<!) = op_stapply_Float2_IOed_arg_IOed_obj
infixr 5 <!
op_stapply_Float2_IOed_arg_unIOed_obj (selName, argAct) obj = argAct >>= \arg -> op_stapply_Float2_unIOed_arg_unIOed_obj (selName, arg) obj
(<!.) = op_stapply_Float2_IOed_arg_unIOed_obj
infixr 5 <!.
op_stapply_Float2_unIOed_arg_IOed_obj = (=<<) . op_stapply_Float2_unIOed_arg_unIOed_obj
(<.!) = op_stapply_Float2_unIOed_arg_IOed_obj
infixr 5 <.!
op_stapply_Float2_unIOed_arg_unIOed_obj (selName, arg) obj = objc_msgSend_stapply_Float2 obj selName arg
(<.!.) = op_stapply_Float2_unIOed_arg_unIOed_obj
infixr 5 <.!.

op_stapply_Double2_IOed_arg_IOed_obj (selName, argAct) objAct = argAct >>= \arg -> op_stapply_Double2_unIOed_arg_IOed_obj (selName, arg) objAct
(<^) = op_stapply_Double2_IOed_arg_IOed_obj
infixr 5 <^
op_stapply_Double2_IOed_arg_unIOed_obj (selName, argAct) obj = argAct >>= \arg -> op_stapply_Double2_unIOed_arg_unIOed_obj (selName, arg) obj
(<^.) = op_stapply_Double2_IOed_arg_unIOed_obj
infixr 5 <^.
op_stapply_Double2_unIOed_arg_IOed_obj = (=<<) . op_stapply_Double2_unIOed_arg_unIOed_obj
(<.^) = op_stapply_Double2_unIOed_arg_IOed_obj
infixr 5 <.^
op_stapply_Double2_unIOed_arg_unIOed_obj (selName, arg) obj = objc_msgSend_stapply_Double2 obj selName arg
(<.^.) = op_stapply_Double2_unIOed_arg_unIOed_obj
infixr 5 <.^.

--op_stapply_Float_IOed_arg_IOed_obj (selName, argAct) objAct = argAct >>= \arg -> op_stapply_Float_unIOed_arg_IOed_obj (selName, arg) objAct
--(<!!) = op_stapply_Float_IOed_arg_IOed_obj
--infixr 5 <!!
--op_stapply_Float_IOed_arg_unIOed_obj (selName, argAct) obj = argAct >>= \arg -> op_stapply_Float_unIOed_arg_unIOed_obj (selName, arg) obj
--(<!!.) = op_stapply_Float_IOed_arg_unIOed_obj
--infixr 5 <!!.
--op_stapply_Float_unIOed_arg_IOed_obj = (=<<) . op_stapply_Float_unIOed_arg_unIOed_obj
--(<.!!) = op_stapply_Float_unIOed_arg_IOed_obj
--infixr 5 <.!!
--op_stapply_Float_unIOed_arg_unIOed_obj (selName, arg) obj = objc_msgSend_stapply_Float obj selName arg
--(<.!!.) = op_stapply_Float_unIOed_arg_unIOed_obj
--infixr 5 <.!!.

op_stapply_Double_IOed_arg_IOed_obj (selName, argAct) objAct = argAct >>= \arg -> op_stapply_Double_unIOed_arg_IOed_obj (selName, arg) objAct
(<:) = op_stapply_Double_IOed_arg_IOed_obj
infixr 5 <:
op_stapply_Double_IOed_arg_unIOed_obj (selName, argAct) obj = argAct >>= \arg -> op_stapply_Double_unIOed_arg_unIOed_obj (selName, arg) obj
(<:.) = op_stapply_Double_IOed_arg_unIOed_obj
infixr 5 <:.
op_stapply_Double_unIOed_arg_IOed_obj = (=<<) . op_stapply_Double_unIOed_arg_unIOed_obj
(<.:) = op_stapply_Double_unIOed_arg_IOed_obj
infixr 5 <.:
op_stapply_Double_unIOed_arg_unIOed_obj (selName, arg) obj = objc_msgSend_stapply_Double obj selName arg
(<.:.) = op_stapply_Double_unIOed_arg_unIOed_obj
infixr 5 <.:.

op_stapply_CGFloat_IOed_arg_IOed_obj (selName, argAct) objAct = argAct >>= \arg -> op_stapply_CGFloat_unIOed_arg_IOed_obj (selName, arg) objAct
(<+) = op_stapply_Double_IOed_arg_IOed_obj
infixr 5 <+
op_stapply_CGFloat_IOed_arg_unIOed_obj (selName, argAct) obj = argAct >>= \arg -> op_stapply_CGFloat_unIOed_arg_unIOed_obj (selName, arg) obj
(<+.) = op_stapply_CGFloat_IOed_arg_unIOed_obj
infixr 5 <+.
op_stapply_CGFloat_unIOed_arg_IOed_obj = (=<<) . op_stapply_CGFloat_unIOed_arg_unIOed_obj
(<.+) = op_stapply_CGFloat_unIOed_arg_IOed_obj
infixr 5 <.+
op_stapply_CGFloat_unIOed_arg_unIOed_obj (selName, arg) obj = objc_msgSend_stapply_CGFloat obj selName arg
(<.+.) = op_stapply_CGFloat_unIOed_arg_unIOed_obj
infixr 5 <.+.

--(<./) = op_stapply_Long_unIOed_arg_unIOed_obj
--(<.=) = op_stapply_Bool_unIOed_arg_unIOed_obj
--(<.~) = op_stapply_Float_unIOed_arg_unIOed_obj
--(<.:) = op_stapply_Double_unIOed_arg_unIOed_obj
--(<.+) = op_stapply_CGFloat_unIOed_arg_unIOed_obj

--(<.-) = op_stapply_Float_unIOed_arg_unIOed_obj
--(<.\) = op_stapply_Float_unIOed_arg_unIOed_obj
--(<.|) = op_stapply_Float_unIOed_arg_unIOed_obj

