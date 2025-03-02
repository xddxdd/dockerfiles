#include "common.Dockerfile"
#include "image/debian_sid.Dockerfile"

#if defined(ARCH_AMD64)
ENV TARGET_ARCH=x86_64
#elif defined(ARCH_I386)
ENV TARGET_ARCH=i386
#elif defined(ARCH_ARM32V7)
ENV TARGET_ARCH=arm
#elif defined(ARCH_ARM64V8)
ENV TARGET_ARCH=aarch64
#elif defined(ARCH_PPC64LE)
ENV TARGET_ARCH=powerpc64
#elif defined(ARCH_S390X)
ENV TARGET_ARCH=s390x
#elif defined(ARCH_RISCV64)
ENV TARGET_ARCH=riscv64
#elif defined(ARCH_X32)
ENV TARGET_ARCH=x32
#else
#error "Architecture not set"
#endif

COPY sleep.c /
RUN cd / \
    && PKG_INSTALL(build-essential wget tar) \
    && UNTARGZ(https://musl.libc.org/releases/musl-1.2.1.tar.gz) \
       && mv musl-1.2.1 musl \
       && sh -c "sed -n -e s/__NR_/SYS_/p < /musl/arch/${TARGET_ARCH}/bits/syscall.h.in >> /musl/arch/${TARGET_ARCH}/bits/syscall.h" \
    && gcc -Os -static -nostdlib \
       -I/musl/arch/${TARGET_ARCH} \
       -Wl,--build-id=none -fno-asynchronous-unwind-tables \
       -o /sleep sleep.c \
    && strip -s -R ".comment" /sleep

FROM scratch
COPY --from=step_0 /sleep /
STOPSIGNAL SIGKILL
ENTRYPOINT [ "/sleep" ]
