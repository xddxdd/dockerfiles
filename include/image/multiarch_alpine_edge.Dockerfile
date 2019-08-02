#if defined(ARCH_AMD64)
FROM multiarch/alpine:amd64-edge
#elif defined(ARCH_I386)
FROM multiarch/alpine:i386-edge
#elif defined(ARCH_ARM32V7)
FROM multiarch/alpine:armhf-edge
#elif defined(ARCH_ARM64V8)
FROM multiarch/alpine:arm64-edge
#else
#error "Architecture not set"
#endif