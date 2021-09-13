#include "common.Dockerfile"
#include "image/debian_sid.Dockerfile"
#include "env.Dockerfile"

#define APP_DEPS libpcre3 zlib1g libgd3 util-linux libzstd1
#define APP_BUILD_TOOLS binutils build-essential git autoconf automake libtool wget libgd-dev libpcre3-dev zlib1g-dev libzstd-dev unzip patch cmake libunwind-dev pkg-config python3 python3-psutil golang curl LINUX_HEADERS mercurial

#if !defined(ARCH_AMD64) && !defined(ARCH_ARM64V8)
#error "Only AMD64 and ARM64V8 is supported"
#endif

ENV OPENRESTY_VERSION=1.19.9.1 OPENRESTY_NGINX_VERSION=1.19.9
COPY patches /tmp/
RUN cd /tmp \
    && PKG_INSTALL(APP_DEPS APP_BUILD_TOOLS) \
    && cd /tmp \
    && hg clone -b quic https://hg.nginx.org/nginx-quic \
    && wget -q https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz \
       && tar xf openresty-${OPENRESTY_VERSION}.tar.gz \
       && cd /tmp/openresty-${OPENRESTY_VERSION}/bundle/ \
          && rm -rf nginx-${OPENRESTY_NGINX_VERSION} \
          && mv /tmp/nginx-quic nginx-${OPENRESTY_NGINX_VERSION} \
       && cd /tmp/openresty-${OPENRESTY_VERSION}/bundle/nginx-${OPENRESTY_NGINX_VERSION} \
          && PATCH(https://github.com/kn007/patch/raw/master/use_openssl_md5_sha1.patch) \
          && PATCH(https://github.com/kn007/patch/raw/master/Enable_BoringSSL_OCSP.patch) \
          && PATCH_LOCAL(/tmp/patch-nginx/nginx-hpack-dyntls.patch) \
          && PATCH_LOCAL(/tmp/patch-nginx/nginx-quic-disable-check.patch) \
          && PATCH_LOCAL(/tmp/patch-nginx/nginx-plain-quic-aware.patch) \
          && PATCH_LOCAL(/tmp/patch-nginx/nginx-plain-proxy.patch) \
          && ln -sf auto/configure ./configure \
       && cd /tmp \
    && git clone https://github.com/google/ngx_brotli.git \
       && cd /tmp/ngx_brotli && git submodule update --init && cd /tmp \
    && git clone https://github.com/cloudflare/zlib.git \
       && cd /tmp/zlib && make -f Makefile.in distclean && cd /tmp \
    && git clone https://github.com/open-quantum-safe/boringssl.git \
    && git clone -b main https://github.com/open-quantum-safe/liboqs.git \
       && mkdir /tmp/liboqs/build && cd /tmp/liboqs/build \
       && cmake .. \
          -DOQS_BUILD_ONLY_LIB=1 \
          -DBUILD_SHARED_LIBS=OFF \
          -DOQS_USE_OPENSSL=OFF \
          -DOQS_DIST_BUILD=ON \
          -DCMAKE_INSTALL_PREFIX=/tmp/boringssl/oqs \
       && make install -j4 && cd /tmp \
    && git clone https://github.com/openresty/stream-echo-nginx-module.git \
       && cd /tmp/stream-echo-nginx-module \
       && PATCH_LOCAL(/tmp/stream-echo-nginx-module.patch) \
       && cd /tmp \
    && git clone https://github.com/tokers/zstd-nginx-module.git \
    && git clone https://github.com/vozlt/nginx-module-vts.git \
    && git clone https://github.com/vozlt/nginx-module-sts.git \
    && git clone https://github.com/vozlt/nginx-module-stream-sts.git \
    && cd /tmp/boringssl \
       && mkdir -p /tmp/boringssl/build /tmp/boringssl/.openssl/lib /tmp/boringssl/.openssl/include \
       && ln -sf /tmp/boringssl/include/openssl /tmp/boringssl/.openssl/include/openssl \
       && touch /tmp/boringssl/.openssl/include/openssl/ssl.h \
       && cmake . && make -j4 \
       && cp /tmp/boringssl/crypto/libcrypto.a /tmp/boringssl/ssl/libssl.a /tmp/boringssl/.openssl/lib \
       && cd /tmp \
    && cd /tmp/openresty-${OPENRESTY_VERSION} \
#ifdef ARCH_I386
    && setarch i386 ./configure \
#else
    && ./configure \
#endif
       --with-threads \
       --with-file-aio \
       --with-pcre-jit \
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
       --with-http_v3_module \
       --with-http_quic_module \
       --with-stream \
       --with-stream_realip_module \
       --with-stream_ssl_module \
       --with-stream_ssl_preread_module \
       --with-stream_quic_module \
       --with-zlib=/tmp/zlib \
       --add-module=/tmp/ngx_brotli \
       --add-module=/tmp/stream-echo-nginx-module \
       --add-module=/tmp/zstd-nginx-module \
       --add-module=/tmp/nginx-module-vts \
       --add-module=/tmp/nginx-module-sts \
       --add-module=/tmp/nginx-module-stream-sts \
       --with-openssl=/tmp/boringssl \
       --with-cc-opt="-I/tmp/boringssl/include -I/tmp/boringssl/oqs/include" \
       --with-ld-opt="-L/tmp/boringssl/build/ssl -L/tmp/boringssl/build/crypto -L/tmp/boringssl/oqs/lib" \
       --without-http_encrypted_session_module `# Conflict with quic stuff`\
    && sed -i 's/libcrypto.a/libcrypto.a -loqs/g' build/nginx-${OPENRESTY_NGINX_VERSION}/objs/Makefile \
    && mkdir -p /tmp/boringssl/.openssl/lib /tmp/boringssl/.openssl/include \
    && ln -sf /tmp/boringssl/include/openssl /tmp/boringssl/.openssl/include/openssl \
    && touch /tmp/boringssl/.openssl/include/openssl/ssl.h \
    && cp /tmp/boringssl/crypto/libcrypto.a /tmp/boringssl/ssl/libssl.a /tmp/boringssl/.openssl/lib \
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

ENTRYPOINT ["/usr/sbin/nginx"]
