#include "common.Dockerfile"
#include "image/debian_buster.Dockerfile"
#include "env.Dockerfile"

#if defined(ARCH_RISCV64)
#define APP_DEPS libpcre3 zlib1g libgd3 util-linux libzstd1
#else
#define APP_DEPS libpcre3 zlib1g libatomic-ops-dev libgd3 util-linux libzstd1
#endif

#if defined(ARCH_AMD64)
#define APP_BUILD_TOOLS binutils build-essential git autoconf automake libtool wget libgd-dev libpcre3-dev zlib1g-dev libzstd-dev unzip patch LINUX_HEADERS cmake
#define APP_BUILD_TOOLS_UNSTABLE rustc cargo golang-go
#else
#define APP_BUILD_TOOLS binutils build-essential git autoconf automake libtool wget libgd-dev libpcre3-dev zlib1g-dev libzstd-dev unzip patch LINUX_HEADERS
#endif

ENV NGINX_VERSION=1.17.9 OPENSSL_VERSION=1.1.1e QUICHE_VERSION=2f2dfab
COPY patches /tmp/
RUN cd /tmp \
    && PKG_INSTALL(APP_DEPS APP_BUILD_TOOLS) \
#if defined(ARCH_AMD64)
    && sh -c "echo \"deb http://deb.debian.org/debian/ unstable main\" > /etc/apt/sources.list.d/unstable.list" \
    && sh -c "printf \"Package: *\nPin: release a=unstable\nPin-Priority: 90\n\" > /etc/apt/preferences.d/limit-unstable" \
    && PKG_INSTALL(APP_BUILD_TOOLS_UNSTABLE) -t unstable \
    && git clone --recursive https://github.com/cloudflare/quiche \
      && cd /tmp/quiche \
      && git checkout ${QUICHE_VERSION} \
      && cd /tmp \
#endif
    && wget -q http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
      && tar xf nginx-${NGINX_VERSION}.tar.gz \
      && cd /tmp/nginx-${NGINX_VERSION} \
#if defined(ARCH_AMD64)
      && PATCH(https://github.com/kn007/patch/raw/master/nginx_with_quic.patch) \
      && PATCH_LOCAL(/tmp/nginx-spdy-patch-quic-aware.patch) \
#else
      && PATCH(https://github.com/kn007/patch/raw/master/nginx.patch) \
      && PATCH_LOCAL(/tmp/nginx-spdy-patch.patch) \
#endif
      && PATCH(https://github.com/hakasenyang/openssl-patch/raw/master/nginx_strict-sni_1.15.10.patch) \
      && PATCH(https://gist.github.com/CarterLi/f6e21d4749984a255edc7b358b44bf58/raw/4a7ad66a9a29ffade34d824549ed663bc4b5ac98/use_openssl_md5_sha1.diff) \
      && cd /tmp \
    && git clone https://github.com/eustas/ngx_brotli.git \
      && cd /tmp/ngx_brotli && git submodule update --init && cd /tmp \
#if defined(ARCH_AMD64) || defined(ARCH_ARM64V8)
      && git clone https://github.com/cloudflare/zlib.git \
      && cd /tmp/zlib && make -f Makefile.in distclean && cd /tmp \
#endif
#if !defined(ARCH_AMD64)
    && wget -q https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
      && tar xf openssl-${OPENSSL_VERSION}.tar.gz \
      && cd /tmp/openssl-${OPENSSL_VERSION} \
      && PATCH(https://github.com/hakasenyang/openssl-patch/raw/master/openssl-equal-1.1.1d.patch) \
      && PATCH(https://github.com/hakasenyang/openssl-patch/raw/master/openssl-1.1.1d-chacha_draft.patch) \
      && cd /tmp \
#endif
    && git clone https://github.com/openresty/headers-more-nginx-module.git \
    && git clone https://github.com/tokers/zstd-nginx-module.git \
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
#if !defined(ARCH_RISCV64)
       --with-libatomic \
#endif
#if defined(ARCH_AMD64) || defined(ARCH_ARM64V8)
       --with-zlib=/tmp/zlib \
#endif
       --add-module=/tmp/ngx_brotli \
       --add-module=/tmp/headers-more-nginx-module \
       --add-module=/tmp/zstd-nginx-module \
#if defined(ARCH_AMD64)
       --with-http_v3_module \
       --with-openssl=/tmp/quiche/deps/boringssl \
       --with-quiche=/tmp/quiche \
#else
       --with-openssl=/tmp/openssl-${OPENSSL_VERSION} \
#endif
#if defined(ARCH_ARM64V8)
       --with-openssl-opt="zlib no-tests enable-ec_nistp_64_gcc_128 enable-tls1_3" \
#elif !defined(ARCH_AMD64)
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
#if defined(ARCH_AMD64)
    && PKG_UNINSTALL(APP_BUILD_TOOLS APP_BUILD_TOOLS_UNSTABLE) \
#else
    && PKG_UNINSTALL(APP_BUILD_TOOLS) \
#endif
    && cd / && rm -rf /tmp/* \
    && ln -sf /usr/local/nginx/sbin/nginx /usr/sbin/nginx
#EXPOSE 80 443
ENTRYPOINT ["/usr/sbin/nginx"]
