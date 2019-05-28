#import <UIKit/UIKit.h>
//#import <QuartzCore/QuartzCore.h>
//#import <CoreGraphics/CoreGraphics.h>
//#import <objc/runtime.h>
//#import <objc/objc.h>
//#import <objc/message.h>

void hs_init(void *, void *);
void runHsMain(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        hs_init(&argc, &argv);
        runHsMain();
    }
}

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
