#import <UIKit/UIKit.h>

void hs_init_with_rtsopts(int *argc, const char **argv[]);
void runHsMain(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        char *argvToAdd[] = {"+RTS", "-N4", "--arbitrary-heap-start", "-RTS"};
        int argvToAddCnt = sizeof(argvToAdd)/sizeof(char *);
        int fixedArgc = argc + argvToAddCnt;
        const char **fixedArgv = malloc(sizeof(char *) * fixedArgc);
        for (int i=0; i<argc; ++i) {
            fixedArgv[i] = argv[i];
        }
        for (int i=argc; i<argc + argvToAddCnt; ++i) {
            fixedArgv[i] = argvToAdd[i - argc];
        }

        hs_init_with_rtsopts(&fixedArgc, &fixedArgv);
        runHsMain();
    }
}
