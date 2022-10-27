#include <sys/time.h>
#include <stdint.h>

int64_t getCurrentTime() {
 struct timeval t;
 gettimeofday(&t, 0);
 int64_t usecs = ((int64_t)t.tv_sec)*1000000 + ((int64_t)t.tv_usec);
 return usecs;
}
