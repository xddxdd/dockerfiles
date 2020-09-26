#include "common.Dockerfile"
#include "image/multiarch_alpine_edge.Dockerfile"
#include "env.Dockerfile"

RUN PKG_INSTALL(git go musl-dev) \
    && go get github.com/Mic92/whois42d \
    && cp /root/go/bin/whois42d /whois42d \
    && rm -rf /root/go \
    && PKG_UNINSTALL(go musl-dev)
COPY run.sh /
RUN chmod +x /run.sh
ENTRYPOINT ["/run.sh"]
