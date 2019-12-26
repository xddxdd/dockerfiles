#include "common.Dockerfile"
#include "image/debian_buster.Dockerfile"
#include "env.Dockerfile"

ADD run.sh /
RUN PKG_INSTALL(git golang procps) \
    && go get github.com/Mic92/whois42d \
    && cp /root/go/bin/whois42d /whois42d \
    && rm -rf /root/go \
    && PKG_UNINSTALL(golang) \
    && chmod +x /run.sh
ENTRYPOINT ["/run.sh"]
