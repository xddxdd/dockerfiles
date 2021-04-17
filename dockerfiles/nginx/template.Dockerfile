#include "common.Dockerfile"
#include "image/debian_sid.Dockerfile"
#include "env.Dockerfile"

#define APP_DEPS libpcre3 zlib1g libgd3 util-linux libzstd1
#define APP_BUILD_TOOLS binutils build-essential git autoconf automake libtool wget libgd-dev libpcre3-dev zlib1g-dev libzstd-dev unzip patch cmake libunwind-dev pkg-config python3 python3-psutil golang curl LINUX_HEADERS

ENV NGINX_VERSION=1.19.10 QUICHE_VERSION=84c0f20
COPY patches /tmp/
RUN cd /tmp \
    && PKG_INSTALL(APP_DEPS APP_BUILD_TOOLS) \
    && curl https://sh.rustup.rs -sSf | sh -s -- -y \
       && export PATH="/root/.cargo/bin:$PATH" \
    && cd /tmp \
    && wget -q http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
       && tar xf nginx-${NGINX_VERSION}.tar.gz \
       && mv nginx-${NGINX_VERSION} nginx \
       && cd /tmp/nginx \
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
#if defined(ARCH_AMD64)
          && PATCH(https://github.com/kn007/patch/raw/master/nginx_with_quic.patch) \
          && PATCH(https://github.com/kn007/patch/raw/master/use_openssl_md5_sha1.patch) \
          && PATCH_LOCAL(/tmp/patch-nginx/nginx-spdy-quic-aware.patch) \
          && PATCH_LOCAL(/tmp/patch-nginx/nginx-plain-spdy-quic-aware.patch) \
#else
          && PATCH(https://github.com/kn007/patch/raw/master/nginx.patch) \
          && PATCH(https://github.com/kn007/patch/raw/master/use_openssl_md5_sha1.patch) \
          && PATCH_LOCAL(/tmp/patch-nginx/nginx-spdy.patch) \
          && PATCH_LOCAL(/tmp/patch-nginx/nginx-plain-spdy-aware.patch) \
#endif
       && cd /tmp \
    && git clone https://github.com/eustas/ngx_brotli.git \
       && cd /tmp/ngx_brotli && git submodule update --init && cd /tmp \
#if defined(ARCH_AMD64) || defined(ARCH_ARM64V8)
       && git clone https://github.com/cloudflare/zlib.git \
       && cd /tmp/zlib && make -f Makefile.in distclean && cd /tmp \
#endif
#if defined(ARCH_AMD64)
    && git clone https://github.com/cloudflare/quiche \
       && cd quiche \
       && git checkout ${QUICHE_VERSION} \
       && rm -rf deps/boringssl \
       && ln -sf /tmp/boringssl deps/boringssl \
       && cd /tmp \
    && git clone https://github.com/open-quantum-safe/boringssl.git \
#else
    && git clone -b OQS-OpenSSL_1_1_1-stable https://github.com/open-quantum-safe/openssl.git \
       && cd openssl \
       && PATCH(https://github.com/hakasenyang/openssl-patch/raw/master/openssl-equal-1.1.1e-dev_ciphers.patch) \
       && PATCH_LOCAL(/tmp/patch-openssl/openssl-oqs-1.1.1i-chacha_draft.patch) \
       && cd /tmp \
#endif
    && git clone -b main https://github.com/open-quantum-safe/liboqs.git \
       && mkdir /tmp/liboqs/build && cd /tmp/liboqs/build \
       && cmake -DOQS_BUILD_ONLY_LIB=1 -DBUILD_SHARED_LIBS=OFF -DOQS_USE_OPENSSL=OFF -DCMAKE_INSTALL_PREFIX=/tmp/boringssl/oqs .. \
       && make -j4 && make install && cd /tmp \
    && git clone https://github.com/vision5/ngx_devel_kit.git \
    && git clone https://github.com/openresty/array-var-nginx-module.git \
    && git clone https://github.com/openresty/echo-nginx-module.git \
    && git clone https://github.com/openresty/headers-more-nginx-module.git \
    && git clone https://github.com/openresty/set-misc-nginx-module.git \
    && git clone https://github.com/openresty/stream-echo-nginx-module.git \
       && cd /tmp/stream-echo-nginx-module \
       && PATCH_LOCAL(/tmp/stream-echo-nginx-module.patch) \
       && cd /tmp \
    && git clone https://github.com/tokers/zstd-nginx-module.git \
    && git clone https://github.com/vozlt/nginx-module-vts.git \
#if defined(ARCH_AMD64)
    && cd /tmp/boringssl \
       && mkdir -p /tmp/boringssl/build /tmp/boringssl/.openssl/lib /tmp/boringssl/.openssl/include \
       && ln -sf /tmp/boringssl/include/openssl /tmp/boringssl/.openssl/include/openssl \
       && touch /tmp/boringssl/.openssl/include/openssl/ssl.h \
       && cd build && cmake .. && make -j4 \
       && cp /tmp/boringssl/build/crypto/libcrypto.a /tmp/boringssl/build/ssl/libssl.a /tmp/boringssl/.openssl/lib \
       && cd /tmp \
#else
    && echo "Replace system OpenSSL with our own" \
    && cd /tmp/openssl \
       && ./config --prefix=/usr --openssldir=/usr \
#if defined(ARCH_ARM64V8) || defined(ARCH_X32)
          zlib no-tests enable-ec_nistp_64_gcc_128 \
#else
          zlib no-tests \
#endif
       && make -j4 && make install && cd /tmp \
#endif
    && cd /tmp/nginx \
#if defined(ARCH_I386)
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
#if defined(ARCH_AMD64)
       --with-http_v3_module \
#endif
       --with-stream \
       --with-stream_realip_module \
       --with-stream_ssl_module \
       --with-stream_ssl_preread_module \
#if defined(ARCH_AMD64) || defined(ARCH_ARM64V8)
       --with-zlib=/tmp/zlib \
#endif
       --add-module=/tmp/ngx_brotli \
       --add-module=/tmp/ngx_devel_kit \
       --add-module=/tmp/array-var-nginx-module \
       --add-module=/tmp/echo-nginx-module \
       --add-module=/tmp/headers-more-nginx-module \
       --add-module=/tmp/set-misc-nginx-module \
       --add-module=/tmp/stream-echo-nginx-module \
       --add-module=/tmp/zstd-nginx-module \
       --add-module=/tmp/nginx-module-vts \
#if defined(ARCH_AMD64)
       --with-quiche=/tmp/quiche \
       --with-openssl=/tmp/boringssl \
       --with-cc-opt="-I/tmp/boringssl/oqs/include" \
       --with-ld-opt="-L/tmp/boringssl/oqs/lib" \
#else
       --with-openssl=/tmp/openssl \
#if defined(ARCH_ARM64V8) || defined(ARCH_X32)
       --with-openssl-opt="zlib no-tests enable-ec_nistp_64_gcc_128" \
#else
       --with-openssl-opt="zlib no-tests" \
#endif
       --with-cc-opt="-I/tmp/openssl/oqs/include" \
       --with-ld-opt="-L/tmp/openssl/oqs/lib" \
#endif
    && sed -i 's/libcrypto.a/libcrypto.a -loqs/g' objs/Makefile \
#if defined(ARCH_AMD64)
    && mkdir -p /tmp/boringssl/.openssl/lib /tmp/boringssl/.openssl/include \
    && ln -sf /tmp/boringssl/include/openssl /tmp/boringssl/.openssl/include/openssl \
    && touch /tmp/boringssl/.openssl/include/openssl/ssl.h \
    && cp /tmp/boringssl/build/crypto/libcrypto.a /tmp/boringssl/build/ssl/libssl.a /tmp/boringssl/.openssl/lib \
#endif
#ifdef ARCH_I386
    && setarch i386 make -j4 \
    && setarch i386 make install \
#else
    && make -j4 \
    && make install \
#endif
    && strip /usr/local/nginx/sbin/* \
    && rm -rf $HOME/.cargo $HOME/.rustup \
    && PKG_UNINSTALL(APP_BUILD_TOOLS) \
    && cd / && FINAL_CLEANUP() \
    && ln -sf /usr/local/nginx/sbin/nginx /usr/sbin/nginx
#EXPOSE 80 443
ENTRYPOINT ["/usr/sbin/nginx"]
