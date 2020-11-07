#include "common.Dockerfile"
#include "image/debian_sid.Dockerfile"

COPY sleep.c /
RUN cd / \
    && PKG_INSTALL(build-essential wget tar) \
    && UNTARGZ(https://musl.libc.org/releases/musl-1.2.1.tar.gz) \
       && mv musl-1.2.1 musl \
       && musl/configure \
       && export TARGET_ARCH=$(cat config.mak | grep "^ARCH" | sed 's/ //g' | cut -d'=' -f2) \
    && gcc -Os -static -nostdlib -Imusl/arch/${TARGET_ARCH} -Wl,--build-id=none -fno-asynchronous-unwind-tables -o /sleep sleep.c \
    && strip -s -R ".comment" /sleep

FROM scratch
COPY --from=step_0 /sleep /
STOPSIGNAL SIGKILL
ENTRYPOINT [ "/sleep" ]
