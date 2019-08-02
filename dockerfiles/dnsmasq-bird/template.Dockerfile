#include "image/multiarch_alpine_edge.Dockerfile"
#include "env.Dockerfile"

RUN sh -c "echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories" \
    && apk --no-cache add dnsmasq bird supervisor
COPY supervisord.conf /etc/supervisord.conf
COPY bird.conf /etc/bird.conf
COPY bird-static.conf /etc/bird-static.conf
ENTRYPOINT ["/usr/bin/supervisord", "-n"]