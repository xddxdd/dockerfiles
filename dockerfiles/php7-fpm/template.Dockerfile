#include "common.Dockerfile"
#include "image/debian_sid.Dockerfile"
#include "env.Dockerfile"

#define APP_DEPS \
   php-apcu \
   php-apcu-bc \
   php-geoip \
   php-imagick \
   php-memcache \
   php7.4 \
   php7.4-bcmath \
   php7.4-bz2 \
   php7.4-cli \
   php7.4-common \
   php7.4-curl \
   php7.4-fpm \
   php7.4-gd \
   php7.4-gmp \
   php7.4-imap \
   php7.4-intl \
   php7.4-json \
   php7.4-ldap \
   php7.4-mbstring \
   php7.4-mysql \
   php7.4-opcache \
   php7.4-pgsql \
   php7.4-readline \
   php7.4-sqlite3 \
   php7.4-xml \
   php7.4-xmlrpc \
   php7.4-zip
#define APP_BUILD_TOOLS build-essential autoconf automake git wget php7.4-dev

ENV LIBMAXMINDDB_VERSION=1.4.2
RUN mkdir /usr/log && mkdir /run/php \
    && PKG_INSTALL(APP_DEPS APP_BUILD_TOOLS) \
    && echo "daemonize = no" >> /etc/php/7.4/fpm/php-fpm.conf \
    && ln -sf /usr/sbin/php-fpm7.4 /usr/sbin/php-fpm \
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
       && sh -c "echo extension=maxminddb.so > /etc/php/7.4/fpm/conf.d/maxminddb.ini" \
    && PKG_UNINSTALL(APP_BUILD_TOOLS) \
    && FINAL_CLEANUP()
EXPOSE 9000
ENTRYPOINT ["/usr/sbin/php-fpm"]
