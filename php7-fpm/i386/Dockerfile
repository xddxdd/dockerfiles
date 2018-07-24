FROM multiarch/alpine:i386-edge
MAINTAINER Lan Tian "lantian@lantian.pub"
RUN mkdir /usr/log && mkdir /run/php \
    && apk --no-cache add php7-fpm php7-bz2 php7-curl php7-gd php7-json \
                          php7-mbstring php7-memcached php7-mysqli php7-pdo_mysql \
                          php7-redis php7-sqlite3 php7-pdo_sqlite php7-xml \
                          php7-xmlrpc php7-zip php7-intl php7-ctype php7-tokenizer
ADD www.conf /etc/php7/php-fpm.d/www.conf
ADD php.ini /etc/php7/php.ini
ADD php-fpm.conf /etc/php7/php-fpm.conf
EXPOSE 9000
ENTRYPOINT ["php-fpm7"]
