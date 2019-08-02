#include "image/multiarch_debian_buster.Dockerfile"
#include "env.Dockerfile"

COPY bird-restricted.sh /usr/sbin/
RUN apt-get update \
    && apt-get install -y bird busybox-static \
    && rm -rf /var/cache/apt \
    && chmod +x /usr/sbin/bird-restricted.sh

STOPSIGNAL SIGKILL
ENTRYPOINT ["/bin/busybox", "telnetd", "-l", "/usr/sbin/bird-restricted.sh", "-K", "-F"]