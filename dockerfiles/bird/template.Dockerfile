#include "common.Dockerfile"
#include "image/debian_sid.Dockerfile"
#include "env.Dockerfile"

#define APP_DEPS libncurses6 libncursesw6 libreadline8
#define APP_BUILD_TOOLS build-essential bison flex libncurses-dev libreadline-dev LINUX_HEADERS wget patch binutils

ENV BIRD_VERSION=2.0.7
RUN PKG_INSTALL(APP_DEPS APP_BUILD_TOOLS) \
    && cd /tmp \
    && UNTARGZ(https://bird.network.cz/download/bird-${BIRD_VERSION}.tar.gz) \
       && cd /tmp/bird-${BIRD_VERSION} \
       && ./configure --prefix=/usr \
          --sysconfdir=/etc \
          --mandir=/usr/share/man \
          --localstatedir=/var \
       && make -j4 && make install \
       && strip /usr/sbin/bird* \
    && cd / \
    && PKG_UNINSTALL(APP_BUILD_TOOLS) \
    && FINAL_CLEANUP()

ADD bird.conf /etc/bird.conf
ADD healthcheck.sh /
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 CMD [ "sh", "/healthcheck.sh" ]
ENTRYPOINT ["/usr/sbin/bird", "-f"]