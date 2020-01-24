module Camera
( createCameraUi
) where

import Objc
import UiKit
import Gcd
import AvHelpers

import Foreign.Ptr
import Foreign.Storable


foreign import ccall safe "createSession" c_createSession :: Id -> Id -> Id -> IO (Ptr ())


foreign import ccall safe "startCapturing" c_startCapturing :: IO ()
foreign import ccall safe "setupCaptureSession" c_setupCaptureSession :: IO ()

createCameraUi :: Id -> IO ()
createCameraUi rootView = do
 withCamera $ setupCaptureSession rootView

setupCaptureSession rootView = do
 captureSession <- "new" @| "AVCaptureSession"
 ("setSessionPreset:", high) <.@. captureSession

 n <- fromNsInteger <$> "count" @< "inputs" @<. captureSession

 if n > 0
 then print "there are some inputs"
 else setupCaptureSession' rootView captureSession >> pure ()



setupCaptureSession' rootView captureSession = do
 types <- nsArray [trueDepthCamera, dualCamera, telephotoCamera, wideAngleCamera]
 session <- ("discoverySessionWithDeviceTypes:mediaType:position:", [types, video, back]) <.@@ "class" @| "AVCaptureDeviceDiscoverySession"
 -- session <- c_createSession types video back
 camera <- "firstObject" @< "devices" @<. session
 if camera == nullPtr
 then print "no camera"
 else setupCaptureSession'' rootView captureSession camera >> pure ()

setupCaptureSession'' rootView captureSession camera = do
 cameraInput <- ("deviceInputWithDevice:error:", [camera, nullPtr]) <.@@ "class" @| "AVCaptureDeviceInput"
 ("addInput:", cameraInput) <.@. captureSession

 createPreview rootView captureSession

createPreview rootView captureSession = do
 preview <- ("layerWithSession:", captureSession) <.@ "class" @| "AVCaptureVideoPreviewLayer"
 ("setFrame:", "bounds" #<. rootView) <#. preview
 ("setBackgroundColor:", "CGColor" @< "blackColor" @| "UIColor") <@. preview
 ("setVideoGravity:", resizeAspectFill) <.@. preview
 ("addSublayer:", preview) <.@ "layer" @<. rootView

 delegate1 <- "new" @| "SampleBufferDelegate"
 sampleBufferQueue <- getBackgroundQueue

 output <- "new" @| "AVCaptureVideoDataOutput"
 ("setAlwaysDiscardsLateVideoFrames:", toNsBool True) <.@. output
 ("setSampleBufferDelegate:queue:", [delegate1, sampleBufferQueue]) <.@@. output
 ("addOutput:", output) <.@. captureSession

 connection <- ("connectionWithMediaType:", video) <.@. output
 if connection == nullPtr
 then do
  print "no connection"
 else startRunning connection captureSession

startRunning connection captureSession = do
 ("setVideoOrientation:", portrait) <.@. connection
 "startRunning" @<. captureSession
 pure ()


withCamera action = do
 authorized <- isAuthorized
 if authorized then action
 else requestAccess $ \granted -> do
  if fromNsBool granted then onMainThread action
  else print "no camera access"


isAuthorized = do
 (== authorized) <$> ("authorizationStatusForMediaType:", video) <.@ "class" @| "AVCaptureDevice"

requestAccess completion = do
 c <- "class" @| "AVCaptureDevice"
 objc_msgSend_apply_ptr_apply_block c "requestAccessForMediaType:completionHandler:" video completion
