#include "common.Dockerfile"
#include "image/debian_sid.Dockerfile"
#include "env.Dockerfile"

#define APP_BUILD_TOOLS build-essential git musl-dev musl-tools wget bison flex automake autoconf

#if defined(ARCH_AMD64)
ENV TARGET_ARCH=x86_64
#elif defined(ARCH_I386)
ENV TARGET_ARCH=i386
#elif defined(ARCH_ARM32V7)
ENV TARGET_ARCH=arm
#elif defined(ARCH_ARM64V8)
ENV TARGET_ARCH=aarch64
#elif defined(ARCH_PPC64LE)
ENV TARGET_ARCH=ppc64le
#elif defined(ARCH_S390X)
ENV TARGET_ARCH=s390
#elif defined(ARCH_RISCV64)
#error "RISC-V not supported"
#elif defined(ARCH_X32)
ENV TARGET_ARCH=x32
#else
#error "Architecture not set"
#endif

RUN PKG_INSTALL(APP_BUILD_TOOLS) \
    && cd /tmp \
    && git clone https://github.com/sabotage-linux/kernel-headers.git \
    && git -c http.sslVerify=false clone https://gitlab.nic.cz/labs/bird.git \
       && cd /tmp/bird \
       && autoreconf \
       && ./configure \
          CC="musl-gcc" \
          LD="musl-gcc" \
          CFLAGS="-I/tmp/kernel-headers/${TARGET_ARCH}/include -flto" \
          LDFLAGS="-static -flto" \
          --disable-client \
          --prefix=/usr \
          --sysconfdir=/etc \
          --mandir=/usr/share/man \
          --localstatedir=/var \
       && make -j4 \
       && strip /tmp/bird/bird /tmp/bird/birdcl

#include "image/scratch.Dockerfile"
COPY --from=step_0 /tmp/bird/bird /usr/sbin/bird
COPY --from=step_0 /tmp/bird/birdcl /usr/sbin/birdc
COPY --from=step_0 /tmp/bird/birdcl /usr/sbin/birdcl
ADD bird.conf /etc/bird.conf
ADD empty.txt /var/run/.empty
ENTRYPOINT ["/usr/sbin/bird", "-f"]
