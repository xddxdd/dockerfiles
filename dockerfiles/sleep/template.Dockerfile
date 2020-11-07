#include "common.Dockerfile"
#include "image/debian_sid.Dockerfile"

COPY sleep.c /
RUN cd / \
    && PKG_INSTALL(build-essential wget tar) \
    && UNTARGZ(https://musl.libc.org/releases/musl-1.2.1.tar.gz) \
       && mv musl-1.2.1 musl \
       && cd /musl \
       && ./configure \
       && make obj/include/bits/syscall.h \
       && export TARGET_ARCH=$(cat config.mak | grep "^ARCH" | sed 's/ //g' | cut -d'=' -f2) \
       && cd / \
    && gcc -Os -static -nostdlib \
       -I/musl/arch/${TARGET_ARCH} \
       -I/musl/obj/include/bits \
       -Wl,--build-id=none -fno-asynchronous-unwind-tables \
       -o /sleep sleep.c \
    && strip -s -R ".comment" /sleep

FROM scratch
COPY --from=step_0 /sleep /
STOPSIGNAL SIGKILL
ENTRYPOINT [ "/sleep" ]
