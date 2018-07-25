FROM multiarch/alpine:armhf-edge
MAINTAINER Lan Tian "lantian@lantian.pub"
ENV NGINX_VERSION=1.15.2 OPENSSL_VERSION=OpenSSL_1_1_1-pre8
RUN apk --no-cache add build-base git autoconf automake libtool wget tar zlib-dev pcre-dev unzip jemalloc-dev patch linux-headers \
    && cd /tmp \
    && wget -q http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
      && tar xf nginx-${NGINX_VERSION}.tar.gz \
      && cd /tmp/nginx-${NGINX_VERSION} \
      && wget -qO- https://github.com/kn007/patch/raw/master/nginx.patch | patch -p1 \
      && wget -qO- https://github.com/kn007/patch/raw/master/fix_nginx_hpack_push_error.patch | patch -p1 \
      && cd /tmp \
    && git clone https://github.com/google/ngx_brotli.git \
      && cd /tmp/ngx_brotli && git submodule update --init && cd /tmp \
    && wget -q https://github.com/openssl/openssl/archive/${OPENSSL_VERSION}.zip \
      && unzip -q ${OPENSSL_VERSION}.zip \
      && cd /tmp/openssl-${OPENSSL_VERSION} \
      && wget -qO- https://github.com/hakasenyang/openssl-patch/raw/master/openssl-equal-pre8_ciphers.patch | patch -p1 \
      && cd /tmp \
    && git clone https://github.com/openresty/headers-more-nginx-module.git \
    && cd /tmp/nginx-${NGINX_VERSION} \
    && ./configure \
       --with-threads \
       --with-file-aio \
       --with-ipv6 \
       --with-http_ssl_module \
       --with-http_spdy_module \
       --with-http_v2_module \
       --with-http_v2_hpack_enc \
       --with-http_gzip_static_module \
       --with-http_gunzip_module \
       --with-http_realip_module \
       --with-http_stub_status_module \
       --with-http_sub_module \
       --with-http_addition_module \
       --add-module=/tmp/ngx_brotli \
       --add-module=/tmp/headers-more-nginx-module \
       --with-openssl=/tmp/openssl-${OPENSSL_VERSION} \
       --with-openssl-opt='no-tests enable-tls1_3 -ljemalloc' \
       --with-ld-opt="-ljemalloc" \
       --with-cc-opt="-O3 -flto -fPIC -fPIE -fstack-protector-strong -Wformat -Werror=format-security -Wno-deprecated-declarations -Wno-strict-aliasing" \
    && make -j2 \
    && make install \
    && apk del build-base git autoconf automake wget tar unzip patch linux-headers || true \
    && cd / && rm -rf /tmp/* \
    && ln -sf /usr/local/nginx/sbin/nginx /usr/sbin/nginx \
    && ln -sf /dev/stdout /usr/local/nginx/logs/access.log \
      && ln -sf /dev/stderr /usr/local/nginx/logs/error.log
#EXPOSE 80 443
ENTRYPOINT /usr/sbin/nginx
