#if defined(ARCH_AMD64)
FROM amd64/alpine:edge
#elif defined(ARCH_I386)
FROM i386/alpine:edge
#elif defined(ARCH_ARM32V7)
FROM arm32v7/alpine:edge
#elif defined(ARCH_ARM64V8)
FROM arm64v8/alpine:edge
#elif defined(ARCH_PPC64LE)
FROM ppc64le/alpine:edge
#elif defined(ARCH_S390X)
FROM s390x/alpine:edge
#else
#error "Architecture not set"
#endif

#define LINUX_HEADERS linux-headers

#define PKG_INSTALL(pkgs) apk add -q --no-cache pkgs
#define PKG_UNINSTALL(pkgs) apk del -q --purge pkgs
#define PKG_CLEANUP()
