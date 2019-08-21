#include "common.Dockerfile"
#include "image/alpine_edge.Dockerfile"
#include "env.Dockerfile"

RUN PKG_INSTALL(quassel-core qt5-qtbase-sqlite qt5-qtbase-mysql qt5-qtbase-postgresql)
VOLUME ["/var/lib/quassel/"]
ENTRYPOINT ["/usr/bin/quasselcore", "--configdir=/var/lib/quassel/"]
