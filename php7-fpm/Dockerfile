FROM debian:jessie-slim
MAINTAINER Lan Tian "lantian@lantian.pub"
RUN apt-get update \
    && apt-get install -y wget apt-transport-https lsb-release ca-certificates \
    && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
    && apt-get update \
    && apt-get install -y php7.2-fpm php7.2-bz2 php7.2-curl php7.2-gd php7.2-json php7.2-mbstring php7.2-memcached php7.2-mysql php7.2-redis php7.2-sqlite3 php7.2-xml php7.2-xmlrpc php7.2-zip php7.2-intl sudo \
    && apt-get clean
ADD www.conf /etc/php/7.2/fpm/pool.d/www.conf
ADD php.ini /etc/php/7.2/fpm/php.ini
ADD php-fpm.conf /etc/php/7.2/fpm/php-fpm.conf
RUN mkdir /usr/log && mkdir /run/php
EXPOSE 9000
ENTRYPOINT ["php-fpm7.2"]
