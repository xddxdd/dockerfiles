#include "syscall_arch.h"
#include "bits/syscall.h.in"

void _start() {
	while(1) __syscall0(__NR_sched_yield);
}
