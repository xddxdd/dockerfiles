#include "common.Dockerfile"
#include "image/alpine_edge.Dockerfile"
#include "env.Dockerfile"

#define APP_DEPS pcre zlib libatomic_ops openldap libgd
#define APP_BUILD_TOOLS build-base git autoconf automake libtool wget tar gd-dev pcre-dev zlib-dev libatomic_ops-dev unzip patch linux-headers openldap-dev util-linux binutils

ENV NGINX_VERSION=1.17.4 OPENSSL_VERSION=1.1.1d
RUN PKG_INSTALL(APP_DEPS APP_BUILD_TOOLS) \
    && cd /tmp \
    && wget -q http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
      && tar xf nginx-${NGINX_VERSION}.tar.gz \
      && cd /tmp/nginx-${NGINX_VERSION} \
      && PATCH(https://github.com/kn007/patch/raw/master/nginx.patch) \
      && PATCH(https://github.com/hakasenyang/openssl-patch/raw/master/nginx_strict-sni_1.15.10.patch) \
      && PATCH(https://gist.github.com/CarterLi/f6e21d4749984a255edc7b358b44bf58/raw/4a7ad66a9a29ffade34d824549ed663bc4b5ac98/use_openssl_md5_sha1.diff) \
      && cd /tmp \
    && git clone https://github.com/eustas/ngx_brotli.git \
      && cd /tmp/ngx_brotli && git submodule update --init && cd /tmp \
#if defined(ARCH_AMD64) || defined(ARCH_ARM64V8)
      && git clone https://github.com/cloudflare/zlib.git \
      && cd /tmp/zlib && make -f Makefile.in distclean && cd /tmp \
#endif
    && wget -q https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
      && tar xf openssl-${OPENSSL_VERSION}.tar.gz \
      && cd /tmp/openssl-${OPENSSL_VERSION} \
      && PATCH(https://github.com/hakasenyang/openssl-patch/raw/master/openssl-equal-1.1.1d.patch) \
      && PATCH(https://github.com/hakasenyang/openssl-patch/raw/master/openssl-1.1.1d-chacha_draft.patch) \
      && cd /tmp \
    && git clone https://github.com/openresty/headers-more-nginx-module.git \
    && cd /tmp/nginx-${NGINX_VERSION} \
#ifdef ARCH_I386
    && setarch i386 ./configure \
#else
    && ./configure \
#endif
       --with-threads \
       --with-file-aio \
       --with-http_addition_module \
       --with-http_auth_request_module \
       --with-http_gunzip_module \
       --with-http_gzip_static_module \
       --with-http_image_filter_module \
       --with-http_realip_module \
       --with-http_spdy_module \
       --with-http_ssl_module \
       --with-http_stub_status_module \
       --with-http_sub_module \
       --with-http_v2_module \
       --with-http_v2_hpack_enc \
       --with-libatomic \
#if defined(ARCH_AMD64) || defined(ARCH_ARM64V8)
       --with-zlib=/tmp/zlib \
#endif
       --add-module=/tmp/ngx_brotli \
       --add-module=/tmp/headers-more-nginx-module \
       --with-openssl=/tmp/openssl-${OPENSSL_VERSION} \
#if defined(ARCH_AMD64) || defined(ARCH_ARM64V8)
       --with-openssl-opt="zlib no-tests enable-ec_nistp_64_gcc_128 enable-tls1_3" \
#else
       --with-openssl-opt="zlib no-tests enable-tls1_3" \
#endif
       --with-cc-opt="-O3 -flto -fPIC -fPIE -fstack-protector-strong -Wformat -Werror=format-security -Wno-deprecated-declarations -Wno-strict-aliasing" \
#ifdef ARCH_I386
    && setarch i386 make -j4 \
    && setarch i386 make install \
#else
    && make -j4 \
    && make install \
#endif
    && strip /usr/local/nginx/sbin/* \
    && PKG_UNINSTALL(APP_BUILD_TOOLS) \
    && cd / && rm -rf /tmp/* \
    && ln -sf /usr/local/nginx/sbin/nginx /usr/sbin/nginx
#EXPOSE 80 443
ENTRYPOINT ["/usr/sbin/nginx"]
