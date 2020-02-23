#include "common.Dockerfile"
#include "image/debian_buster.Dockerfile"
#include "env.Dockerfile"

#define APP_DEPS libmaxminddb0
#define APP_BUILD_TOOLS build-essential autoconf automake git libmaxminddb-dev

# https://packages.sury.org/php/README.txt
RUN mkdir /usr/log && mkdir /run/php \
    && ln -sf /bin/sed /usr/bin/sed \
#if defined(ARCH_AMD64) || defined(ARCH_I386) || defined(ARCH_ARM32V7) || defined(ARCH_ARM64V8)
    && PKG_INSTALL(apt-transport-https lsb-release ca-certificates curl wget APP_DEPS APP_BUILD_TOOLS) \
    && WGET(https://packages.sury.org/php/apt.gpg) -O /etc/apt/trusted.gpg.d/php.gpg \
    && echo "deb https://packages.sury.org/php/ buster main" > /etc/apt/sources.list.d/php.list \
    && apt-get -qq update \
    && sh -c "apt-cache search php7.4 | cut -d' ' -f1 | egrep -v \"(apache|litespeed|gmagick|libsodium|embed|yac|dbgsym)\" | xargs apt-get -qq install -y --no-install-recommends" \
    && echo "daemonize = no" >> /etc/php/7.4/fpm/php-fpm.conf \
    && ln -sf /usr/sbin/php-fpm7.4 /usr/sbin/php-fpm \
#else
    && PKG_INSTALL(APP_DEPS APP_BUILD_TOOLS) \
    && sh -c "apt-cache search php7.3 | cut -d' ' -f1 | egrep -v \"(apache|litespeed|gmagick|libsodium|embed|yac|dbgsym)\" | xargs apt-get -qq install -y --no-install-recommends" \
    && echo "daemonize = no" >> /etc/php/7.3/fpm/php-fpm.conf \
    && ln -sf /usr/sbin/php-fpm7.3 /usr/sbin/php-fpm \
#endif
    && cd /tmp \
    && git clone https://github.com/maxmind/MaxMind-DB-Reader-php.git \
      && cd MaxMind-DB-Reader-php/ext \
      && phpize && ./configure \
      && make && make install \
      && cd /tmp && rm -rf MaxMind-DB-Reader-php \
#if defined(ARCH_AMD64) || defined(ARCH_I386) || defined(ARCH_ARM32V7) || defined(ARCH_ARM64V8)
      && sh -c "echo extension=maxminddb.so > /etc/php/7.4/fpm/conf.d/maxminddb.ini" \
#else
      && sh -c "echo extension=maxminddb.so > /etc/php/7.3/fpm/conf.d/maxminddb.ini" \
#endif
    && PKG_UNINSTALL(APP_BUILD_TOOLS)
EXPOSE 9000
ENTRYPOINT ["/usr/sbin/php-fpm"]
