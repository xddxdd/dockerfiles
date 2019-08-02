#if defined(ARCH_AMD64)
FROM multiarch/debian-debootstrap:amd64-buster
#elif defined(ARCH_I386)
FROM multiarch/debian-debootstrap:i386-buster
#elif defined(ARCH_ARM32V7)
FROM multiarch/debian-debootstrap:armhf-buster
#elif defined(ARCH_ARM64V8)
FROM multiarch/debian-debootstrap:arm64-buster
#else
#error "Architecture not set"
#endif