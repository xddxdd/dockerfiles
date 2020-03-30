#include "common.Dockerfile"
#include "image/debian_sid.Dockerfile"
#include "env.Dockerfile"

#define APP_DEPS busybox-static libncurses6 libncursesw6 libreadline8
#define APP_BUILD_TOOLS build-essential bison flex libncurses-dev libreadline-dev LINUX_HEADERS wget patch binutils

ADD bird-restricted.sh /usr/local/sbin/
ENV BIRD_VERSION=2.0.7
RUN PKG_INSTALL(APP_DEPS APP_BUILD_TOOLS) \
    && cd /tmp \
    && UNTARGZ(ftp://bird.network.cz/pub/bird/bird-${BIRD_VERSION}.tar.gz) \
       && cd /tmp/bird-${BIRD_VERSION} \
       && ./configure --prefix=/usr \
          --sysconfdir=/etc \
          --mandir=/usr/share/man \
          --localstatedir=/var \
       && make -j4 && make install \
       && strip /usr/sbin/bird* \
    && cd / \
    && chmod +x /usr/local/sbin/bird-restricted.sh \
    && PKG_UNINSTALL(APP_BUILD_TOOLS) \
    && FINAL_CLEANUP()

STOPSIGNAL SIGKILL
ENTRYPOINT ["/bin/busybox", "telnetd", "-l", "/usr/local/sbin/bird-restricted.sh", "-K", "-F"]
