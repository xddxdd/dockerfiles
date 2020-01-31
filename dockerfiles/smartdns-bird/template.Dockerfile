#include "common.Dockerfile"
#include "image/debian_buster.Dockerfile"
#include "env.Dockerfile"

#define APP_DEPS tini libssl1\*
#define APP_BUILD_TOOLS build-essential bison flex libncurses-dev libreadline-dev LINUX_HEADERS wget patch binutils libssl-dev git

ENV BIRD_VERSION=2.0.5
ADD start.sh /start.sh
RUN PKG_INSTALL(APP_DEPS APP_BUILD_TOOLS) \
    && chmod +x /start.sh \
    && cd /tmp \
    && git clone https://github.com/pymumu/smartdns.git \
        && cd /tmp/smartdns/src && make \
        && cd /tmp/smartdns && bash install -i \
        && cd /tmp \
    && UNTARGZ(ftp://bird.network.cz/pub/bird/bird-${BIRD_VERSION}.tar.gz) \
        && cd /tmp/bird-${BIRD_VERSION} \
        && ./configure --prefix=/usr \
        --sysconfdir=/etc \
        --mandir=/usr/share/man \
        --localstatedir=/var \
        && make && make install \
        && rm -rf /usr/share/man \
        && strip /usr/sbin/bird* \
    && cd / \
    && rm -rf /tmp/* \
    && PKG_UNINSTALL(APP_BUILD_TOOLS)
ADD bird.conf /etc/bird.conf
ADD bird-static.conf /etc/bird-static.conf
ENTRYPOINT ["/usr/bin/tini", "-g", "--", "/start.sh"]
