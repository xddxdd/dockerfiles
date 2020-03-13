#include "common.Dockerfile"
#include "image/debian_sid.Dockerfile"
#include "env.Dockerfile"

RUN PKG_INSTALL(pdns-recursor pdns-tools)
ENTRYPOINT ["/usr/sbin/pdns_recursor"]