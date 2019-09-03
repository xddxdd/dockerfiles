#include "common.Dockerfile"
#include "image/alpine_edge.Dockerfile"
#include "env.Dockerfile"

ADD route.sh /
RUN chmod +x /route.sh
ENTRYPOINT ["/route.sh"]
