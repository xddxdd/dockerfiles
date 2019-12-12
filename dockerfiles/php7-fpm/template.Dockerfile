#include "common.Dockerfile"
#include "image/alpine_edge.Dockerfile"
#include "env.Dockerfile"

#define APP_DEPS libmaxminddb
#define APP_BUILD_TOOLS php7-dev build-base autoconf automake git libmaxminddb-dev

# See https://github.com/codecasts/php-alpine
ADD https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub
RUN PKG_INSTALL(ca-certificates) \
    && echo "https://dl.bintray.com/php-alpine/v3.10/php-7.4" >> /etc/apk/repositories \
    && apk update \
    && mkdir /usr/log && mkdir /run/php \
    && sh -c "apk -q --no-cache search php7- | egrep -v \"(apache|litespeed|gmagick|libsodium)\" | xargs apk --no-cache add" \
    && PKG_INSTALL(APP_DEPS APP_BUILD_TOOLS) \
    && cd /root \
    && git clone https://github.com/maxmind/MaxMind-DB-Reader-php.git \
      && cd MaxMind-DB-Reader-php/ext && phpize7 \
      && ./configure --with-php-config=/usr/bin/php-config7 \
      && make && make install \
      && cd /root && rm -rf MaxMind-DB-Reader-php \
      && sh -c "echo extension=maxminddb.so > /etc/php7/conf.d/maxminddb.ini" \
    && PKG_UNINSTALL(APP_BUILD_TOOLS)
ADD www.conf /etc/php7/php-fpm.d/www.conf
ADD php.ini /etc/php7/php.ini
ADD php-fpm.conf /etc/php7/php-fpm.conf
EXPOSE 9000
ENTRYPOINT ["php-fpm7"]
