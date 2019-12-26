#if defined(ARCH_AMD64)
FROM amd64/debian:buster
#elif defined(ARCH_I386)
FROM i386/debian:buster
#elif defined(ARCH_ARM32V7)
FROM arm32v7/debian:buster
#elif defined(ARCH_ARM64V8)
FROM arm64v8/debian:buster
#elif defined(ARCH_PPC64LE)
FROM ppc64le/debian:buster
#elif defined(ARCH_S390X)
FROM s390x/debian:buster
#elif defined(ARCH_RISCV64)
#warning "Debian RISC-V image is based on Sid (Unstable)"
FROM xddxdd/debian-riscv64:latest
#else
#error "Architecture not set"
#endif

#define PKG_INSTALL(pkgs) apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get -qq install -y pkgs
#define PKG_UNINSTALL(pkgs) apt-get -qq purge pkgs
