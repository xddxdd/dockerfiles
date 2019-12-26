#include "common.Dockerfile"
#include "image/debian_buster.Dockerfile"
#include "env.Dockerfile"

ADD route.sh /
RUN chmod +x /route.sh
ENTRYPOINT ["/route.sh"]
