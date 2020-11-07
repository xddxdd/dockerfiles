#include "bits/syscall.h"
#include "syscall_arch.h"

void _start() {
	while(1) __syscall0(SYS_sched_yield);
}
