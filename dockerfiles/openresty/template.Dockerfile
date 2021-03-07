#include "common.Dockerfile"
#include "image/debian_sid.Dockerfile"
#include "env.Dockerfile"

#define APP_DEPS libpcre3 zlib1g libgd3 util-linux libzstd1
#define APP_BUILD_TOOLS_EARLY libssl-dev openssl
#define APP_BUILD_TOOLS binutils build-essential git autoconf automake libtool wget libgd-dev libpcre3-dev zlib1g-dev libzstd-dev unzip patch cmake LINUX_HEADERS

ENV OPENRESTY_VERSION=1.19.3.1 OPENRESTY_NGINX_VERSION=1.19.3 NGINX_VERSION=1.19.7
COPY patches /tmp/
RUN cd /tmp \
    && PKG_INSTALL(APP_DEPS APP_BUILD_TOOLS APP_BUILD_TOOLS_EARLY) \
    && cd /tmp \
    && git clone https://github.com/nginx/nginx.git \
      && cd /tmp/nginx \
      && git diff release-${OPENRESTY_NGINX_VERSION} release-${NGINX_VERSION} > /tmp/nginx-upgrade.patch \
      && cd /tmp \
    && wget -q https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz \
      && tar xf openresty-${OPENRESTY_VERSION}.tar.gz \
      && cd /tmp/openresty-${OPENRESTY_VERSION}/bundle/nginx-${OPENRESTY_NGINX_VERSION} \ 
      && (PATCH_LOCAL(/tmp/nginx-upgrade.patch) || true) \
      && PATCH(https://github.com/kn007/patch/raw/master/nginx.patch) \
      && PATCH(https://github.com/kn007/patch/raw/master/use_openssl_md5_sha1.patch) \
      && PATCH_LOCAL(/tmp/patch-nginx/spdy.patch) \
      && PATCH_LOCAL(/tmp/patch-nginx/plain-protocol-use-after-spdy.patch) \
      && cd /tmp \
    && git clone https://github.com/eustas/ngx_brotli.git \
      && cd /tmp/ngx_brotli && git submodule update --init && cd /tmp \
#if defined(ARCH_AMD64) || defined(ARCH_ARM64V8)
      && git clone https://github.com/cloudflare/zlib.git \
      && cd /tmp/zlib && make -f Makefile.in distclean && cd /tmp \
#endif
    && git clone -b OQS-OpenSSL_1_1_1-stable https://github.com/open-quantum-safe/openssl.git \
      && cd openssl \
      && PATCH(https://github.com/hakasenyang/openssl-patch/raw/master/openssl-equal-1.1.1e-dev_ciphers.patch) \
      && PATCH_LOCAL(/tmp/patch-openssl/openssl-oqs-1.1.1i-chacha_draft.patch) \
      && cd /tmp \
    && git clone -b main https://github.com/open-quantum-safe/liboqs.git \
      && mkdir /tmp/liboqs/build && cd /tmp/liboqs/build \
      && cmake -DOQS_BUILD_ONLY_LIB=1 -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX=/tmp/openssl/oqs .. \
      && make -j4 && make install && cd /tmp \
    && git clone https://github.com/openresty/stream-echo-nginx-module.git \
      && cd /tmp/stream-echo-nginx-module \
      && PATCH_LOCAL(/tmp/stream-echo-nginx-module.patch) \
      && cd /tmp \
    && git clone https://github.com/tokers/zstd-nginx-module.git \
    && git clone https://github.com/vozlt/nginx-module-vts.git \
    && echo "Replace system OpenSSL with our own" \
    && PKG_UNINSTALL(APP_BUILD_TOOLS_EARLY) \
    && cd /tmp/openssl \
      && ./config --prefix=/usr --openssldir=/usr \
#if defined(ARCH_AMD64) || defined(ARCH_ARM64V8) || defined(ARCH_X32)
         zlib no-tests enable-ec_nistp_64_gcc_128 \
#else
         zlib no-tests \
#endif
      && make -j4 && make install && cd /tmp \
    && cd /tmp/openresty-${OPENRESTY_VERSION} \
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
       --with-http_plain_module \
       --with-http_spdy_module \
       --with-http_ssl_module \
       --with-http_stub_status_module \
       --with-http_sub_module \
       --with-http_v2_module \
       --with-http_v2_hpack_enc \
       --with-stream \
       --with-stream_realip_module \
       --with-stream_ssl_module \
       --with-stream_ssl_preread_module \
#if defined(ARCH_AMD64) || defined(ARCH_ARM64V8)
       --with-zlib=/tmp/zlib \
#endif
       --add-module=/tmp/ngx_brotli \
       --add-module=/tmp/stream-echo-nginx-module \
       --add-module=/tmp/zstd-nginx-module \
       --add-module=/tmp/nginx-module-vts \
       --with-openssl=/tmp/openssl \
#if defined(ARCH_AMD64) || defined(ARCH_ARM64V8) || defined(ARCH_X32)
       --with-openssl-opt="zlib no-tests enable-ec_nistp_64_gcc_128" \
#else
       --with-openssl-opt="zlib no-tests" \
#endif
       --with-cc-opt="-I/tmp/openssl/oqs/include" \
       --with-ld-opt="-L/tmp/openssl/oqs/lib" \
    && sed -i 's/libcrypto.a/libcrypto.a -loqs/g' build/nginx-${OPENRESTY_NGINX_VERSION}/objs/Makefile \
#ifdef ARCH_I386
    && setarch i386 make -j4 \
    && setarch i386 make install \
#else
    && make -j4 \
    && make install \
#endif
    && strip /usr/local/openresty/nginx/sbin/* \
    && PKG_UNINSTALL(APP_BUILD_TOOLS) \
    && cd / && FINAL_CLEANUP() \
    && ln -sf /usr/local/openresty/nginx/sbin/nginx /usr/sbin/nginx \
    && ln -sf /usr/local/openresty/nginx/sbin/nginx /usr/sbin/openresty
#EXPOSE 80 443
ENTRYPOINT ["/usr/sbin/nginx"]
