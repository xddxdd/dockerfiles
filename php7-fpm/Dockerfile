ARG THIS_ARCH_ALT=amd64
FROM multiarch/alpine:${THIS_ARCH_ALT}-edge

LABEL Lan Tian "lantian@lantian.pub"
RUN mkdir /usr/log && mkdir /run/php \
    && apk -q --no-cache search php7- | egrep -v "(apache|dev|litespeed|ssh)" | xargs apk --no-cache add
COPY www.conf /etc/php7/php-fpm.d/www.conf
COPY php.ini /etc/php7/php.ini
COPY php-fpm.conf /etc/php7/php-fpm.conf
EXPOSE 9000
ENTRYPOINT ["php-fpm7"]
