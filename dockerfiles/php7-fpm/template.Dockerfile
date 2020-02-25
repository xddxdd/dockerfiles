#include "common.Dockerfile"
#include "image/debian_sid.Dockerfile"
#include "env.Dockerfile"

#define APP_DEPS
#define APP_BUILD_TOOLS build-essential autoconf automake git wget

ENV PHP_VERSION=7.4 LIBMAXMINDDB_VERSION=1.4.2
RUN mkdir /usr/log && mkdir /run/php \
    && PKG_INSTALL(APP_DEPS APP_BUILD_TOOLS) \
    && sh -c "apt-cache search php${PHP_VERSION} | cut -d' ' -f1 | egrep -v \"(apache|litespeed|gmagick|libsodium|embed|yac|dbgsym)\" | xargs apt-get -qq install -y --no-install-recommends" \
    && echo "daemonize = no" >> /etc/php/${PHP_VERSION}/fpm/php-fpm.conf \
    && ln -sf /usr/sbin/php-fpm${PHP_VERSION} /usr/sbin/php-fpm \
    && cd /tmp \
    && UNTARGZ(https://github.com/maxmind/libmaxminddb/releases/download/${LIBMAXMINDDB_VERSION}/libmaxminddb-${LIBMAXMINDDB_VERSION}.tar.gz) \
       && cd libmaxminddb-${LIBMAXMINDDB_VERSION} \
       && ./configure && make -j4 && make install \
       && cd /tmp && rm -rf libmaxminddb-${LIBMAXMINDDB_VERSION} \
    && cd /tmp \
    && git clone https://github.com/maxmind/MaxMind-DB-Reader-php.git \
       && cd MaxMind-DB-Reader-php/ext \
       && phpize && ./configure \
       && make -j4 && make install \
       && cd /tmp && rm -rf MaxMind-DB-Reader-php \
       && sh -c "echo extension=maxminddb.so > /etc/php/${PHP_VERSION}/fpm/conf.d/maxminddb.ini" \
    && PKG_UNINSTALL(APP_BUILD_TOOLS)
EXPOSE 9000
ENTRYPOINT ["/usr/sbin/php-fpm"]
