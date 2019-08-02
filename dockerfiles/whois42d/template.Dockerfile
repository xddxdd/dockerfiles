#include "image/multiarch_alpine_edge.Dockerfile"
#include "env.Dockerfile"

RUN apk --no-cache add go git musl-dev \
    && go get github.com/Mic92/whois42d \
    && cp /root/go/bin/whois42d /whois42d \
    && rm -rf /root/go \
    && apk --no-cache del go musl-dev
COPY run.sh /
RUN chmod +x /run.sh
ENTRYPOINT ["/run.sh"]
