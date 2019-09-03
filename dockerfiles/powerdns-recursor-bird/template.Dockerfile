#include "common.Dockerfile"
#include "image/alpine_edge.Dockerfile"
#include "env.Dockerfile"

ADD start.sh /start.sh
ADD bird.conf /etc/bird.conf
ADD bird-static.conf /etc/bird-static.conf
RUN sh -c "echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories" \
    && apk update \
    && sh -c "apk search -q pdns | grep -v pdnsd | xargs apk add" \
    && PKG_INSTALL(bird tini) \
    && rm -rf /var/cache/apk/* \
    && chmod +x /start.sh
ENTRYPOINT ["/sbin/tini", "-g", "--", "/start.sh"]