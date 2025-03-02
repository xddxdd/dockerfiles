#include "common.Dockerfile"
#include "image/debian_sid.Dockerfile"

#define APP_BUILD_TOOLS build-essential git musl-dev musl-tools

RUN PKG_INSTALL(APP_BUILD_TOOLS) \
    && cd /tmp \
    && git clone https://github.com/klange/nyancat.git \
      && cd nyancat \
      && CC=musl-gcc LDFLAGS="-static" make \
      && cp src/nyancat / \
    && cd /tmp \
    && git clone http://offog.org/git/onenetd.git \
      && cd /tmp/onenetd \
      && touch config.h \
      && musl-gcc -static -O3 -DVERSION="" -o /onenetd onenetd.c

#include "image/scratch.Dockerfile"
COPY --from=step_0 /nyancat /onenetd /
STOPSIGNAL SIGKILL
ENTRYPOINT ["/onenetd", "-v", "0", "23", "/nyancat", "--telnet"]
