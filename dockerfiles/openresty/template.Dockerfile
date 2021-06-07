#include "common.Dockerfile"
#include "image/debian_sid.Dockerfile"
#include "env.Dockerfile"

#define APP_DEPS libpcre3 zlib1g libgd3 util-linux libzstd1
#define APP_BUILD_TOOLS binutils build-essential git autoconf automake libtool wget libgd-dev libpcre3-dev zlib1g-dev libzstd-dev unzip patch cmake libunwind-dev pkg-config python3 python3-psutil golang curl LINUX_HEADERS

ENV OPENRESTY_VERSION=1.19.3.2 OPENRESTY_NGINX_VERSION=1.19.3 NGINX_VERSION=1.21.0 QUICHE_VERSION=cf2a087
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
          && PATCH_LOCAL(/tmp/patch-nginx/nginx-plain-quic-aware.patch) \
#else
          && PATCH(https://github.com/kn007/patch/raw/master/nginx.patch) \
          && PATCH(https://github.com/kn007/patch/raw/master/use_openssl_md5_sha1.patch) \
          && PATCH_LOCAL(/tmp/patch-nginx/nginx-plain-quic-aware.patch) \
#endif
       && cd /tmp \
    && wget -q https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz \
       && tar xf openresty-${OPENRESTY_VERSION}.tar.gz \
       && rm -rf /tmp/openresty-${OPENRESTY_VERSION}/bundle/nginx-${OPENRESTY_NGINX_VERSION} \
       && mv /tmp/nginx /tmp/openresty-${OPENRESTY_VERSION}/bundle/nginx-${OPENRESTY_NGINX_VERSION} \
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
       && git submodule update --init --recursive \
       && cd /tmp/quiche/deps/boringssl \
          && PATCH_LOCAL(/tmp/patch-openssl/boringssl-oqs.patch) \
       && cd /tmp \
#else
    && git clone -b OQS-OpenSSL_1_1_1-stable https://github.com/open-quantum-safe/openssl.git \
       && cd openssl \
       && PATCH(https://github.com/hakasenyang/openssl-patch/raw/master/openssl-equal-1.1.1e-dev_ciphers.patch) \
       && PATCH_LOCAL(/tmp/patch-openssl/openssl-oqs-1.1.1i-chacha_draft.patch) \
       && cd /tmp \
#endif
    && git clone -b main https://github.com/open-quantum-safe/liboqs.git \
       && mkdir /tmp/liboqs/build && cd /tmp/liboqs/build \
       && cmake .. \
          -DOQS_BUILD_ONLY_LIB=1 \
          -DBUILD_SHARED_LIBS=OFF \
          -DOQS_USE_OPENSSL=OFF \
          -DOQS_DIST_BUILD=ON \
#if defined(ARCH_AMD64)
          -DCMAKE_INSTALL_PREFIX=/tmp/quiche/deps/boringssl/oqs \
#else
          -DCMAKE_INSTALL_PREFIX=/tmp/openssl/oqs \
#endif
       && make -j4 && make install && cd /tmp \
    && git clone https://github.com/openresty/stream-echo-nginx-module.git \
       && cd /tmp/stream-echo-nginx-module \
       && PATCH_LOCAL(/tmp/stream-echo-nginx-module.patch) \
       && cd /tmp \
    && git clone https://github.com/tokers/zstd-nginx-module.git \
    && git clone https://github.com/vozlt/nginx-module-vts.git \
    && git clone https://github.com/vozlt/nginx-module-sts.git \
    && git clone https://github.com/vozlt/nginx-module-stream-sts.git \
#if defined(ARCH_AMD64)
    && cd /tmp/quiche/deps/boringssl \
       && mkdir -p /tmp/quiche/deps/boringssl/build /tmp/quiche/deps/boringssl/.openssl/lib /tmp/quiche/deps/boringssl/.openssl/include \
       && ln -sf /tmp/quiche/deps/boringssl/src/include/openssl /tmp/quiche/deps/boringssl/.openssl/include/openssl \
       && touch /tmp/quiche/deps/boringssl/.openssl/include/openssl/ssl.h \
       && cd build && cmake .. && make -j4 \
       && cp /tmp/quiche/deps/boringssl/build/libcrypto.a /tmp/quiche/deps/boringssl/build/libssl.a /tmp/quiche/deps/boringssl/.openssl/lib \
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
       --add-module=/tmp/stream-echo-nginx-module \
       --add-module=/tmp/zstd-nginx-module \
       --add-module=/tmp/nginx-module-vts \
       --add-module=/tmp/nginx-module-sts \
       --add-module=/tmp/nginx-module-stream-sts \
#if defined(ARCH_AMD64)
       --with-quiche=/tmp/quiche \
       --with-openssl=/tmp/quiche/deps/boringssl \
       --with-cc-opt="-I/tmp/quiche/deps/boringssl/oqs/include" \
       --with-ld-opt="-L/tmp/quiche/deps/boringssl/oqs/lib" \
       --without-http_encrypted_session_module `# Conflict with quiche stuff`\
#elif defined(ARCH_ARM64V8) || defined(ARCH_X32)
       --with-openssl=/tmp/openssl \
       --with-openssl-opt="zlib no-tests enable-ec_nistp_64_gcc_128" \
#else
       --with-openssl=/tmp/openssl \
       --with-openssl-opt="zlib no-tests" \
#endif
    && sed -i 's/libcrypto.a/libcrypto.a -loqs/g' build/nginx-${OPENRESTY_NGINX_VERSION}/objs/Makefile \
#if defined(ARCH_AMD64)
    && mkdir -p /tmp/quiche/deps/boringssl/.openssl/lib /tmp/quiche/deps/boringssl/.openssl/include \
    && ln -sf /tmp/quiche/deps/boringssl/src/include/openssl /tmp/quiche/deps/boringssl/.openssl/include/openssl \
    && touch /tmp/quiche/deps/boringssl/.openssl/include/openssl/ssl.h \
    && cp /tmp/quiche/deps/boringssl/build/libcrypto.a /tmp/quiche/deps/boringssl/build/libssl.a /tmp/quiche/deps/boringssl/.openssl/lib \
#endif
#ifdef ARCH_I386
    && setarch i386 make -j4 \
    && setarch i386 make install \
#else
    && make -j4 \
    && make install \
#endif
    && strip /usr/local/openresty/nginx/sbin/* \
    && rm -rf $HOME/.cargo $HOME/.rustup \
    && PKG_UNINSTALL(APP_BUILD_TOOLS) \
    && cd / && FINAL_CLEANUP() \
    && ln -sf /usr/local/openresty/nginx/sbin/nginx /usr/sbin/nginx \
    && ln -sf /usr/local/openresty/nginx/sbin/nginx /usr/sbin/openresty
#EXPOSE 80 443
ENTRYPOINT ["/usr/sbin/nginx"]
