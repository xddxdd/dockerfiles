#include "common.Dockerfile"
#include "image/debian_sid.Dockerfile"
#include "env.Dockerfile"

#define APP_DEPS libncurses6 libncursesw6 libreadline8
#define APP_BUILD_TOOLS build-essential bison flex libncurses-dev libreadline-dev LINUX_HEADERS wget patch binutils

ENV BIRD_VERSION=2.0.7
RUN PKG_INSTALL(APP_DEPS APP_BUILD_TOOLS) \
    && cd /tmp \
    && UNTARGZ(ftp://bird.network.cz/pub/bird/bird-${BIRD_VERSION}.tar.gz) \
       && cd /tmp/bird-${BIRD_VERSION} \
       && ./configure --prefix=/usr \
          --sysconfdir=/etc \
          --mandir=/usr/share/man \
          --localstatedir=/var \
       && make -j4 && make install \
       && strip /usr/sbin/bird* \
    && cd / \
    && rm -rf /tmp/* \
    && rm -rf /usr/share/man /usr/local/share/man \
    && PKG_UNINSTALL(APP_BUILD_TOOLS)
ADD bird.conf /etc/bird.conf
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 CMD [ "sh", "/healthcheck.sh" ]
ENTRYPOINT ["/usr/sbin/bird", "-f"]