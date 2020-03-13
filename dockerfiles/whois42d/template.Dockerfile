#include "common.Dockerfile"
#include "image/debian_buster.Dockerfile"
#include "env.Dockerfile"

#define APP_DEPS git procps
#define APP_BUILD_TOOLS golang

ADD start.sh /
RUN PKG_INSTALL(APP_DEPS APP_BUILD_TOOLS) \
    && go get github.com/Mic92/whois42d \
    && cp /root/go/bin/whois42d /whois42d \
    && rm -rf /root/go \
    && PKG_UNINSTALL(APP_BUILD_TOOLS)
ENTRYPOINT ["sh", "/start.sh"]
