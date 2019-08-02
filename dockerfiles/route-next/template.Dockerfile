#include "image/multiarch_alpine_edge.Dockerfile"
#include "env.Dockerfile"

COPY route.sh /
RUN chmod +x /route.sh
ENTRYPOINT ["/route.sh"]
