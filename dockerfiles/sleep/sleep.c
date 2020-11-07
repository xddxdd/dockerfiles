#include "syscall_arch.h"
#include "syscall.h"

void _start() {
	while(1) __syscall0(__NR_sched_yield);
}
