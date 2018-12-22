ARG THIS_ARCH_ALT=amd64
FROM multiarch/alpine:${THIS_ARCH_ALT}-v3.8

ARG THIS_ARCH=amd64
ARG THIS_ARCH_ALT=amd64

LABEL Lan Tian "lantian@lantian.pub"
ENV NGINX_VERSION=1.15.7 OPENSSL_VERSION=1.1.1a
RUN apk --no-cache add build-base git autoconf automake libtool wget tar pcre-dev zlib-dev libatomic_ops-dev unzip jemalloc-dev patch linux-headers openldap-dev \
    && cd /tmp \
    && wget -q http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
      && tar xf nginx-${NGINX_VERSION}.tar.gz \
      && cd /tmp/nginx-${NGINX_VERSION} \
      && wget -qO- https://github.com/kn007/patch/raw/master/nginx.patch | patch -p1 \
      && wget -qO- https://github.com/kn007/patch/raw/master/nginx_auto_using_PRIORITIZE_CHACHA.patch | patch -p1 \
      && wget -qO- https://github.com/kn007/patch/raw/master/nginx_strict-sni.patch | patch -p1 \
      && wget -qO- https://gist.github.com/CarterLi/f6e21d4749984a255edc7b358b44bf58/raw/4a7ad66a9a29ffade34d824549ed663bc4b5ac98/use_openssl_md5_sha1.diff | patch -p1 \
      && cd /tmp \
    && git clone https://github.com/eustas/ngx_brotli.git \
      && cd /tmp/ngx_brotli && git submodule update --init && cd /tmp \
    && if [ "$THIS_ARCH" == "amd64" ] || [ "$THIS_ARCH" == "arm64v8" ]; then \
        git clone https://github.com/cloudflare/zlib.git \
        && cd /tmp/zlib && make -f Makefile.in distclean && cd /tmp \
      ; fi \
    && wget -q https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
      && tar xf openssl-${OPENSSL_VERSION}.tar.gz \
      && cd /tmp/openssl-${OPENSSL_VERSION} \
      && wget -qO- https://github.com/hakasenyang/openssl-patch/raw/master/openssl-equal-1.1.1a_ciphers.patch | patch -p1 \
      && wget -qO- https://github.com/hakasenyang/openssl-patch/raw/master/openssl-1.1.1a-chacha_draft.patch | patch -p1 \
      && cd /tmp \
    && git clone https://github.com/openresty/headers-more-nginx-module.git \
    && git clone https://github.com/kvspb/nginx-auth-ldap.git \
    && cd /tmp/nginx-${NGINX_VERSION} \
    && CC_OPENSSL_OPT=$([ "$THIS_ARCH" == "amd64" ] || [ "$THIS_ARCH" == "arm64v8" ] && echo "enable-ec_nistp_64_gcc_128" || echo) \
    && ./configure \
       --with-threads \
       --with-file-aio \
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
       --with-http_auth_request_module \
       --with-libatomic \
       $([ "$THIS_ARCH" == "amd64" ] || [ "$THIS_ARCH" == "arm64v8" ] && echo "--with-zlib=/tmp/zlib" || echo) \
       --add-module=/tmp/ngx_brotli \
       --add-module=/tmp/headers-more-nginx-module \
       --add-module=/tmp/nginx-auth-ldap \
       --with-openssl=/tmp/openssl-${OPENSSL_VERSION} \
       --with-openssl-opt="zlib no-tests ${CC_OPENSSL_OPT} enable-tls1_3 -ljemalloc" \
       --with-ld-opt="-ljemalloc" \
       --with-cc-opt="-O3 -flto -fPIC -fPIE -fstack-protector-strong -Wformat -Werror=format-security -Wno-deprecated-declarations -Wno-strict-aliasing" \
    && make -j4 \
    && make install \
    && apk del build-base git autoconf automake wget tar unzip patch linux-headers \
    && cd / && rm -rf /tmp/* \
    && ln -sf /usr/local/nginx/sbin/nginx /usr/sbin/nginx
#EXPOSE 80 443
ENTRYPOINT ["/usr/sbin/nginx"]
