#include "common.Dockerfile"
#include "image/debian_sid.Dockerfile"
#include "env.Dockerfile"

RUN PKG_INSTALL(quassel-core)
VOLUME ["/var/lib/quassel/"]
ENTRYPOINT ["/usr/bin/quasselcore", "--configdir=/var/lib/quassel/"]
