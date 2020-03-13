#include "common.Dockerfile"
#include "image/debian_buster.Dockerfile"
#include "env.Dockerfile"

ADD route.sh /
ENTRYPOINT ["sh", "/route.sh"]
