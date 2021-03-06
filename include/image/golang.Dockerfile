#include "step_counter.Dockerfile"

FROM golang:buster AS STEP
#define LINUX_HEADERS linux-headers-amd64

#if defined(ARCH_AMD64)
ENV GOOS=linux GOARCH=amd64
#elif defined(ARCH_I386)
ENV GOOS=linux GOARCH=386
#elif defined(ARCH_ARM32V7)
ENV GOOS=linux GOARCH=arm
#elif defined(ARCH_ARM64V8)
ENV GOOS=linux GOARCH=arm64
#elif defined(ARCH_PPC64LE)
ENV GOOS=linux GOARCH=ppc64le
#elif defined(ARCH_S390X)
ENV GOOS=linux GOARCH=s390x
#elif defined(ARCH_RISCV64)
ENV GOOS=linux GOARCH=riscv64
#elif defined(ARCH_X32)
ENV GOOS=linux GOARCH=amd64
#else
#error "Architecture not set"
#endif

#define PKG_INSTALL(pkgs) apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get -qq install -y pkgs
#define PKG_UNINSTALL(pkgs) apt-get -qq purge -y pkgs && PKG_CLEANUP()
#define PKG_CLEANUP() apt-get -qq autoremove --purge -y && apt-get clean && rm -rf /var/lib/apt/lists