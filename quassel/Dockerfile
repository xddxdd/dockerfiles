ARG THIS_ARCH_ALT=amd64
FROM multiarch/alpine:${THIS_ARCH_ALT}-edge

LABEL Lan Tian "lantian@lantian.pub"
RUN apk --no-cache add quassel-core qt5-qtbase-sqlite qt5-qtbase-mysql qt5-qtbase-postgresql
VOLUME ["/var/lib/quassel/"]
ENTRYPOINT ["/usr/bin/quasselcore", "--configdir=/var/lib/quassel/"]
