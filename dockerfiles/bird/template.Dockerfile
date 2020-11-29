#include "common.Dockerfile"
#include "image/debian_sid.Dockerfile"
#include "env.Dockerfile"

#define APP_BUILD_TOOLS build-essential gcc-9 git musl-dev musl-tools wget bison flex

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

ENV BIRD_VERSION=2.0.7 NCURSES_VERSION=6.2 READLINE_VERSION=8.0
RUN PKG_INSTALL(APP_BUILD_TOOLS) \
    && cd /tmp \
    && export REALGCC=gcc-9 \
    && git clone https://github.com/sabotage-linux/kernel-headers.git \
    && UNTARGZ(https://ftp.gnu.org/pub/gnu/ncurses/ncurses-${NCURSES_VERSION}.tar.gz) \
       && mv /tmp/ncurses-${NCURSES_VERSION} /tmp/ncurses \
       && cd /tmp/ncurses \
       && ./configure CC="musl-gcc" CXX="musl-gcc" && make -j4 \
       && cd /tmp \
    && UNTARGZ(https://ftp.gnu.org/gnu/readline/readline-${READLINE_VERSION}.tar.gz) \
       && mv /tmp/readline-${READLINE_VERSION} /tmp/readline \
       && cd /tmp/readline \
       && ./configure CC="musl-gcc" && make -j4 \
       && cd /tmp \
    && UNTARGZ(https://bird.network.cz/download/bird-${BIRD_VERSION}.tar.gz) \
       && mv /tmp/bird-${BIRD_VERSION} /tmp/bird \
       && cd /tmp/bird \
       && ./configure \
          CC="musl-gcc" \
          CFLAGS="-I/tmp/ncurses/include -I/tmp -I/tmp/kernel-headers/${TARGET_ARCH}/include" \
          LDFLAGS="-L/tmp/ncurses/lib -L/tmp/readline -static" \
          --prefix=/usr \
          --sysconfdir=/etc \
          --mandir=/usr/share/man \
          --localstatedir=/var \
       && make -j4 \
       && strip /tmp/bird/bird /tmp/bird/birdc /tmp/bird/birdcl

#include "image/scratch.Dockerfile"
COPY --from=step_0 /tmp/bird/bird /tmp/bird/birdc /tmp/bird/birdcl /usr/sbin/
ADD bird.conf /etc/bird.conf
ADD empty.txt /var/run/.empty
ENTRYPOINT ["/usr/sbin/bird", "-f"]