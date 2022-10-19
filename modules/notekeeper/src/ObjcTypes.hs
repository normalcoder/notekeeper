module ObjcTypes
( Id
, Class
, Sel
, Method
, Imp
, TypeEncoding
, NSString
) where

import Foreign.Ptr
import Foreign.C.String

type Id = Ptr ()
type Class = Ptr ()
type Sel = Ptr ()
type Method = Ptr ()
type Imp = Ptr ()
type TypeEncoding = CString
type NSString = Ptr ()
