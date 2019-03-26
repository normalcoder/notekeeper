#import <UIKit/UIKit.h>

void hs_init(void *, void *);
void runHsMain(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        hs_init(&argc, &argv);
        runHsMain();
    }
}
