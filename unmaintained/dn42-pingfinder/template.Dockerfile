#include "common.Dockerfile"
#include "image/alpine_edge.Dockerfile"
#include "env.Dockerfile"

ADD pingfinder.sh /
ADD crontab /etc/crontabs/root
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
RUN PKG_INSTALL(curl bash)
ENTRYPOINT ["/usr/sbin/crond", "-f"]
