#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>

//#import <QuartzCore/QuartzCore.h>
//#import <CoreGraphics/CoreGraphics.h>
//#import <objc/runtime.h>
//#import <objc/objc.h>
//#import <objc/message.h>

void hs_init(void *, void *);
void runHsMain(void);
void startCapturing(void);
void setupCaptureSession(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            startCapturing();
//        });
        hs_init(&argc, &argv);
        runHsMain();
    }
}

@interface SampleBufferDelegate : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> @end @implementation SampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"qwe");
}

@end

void startCapturing() {
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized) {
        setupCaptureSession();
    } else {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    setupCaptureSession();
                });
            }
        }];
    }
}
SampleBufferDelegate *delegate1;
void setupCaptureSession() {
    UIView *mainView = UIApplication.sharedApplication.windows[0].rootViewController.view;

    AVCaptureSession *captureSession = AVCaptureSession.new;
    captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    if (captureSession.inputs.count > 0) {
        NSLog(@"there are some inputs");
        return;
    }
    
    if (@available(iOS 11.1, *)) {
    } else {
        NSLog(@"ios version is < 11.1");
        return;
    }
    
    AVCaptureDeviceDiscoverySession *discoverySession =
    [AVCaptureDeviceDiscoverySession
     discoverySessionWithDeviceTypes:@[
         AVCaptureDeviceTypeBuiltInTrueDepthCamera,
         AVCaptureDeviceTypeBuiltInDualCamera,
         AVCaptureDeviceTypeBuiltInTelephotoCamera,
         AVCaptureDeviceTypeBuiltInWideAngleCamera,
     ]
     mediaType:AVMediaTypeVideo
     position:AVCaptureDevicePositionBack];
        
    AVCaptureDevice *camera = discoverySession.devices.firstObject;
    if (!camera) {
        NSLog(@"no camera");
        return;
    }
    
    NSError *e;
    AVCaptureDeviceInput *cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:camera error:&e];
    [captureSession addInput:cameraInput];
    
    
    // preview
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    preview.frame = mainView.bounds;
    preview.backgroundColor = UIColor.blackColor.CGColor;
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [mainView.layer addSublayer:preview];
    
    
    delegate1 = SampleBufferDelegate.new;
    dispatch_queue_t sampleBufferQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    AVCaptureVideoDataOutput *output = AVCaptureVideoDataOutput.new;
    output.alwaysDiscardsLateVideoFrames = YES;
    [output setSampleBufferDelegate:delegate1 queue:sampleBufferQueue];
    [captureSession addOutput:output];
    
    AVCaptureConnection *connection = [output connectionWithMediaType:AVMediaTypeVideo];
    if (!connection) {
        NSLog(@"no connection");
        return;
    }
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    [captureSession startRunning];
    
}

//UIViewController
// startRunning
// stopRunning
// imageCaptured
//
//producer :: Producer Image

//struct CGFloat2 { CGFloat a[2]; };
//
//void objc_msgSend();
//void objc_msgSend_stret();
//static void *fRet = (void *)objc_msgSend_stret;
//static void *f = (void *)objc_msgSend;
//
//void objc_msgSend_stret_CGFloat2(void * obj, void * sel, struct CGFloat2 * r) {
////    UIView *v = (__bridge UIView *)obj;
////    CGPoint p = [v center];
////    NSLog(@"p: %f %f", p.x, p.y);
////    CGRect b = [v bounds];
////    NSLog(@"b: %f", b.origin.x);
////    SEL s1 = (SEL)sel;
////    objc_msgSend_stret()
////    objc
////    CGPoint p2 = [v performSelector:s1];
////    struct CGFloat2 q = ((struct CGFloat2 (*)(void *, void *))f)(obj, sel);
////
//    *r = ((struct CGFloat2 (*)(void *, void *))f)(obj, sel);
//}
