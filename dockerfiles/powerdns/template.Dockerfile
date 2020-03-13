#include "common.Dockerfile"
#include "image/debian_sid.Dockerfile"
#include "env.Dockerfile"

RUN PKG_INSTALL(pdns-server pdns-tools pdns-backend-\*)
ENTRYPOINT ["/usr/sbin/pdns_server"]
