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

COPY ip-holder.c /
RUN cd / \
    && PKG_INSTALL(build-essential git musl-dev musl-tools) \
    && git clone https://github.com/sabotage-linux/kernel-headers.git \
    && musl-gcc -Os -static -Wl,--build-id=none \
       -I /kernel-headers/${TARGET_ARCH}/include \
       -o /ip-holder ip-holder.c \
    && strip -s -R ".comment" /ip-holder

FROM scratch
COPY --from=step_0 /ip-holder /
STOPSIGNAL SIGKILL
ENTRYPOINT [ "/ip-holder" ]
