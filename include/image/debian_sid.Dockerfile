#if defined(ARCH_AMD64)
FROM amd64/debian:sid
#define LINUX_HEADERS linux-headers-amd64
#elif defined(ARCH_I386)
FROM i386/debian:sid
#define LINUX_HEADERS linux-headers-686
#elif defined(ARCH_ARM32V7)
FROM arm32v7/debian:sid
#define LINUX_HEADERS linux-headers-armmp
#elif defined(ARCH_ARM64V8)
FROM arm64v8/debian:sid
#define LINUX_HEADERS linux-headers-arm64
#elif defined(ARCH_PPC64LE)
FROM ppc64le/debian:sid
#define LINUX_HEADERS linux-headers-powerpc64le
#elif defined(ARCH_S390X)
FROM s390x/debian:sid
#define LINUX_HEADERS linux-headers-s390x
#elif defined(ARCH_RISCV64)
FROM xddxdd/debian-riscv64:latest
#define LINUX_HEADERS linux-headers-riscv64
#elif defined(ARCH_X32)
FROM xddxdd/debian-x32:latest
#define LINUX_HEADERS linux-headers-\*-common
#else
#error "Architecture not set"
#endif

#define PKG_INSTALL(pkgs) apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get -qq install -y pkgs
#define PKG_UNINSTALL(pkgs) apt-get -qq purge -y pkgs && PKG_CLEANUP()
#define PKG_CLEANUP() apt-get -qq autoremove --purge -y && apt-get clean && rm -rf /var/lib/apt/lists