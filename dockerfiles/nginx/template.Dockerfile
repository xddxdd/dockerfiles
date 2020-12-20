#include "common.Dockerfile"
#include "image/debian_sid.Dockerfile"
#include "env.Dockerfile"

#define APP_DEPS libpcre3 zlib1g libgd3 util-linux libzstd1
#define APP_BUILD_TOOLS_EARLY libssl-dev openssl
#define APP_BUILD_TOOLS binutils build-essential git autoconf automake libtool wget libgd-dev libpcre3-dev zlib1g-dev libzstd-dev unzip patch cmake LINUX_HEADERS

ENV NGINX_VERSION=1.19.6
COPY patches /tmp/
RUN cd /tmp \
    && PKG_INSTALL(APP_DEPS APP_BUILD_TOOLS APP_BUILD_TOOLS_EARLY) \
    && cd /tmp \
    && wget -q http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
      && tar xf nginx-${NGINX_VERSION}.tar.gz \
      && cd /tmp/nginx-${NGINX_VERSION} \
      && echo "Adding OpenResty patches" \
         && PATCH_LOCAL(/tmp/patch-nginx/nginx-1.17.10-resolver_conf_parsing.patch) \
         && PATCH_LOCAL(/tmp/patch-nginx/nginx-1.17.10-upstream_pipelining.patch) \
         && PATCH_LOCAL(/tmp/patch-nginx/nginx-1.17.10-no_error_pages.patch) \
         && PATCH_LOCAL(/tmp/patch-nginx/nginx-1.17.10-log_escape_non_ascii.patch) \
         && PATCH_LOCAL(/tmp/patch-nginx/nginx-1.17.10-larger_max_error_str.patch) \
         && PATCH_LOCAL(/tmp/patch-nginx/nginx-1.17.10-upstream_timeout_fields.patch) \
         && PATCH_LOCAL(/tmp/patch-nginx/nginx-1.17.10-safe_resolver_ipv6_option.patch) \
         && PATCH_LOCAL(/tmp/patch-nginx/nginx-1.17.10-socket_cloexec.patch) \
         && PATCH_LOCAL(/tmp/patch-nginx/nginx-1.17.10-reuseport_close_unused_fds.patch) \
      && echo "Adding other patches" \
      && PATCH(https://github.com/kn007/patch/raw/master/nginx.patch) \
      && PATCH(https://github.com/kn007/patch/raw/master/use_openssl_md5_sha1.patch) \
      && PATCH_LOCAL(/tmp/patch-nginx/spdy.patch) \
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
    && git clone -b v2.1-agentzh https://github.com/openresty/luajit2.git \
      && cd /tmp/luajit2 \
      && make -j4 && make install \
      && cd /tmp \
    && git clone https://github.com/vision5/ngx_devel_kit.git \
    && git clone https://github.com/openresty/headers-more-nginx-module.git \
    && git clone https://github.com/openresty/set-misc-nginx-module.git \
    && git clone https://github.com/tokers/zstd-nginx-module.git \
    && git clone https://github.com/vozlt/nginx-module-vts.git \
    && git clone https://github.com/openresty/lua-nginx-module.git \
    && git clone https://github.com/openresty/stream-lua-nginx-module.git \
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
    && export LUAJIT_LIB=/usr/local/lib \
    && export LUAJIT_INC=/usr/local/include/luajit-2.1 \
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
       --with-stream \
       --with-stream_realip_module \
       --with-stream_ssl_module \
       --with-stream_ssl_preread_module \
#if defined(ARCH_AMD64) || defined(ARCH_ARM64V8)
       --with-zlib=/tmp/zlib \
#endif
       --add-module=/tmp/ngx_brotli \
       --add-module=/tmp/ngx_devel_kit \
       --add-module=/tmp/headers-more-nginx-module \
       --add-module=/tmp/set-misc-nginx-module \
       --add-module=/tmp/zstd-nginx-module \
       --add-module=/tmp/nginx-module-vts \
       --add-module=/tmp/lua-nginx-module \
       --add-module=/tmp/stream-lua-nginx-module \
       --with-openssl=/tmp/openssl \
#if defined(ARCH_AMD64) || defined(ARCH_ARM64V8) || defined(ARCH_X32)
       --with-openssl-opt="zlib no-tests enable-ec_nistp_64_gcc_128" \
#else
       --with-openssl-opt="zlib no-tests" \
#endif
       --with-cc-opt="-I/tmp/openssl/oqs/include" \
       --with-ld-opt="-L/tmp/openssl/oqs/lib -Wl,-rpath,/path/to/luajit/lib" \
    && sed -i 's/libcrypto.a/libcrypto.a -loqs/g' objs/Makefile \
#ifdef ARCH_I386
    && setarch i386 make -j4 \
    && setarch i386 make install \
#else
    && make -j4 \
    && make install \
#endif
    && strip /usr/local/nginx/sbin/* \
    && PKG_UNINSTALL(APP_BUILD_TOOLS) \
    && cd / && FINAL_CLEANUP() \
    && ln -sf /usr/local/nginx/sbin/nginx /usr/sbin/nginx
#EXPOSE 80 443
ENTRYPOINT ["/usr/sbin/nginx"]
