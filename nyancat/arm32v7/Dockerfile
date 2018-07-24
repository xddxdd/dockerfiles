FROM multiarch/alpine:armhf-edge
MAINTAINER Lan Tian "lantian@lantian.pub"
RUN apk --no-cache add build-base git autoconf automake \
    && cd /tmp \
    && git clone https://github.com/klange/nyancat.git \
      && cd nyancat && make \
      && cp src/nyancat /usr/bin \
      && cd .. && rm -rf nyancat \
    && git clone http://offog.org/git/onenetd.git \
      && cd /tmp/onenetd \
      && autoreconf -vfi && ./configure && make \
      && cp onenetd /usr/bin \
      && cd .. && rm -rf onenetd \
    && apk del --purge build-base git autoconf automake

ENTRYPOINT onenetd -v 0 23 nyancat --telnet
