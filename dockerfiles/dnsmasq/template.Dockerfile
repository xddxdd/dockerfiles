#include "common.Dockerfile"
#include "image/multiarch_alpine_edge.Dockerfile"
#include "env.Dockerfile"

RUN PKG_INSTALL(dnsmasq)
ENTRYPOINT ["/usr/sbin/dnsmasq", "-d"]
