#include "common.Dockerfile"
#include "image/debian_buster.Dockerfile"
#include "env.Dockerfile"

ADD healthcheck.sh /
RUN PKG_INSTALL(dnsutils dnsmasq)
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 CMD [ "sh", "/healthcheck.sh" ]
ENTRYPOINT ["/usr/sbin/dnsmasq", "-d"]
