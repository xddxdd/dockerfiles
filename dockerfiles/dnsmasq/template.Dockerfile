#include "common.Dockerfile"
#include "image/debian_buster.Dockerfile"
#include "env.Dockerfile"

RUN PKG_INSTALL(dnsmasq)
ENTRYPOINT ["/usr/sbin/dnsmasq", "-d"]
