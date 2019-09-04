#include "common.Dockerfile"
#include "image/alpine_edge.Dockerfile"
#include "env.Dockerfile"

#define APP_DEPS tini dnsmasq
#define APP_BUILD_TOOLS build-base bison flex ncurses-dev readline-dev linux-headers wget patch binutils

ENV BIRD_VERSION=2.0.5
ADD start.sh /start.sh
ADD bird.conf /etc/bird.conf
ADD bird-static.conf /etc/bird-static.conf
RUN PKG_INSTALL(APP_DEPS APP_BUILD_TOOLS) \
    && chmod +x /start.sh \
    && cd /tmp \
    && UNTARGZ(ftp://bird.network.cz/pub/bird/bird-${BIRD_VERSION}.tar.gz) \
    && cd /tmp/bird-${BIRD_VERSION} \
    && ./configure --prefix=/usr \
	   --sysconfdir=/etc \
	   --mandir=/usr/share/man \
	   --localstatedir=/var \
    && make && make install \
    && rm -rf /usr/share/man \
    && rm -rf /tmp/* \
    && strip /usr/sbin/bird* \
    && PKG_UNINSTALL(APP_BUILD_TOOLS)
ENTRYPOINT ["/sbin/tini", "-g", "--", "/start.sh"]