#include "common.Dockerfile"
#include "image/alpine_edge.Dockerfile"
#include "env.Dockerfile"

#define APP_BUILD_TOOLS build-base git autoconf automake

RUN PKG_INSTALL(APP_BUILD_TOOLS) \
    && cd /tmp \
    && git clone https://github.com/klange/nyancat.git \
      && cd nyancat && make -j4 \
      && cp src/nyancat /usr/bin \
      && cd .. && rm -rf nyancat \
    && git clone http://offog.org/git/onenetd.git \
      && cd /tmp/onenetd \
      && autoreconf -vfi && ./configure && make -j4 \
      && cp onenetd /usr/bin \
      && cd .. && rm -rf onenetd \
    && PKG_UNINSTALL(APP_BUILD_TOOLS)

ENTRYPOINT ["onenetd", "-v", "0", "23", "nyancat", "--telnet"]
