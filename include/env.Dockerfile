#if defined(ARCH_AMD64)
ENV THIS_ARCH=amd64 THIS_ARCH_GO=amd64
#elif defined(ARCH_I386)
ENV THIS_ARCH=i386 THIS_ARCH_GO=386
#elif defined(ARCH_ARM32V7)
ENV THIS_ARCH=arm32v7 THIS_ARCH_GO=arm
#elif defined(ARCH_ARM64V8)
ENV THIS_ARCH=arm64v8 THIS_ARCH_GO=arm64
#elif defined(ARCH_PPC64LE)
ENV THIS_ARCH=ppc64le THIS_ARCH_GO=ppc64le
#elif defined(ARCH_S390X)
ENV THIS_ARCH=s390x THIS_ARCH_GO=s390x
#elif defined(ARCH_RISCV64)
ENV THIS_ARCH=riscv64 THIS_ARCH_GO=riscv64
#elif defined(ARCH_X32)
ENV THIS_ARCH=x32 THIS_ARCH_GO=386
#else
#error "Architecture not set"
#endif