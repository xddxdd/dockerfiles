#include "image/multiarch_alpine_edge.Dockerfile"
#include "env.Dockerfile"

RUN mkdir /usr/log && mkdir /run/php \
    && sh -c "apk -q --no-cache search php7- | egrep -v \"(apache|dev|litespeed|gmagick)\" | xargs apk --no-cache add" \
    && apk --no-cache add php7-dev build-base git libmaxminddb libmaxminddb-dev \
    && cd /root \
    && git clone https://github.com/maxmind/MaxMind-DB-Reader-php.git \
      && cd MaxMind-DB-Reader-php/ext && phpize && ./configure && make && make install \
      && cd /root && rm -rf MaxMind-DB-Reader-php \
      && sh -c "echo extension=maxminddb.so > /etc/php7/conf.d/maxminddb.ini" \
    && apk del --purge php7-dev build-base git libmaxminddb-dev
COPY www.conf /etc/php7/php-fpm.d/www.conf
COPY php.ini /etc/php7/php.ini
COPY php-fpm.conf /etc/php7/php-fpm.conf
EXPOSE 9000
ENTRYPOINT ["php-fpm7"]
