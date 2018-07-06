FROM debian:jessie-slim
MAINTAINER Lan Tian "lantian@lantian.pub"
RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install php5-cli php5-redis php5-curl ssl-cert \
    && apt-get clean
ADD hitokoto.php /
ENTRYPOINT php /hitokoto.php
