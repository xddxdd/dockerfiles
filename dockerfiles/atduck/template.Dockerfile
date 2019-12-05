#include "common.Dockerfile"
#include "image/debian_buster.Dockerfile"
#include "env.Dockerfile"

RUN PKG_INSTALL(git slirp perl libio-pty-perl tini) \
  && git clone https://github.com/nandhp/atduck.git \
  && ln -sf /usr/bin/slirp /atduck/slirp-nandhp-patch \
  && PKG_UNINSTALL(git) \
  && apt-get autoremove --purge -y
WORKDIR /atduck
ENTRYPOINT ["tini", "/atduck/atduck", "--", "-l", "0.0.0.0:5555"]
