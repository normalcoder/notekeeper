module AvHelpers
( authorized
, back
, portrait
, video
, high
, trueDepthCamera
, dualCamera
, telephotoCamera
, wideAngleCamera
, resizeAspectFill
) where

import Foreign
import Foreign.C.String
import System.IO.Unsafe

import ObjcTypes

-- AVAuthorizationStatusAuthorized = 3
authorized = nullPtr `plusPtr` 3

-- AVCaptureDevicePositionBack = 1
back = nullPtr `plusPtr` 1

-- AVCaptureVideoOrientationPortrait
portrait = nullPtr `plusPtr` 1

foreign import ccall "&AVMediaTypeVideo" c_AVMediaTypeVideo :: Ptr NSString
{-# NOINLINE video #-}
video = unsafePerformIO $ peek c_AVMediaTypeVideo

foreign import ccall "&AVCaptureSessionPresetHigh" c_AVCaptureSessionPresetHigh :: Ptr NSString
{-# NOINLINE high #-}
high = unsafePerformIO $ peek c_AVCaptureSessionPresetHigh

foreign import ccall "&AVCaptureDeviceTypeBuiltInTrueDepthCamera" c_AVCaptureDeviceTypeBuiltInTrueDepthCamera :: Ptr NSString
{-# NOINLINE trueDepthCamera #-}
trueDepthCamera = unsafePerformIO $ peek c_AVCaptureDeviceTypeBuiltInTrueDepthCamera

foreign import ccall "&AVCaptureDeviceTypeBuiltInDualCamera" c_AVCaptureDeviceTypeBuiltInDualCamera :: Ptr NSString
{-# NOINLINE dualCamera #-}
dualCamera = unsafePerformIO $ peek c_AVCaptureDeviceTypeBuiltInDualCamera

foreign import ccall "&AVCaptureDeviceTypeBuiltInTelephotoCamera" c_AVCaptureDeviceTypeBuiltInTelephotoCamera :: Ptr NSString
{-# NOINLINE telephotoCamera #-}
telephotoCamera = unsafePerformIO $ peek c_AVCaptureDeviceTypeBuiltInTelephotoCamera

foreign import ccall "&AVCaptureDeviceTypeBuiltInWideAngleCamera" c_AVCaptureDeviceTypeBuiltInWideAngleCamera :: Ptr NSString
{-# NOINLINE wideAngleCamera #-}
wideAngleCamera = unsafePerformIO $ peek c_AVCaptureDeviceTypeBuiltInWideAngleCamera

foreign import ccall "&AVLayerVideoGravityResizeAspectFill" c_AVLayerVideoGravityResizeAspectFill :: Ptr NSString
{-# NOINLINE resizeAspectFill #-}
resizeAspectFill = unsafePerformIO $ peek c_AVLayerVideoGravityResizeAspectFill
