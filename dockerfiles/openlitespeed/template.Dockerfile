#include "common.Dockerfile"
#include "image/debian_buster.Dockerfile"
#include "env.Dockerfile"

#if !defined(ARCH_I386) && !defined(ARCH_AMD64)
#error "OpenLitespeed only supports i386 or amd64"
#endif

ENV LIBONIG2_VERSION="5.9.5-3.2+deb8u1"
ADD sources.list /etc/apt/sources.list
ADD http://rpms.litespeedtech.com/debian/lst_debian_repo.gpg /etc/apt/trusted.gpg.d/lst_debian_repo.gpg
ADD http://rpms.litespeedtech.com/debian/lst_repo.gpg /etc/apt/trusted.gpg.d/lst_repo.gpg
RUN chmod 644 /etc/apt/trusted.gpg.d/* \
    && PKG_INSTALL(openlitespeed ols-pagespeed ols-modsecurity) \
    && sh -c "apt-cache search lsphp | cut -f1 -d' ' | egrep -v \"(dbg|dev|source)\" | xargs apt-get install -y" \
    && ln -sf /usr/local/lsws/lsphp53/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp53 \
    && ln -sf /usr/local/lsws/lsphp54/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp54 \
    && ln -sf /usr/local/lsws/lsphp55/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp55 \
    && ln -sf /usr/local/lsws/lsphp56/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp56 \
    && ln -sf /usr/local/lsws/lsphp56/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp5 \
    && ln -sf /usr/local/lsws/lsphp70/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp70 \
    && ln -sf /usr/local/lsws/lsphp71/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp71 \
    && ln -sf /usr/local/lsws/lsphp72/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp72 \
    && ln -sf /usr/local/lsws/lsphp73/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp73 \
    && ln -sf /usr/local/lsws/lsphp73/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp7 \
    && ln -sf /usr/local/lsws/lsphp73/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp \
    && rm -rf /var/cache/apt
ENTRYPOINT ["sh", "-c", "/usr/local/lsws/bin/lswsctrl start; tail -f /usr/local/lsws/logs/error.log"]
