#include "image/multiarch_alpine_edge.Dockerfile"
#include "env.Dockerfile"

RUN apk --no-cache add dnsmasq
ENTRYPOINT ["/usr/sbin/dnsmasq", "-d"]
