#include "common.Dockerfile"
#include "image/debian_sid.Dockerfile"
#include "env.Dockerfile"

#define APP_DEPS tini pdns-recursor pdns-tools pdns-backend-\* bird2

ENV BIRD_VERSION=2.0.5
ADD start.sh /start.sh
RUN PKG_INSTALL(APP_DEPS) \
    && apt-get clean \
    && chmod +x /start.sh \
ADD bird.conf /etc/bird.conf
ADD bird-static.conf /etc/bird-static.conf
ENTRYPOINT ["/usr/bin/tini", "-g", "--", "/start.sh"]