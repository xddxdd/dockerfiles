#include "common.Dockerfile"
#include "image/debian_buster.Dockerfile"
#include "env.Dockerfile"

#define APP_DEPS tini git procps libncurses6 libncursesw6 libreadline8
#define APP_BUILD_TOOLS golang build-essential bison flex libncurses-dev libreadline-dev LINUX_HEADERS wget patch binutils

ENV BIRD_VERSION=2.0.7
ADD start.sh /start.sh
RUN PKG_INSTALL(APP_DEPS APP_BUILD_TOOLS) \
    && chmod +x /start.sh \
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
    && go get github.com/Mic92/whois42d \
       && cp /root/go/bin/whois42d /whois42d \
       && rm -rf /root/go \
    && PKG_UNINSTALL(APP_BUILD_TOOLS)
ADD bird.conf /etc/bird.conf
ENTRYPOINT ["/usr/bin/tini", "-g", "--", "/start.sh"]
