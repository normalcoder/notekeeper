#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <stdatomic.h>

//extern void hs_init_with_rtsopts (int *argc, char **argv[]);
void hs_init_with_rtsopts(int *argc, const char **argv[]);
//void hs_init(void *, void *);
void runHsMain(void);
//void check_atomic123(void);
//void moreCapabilities(void);
//void checkAtomic1(void);


int main(int argc, const char * argv[]) {
    @autoreleasepool {
//        checkAtomic1();
//        moreCapabilities();
//        check_atomic123();
        
        int _Atomic x = 1;
        _Atomic(int) *p = &x;
        int _Atomic **pp = (int _Atomic **)&p;

        _Atomic(int) q = atomic_load(p);
        _Atomic(int) q1 = atomic_load(p);
        _Atomic(int) q2 = atomic_load(p);
        _Atomic(int) q3 = atomic_load(p);
        _Atomic(int) q4 = atomic_load(p);
        _Atomic(int) q5 = atomic_load(p);
        _Atomic(int) q6 = atomic_load(p);
        printf("!!!_Atomic(int): %d\n", q);
        
        __atomic_load_n((int **) pp, __ATOMIC_ACQUIRE);
        __atomic_load_n((int **) pp, __ATOMIC_ACQUIRE);
        __atomic_load_n((int **) pp, __ATOMIC_ACQUIRE);
        __atomic_load_n((int **) pp, __ATOMIC_ACQUIRE);
        __atomic_load_n((int **) pp, __ATOMIC_ACQUIRE);
        __atomic_load_n((int **) pp, __ATOMIC_ACQUIRE);
        __atomic_load_n((int **) pp, __ATOMIC_ACQUIRE);
        __atomic_load_n((int **) pp, __ATOMIC_ACQUIRE);

        char *argvToAdd[] = {"+RTS", "-N4", "--arbitrary-heap-start", "-RTS"};
//        char *argvToAdd[] = {"+RTS", "-N4", "-RTS"};
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
//        hs_init(&argc, &argv);
        runHsMain();
    }
}
