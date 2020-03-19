#include "common.Dockerfile"
#include "image/debian_sid.Dockerfile"
#include "env.Dockerfile"

ADD healthcheck.sh /
RUN PKG_INSTALL(dnsutils pdns-server pdns-tools pdns-backend-\*)
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 CMD [ "sh", "/healthcheck.sh" ]
ENTRYPOINT ["/usr/sbin/pdns_server"]
