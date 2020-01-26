module Camera
( createCameraUi
) where

import Foreign.Ptr
import Foreign.Storable

import IOHelpers

import Objc
import UiKit
import Gcd
import AvHelpers

createCameraUi :: Id -> IO ()
createCameraUi rootView = do
 withCamera $ setupCaptureSession rootView

setupCaptureSession rootView = ignore $ do
 captureSession <- "new" @| "AVCaptureSession"
 ("setSessionPreset:", high) <.@. captureSession

 n <- fromNsInteger <$> "count" @< "inputs" @<. captureSession

 guard' (n == 0) "there are some inputs"

 types <- nsArray [trueDepthCamera, dualCamera, telephotoCamera, wideAngleCamera]
 session <- ("discoverySessionWithDeviceTypes:mediaType:position:", [types, video, back]) <.@@ "class" @| "AVCaptureDeviceDiscoverySession"
 camera <- "firstObject" @< "devices" @<. session

 guard' (camera /= nullPtr) "no camera"

 cameraInput <- ("deviceInputWithDevice:error:", [camera, nullPtr]) <.@@ "class" @| "AVCaptureDeviceInput"
 ("addInput:", cameraInput) <.@. captureSession

 preview <- ("layerWithSession:", captureSession) <.@ "class" @| "AVCaptureVideoPreviewLayer"
 ("setFrame:", "bounds" #<. rootView) <#. preview
 ("setBackgroundColor:", "CGColor" @< "blackColor" @| "UIColor") <@. preview
 ("setVideoGravity:", resizeAspectFill) <.@. preview
 ("addSublayer:", preview) <.@ "layer" @<. rootView

 delegate <- mkDelegate "SampleBufferDelegate"
  [ ("captureOutput:didOutputSampleBuffer:fromConnection:", \_ _ _ -> nullRet $ print "asd")
  ]
 sampleBufferQueue <- getBackgroundQueue

 output <- "new" @| "AVCaptureVideoDataOutput"
 ("setAlwaysDiscardsLateVideoFrames:", toNsBool True) <.@. output
 ("setSampleBufferDelegate:queue:", [delegate, sampleBufferQueue]) <.@@. output
 ("addOutput:", output) <.@. captureSession

 connection <- ("connectionWithMediaType:", video) <.@. output
 guard' (connection /= nullPtr) "no connection"

 ("setVideoOrientation:", portrait) <.@. connection
 "startRunning" @<. captureSession


withCamera action = do
 authorized <- isAuthorized
 if authorized then action
 else requestAccess $ \granted -> do
  guard' (fromNsBool granted) "no camera access"
  onMainThread action


isAuthorized = do
 (== authorized) <$> ("authorizationStatusForMediaType:", video) <.@ "class" @| "AVCaptureDevice"

requestAccess completion = do
 c <- "class" @| "AVCaptureDevice"
 objc_msgSend_apply_ptr_apply_block c "requestAccessForMediaType:completionHandler:" video completion
