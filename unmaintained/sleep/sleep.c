#include "bits/syscall.h"
#include "syscall_arch.h"

void _start() {
    while(1) {
#ifdef SYS_pause
        __syscall0(SYS_pause);
#else
        __syscall0(SYS_sched_yield);
#endif
    }
}
