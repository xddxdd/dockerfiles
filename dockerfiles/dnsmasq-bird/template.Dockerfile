#include "common.Dockerfile"
#include "image/alpine_edge.Dockerfile"
#include "env.Dockerfile"

ADD start.sh /start.sh
RUN sh -c "echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories" \
    && PKG_INSTALL(dnsmasq bird tini) \
    && chmod +x /start.sh
ADD bird.conf /etc/bird.conf
ADD bird-static.conf /etc/bird-static.conf
ENTRYPOINT ["/sbin/tini", "-g", "--", "/start.sh"]