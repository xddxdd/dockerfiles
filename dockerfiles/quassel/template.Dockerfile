#include "image/multiarch_alpine_edge.Dockerfile"
#include "env.Dockerfile"

RUN apk --no-cache add quassel-core qt5-qtbase-sqlite qt5-qtbase-mysql qt5-qtbase-postgresql
VOLUME ["/var/lib/quassel/"]
ENTRYPOINT ["/usr/bin/quasselcore", "--configdir=/var/lib/quassel/"]
