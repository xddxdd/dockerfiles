#include "common.Dockerfile"
#include "image/alpine_edge.Dockerfile"
#include "env.Dockerfile"

COPY run.sh /
RUN PKG_INSTALL(git go musl-dev) \
    && go get github.com/Mic92/whois42d \
    && cp /root/go/bin/whois42d /whois42d \
    && rm -rf /root/go \
    && PKG_UNINSTALL(go musl-dev) \
    && chmod +x /run.sh
ENTRYPOINT ["/run.sh"]
