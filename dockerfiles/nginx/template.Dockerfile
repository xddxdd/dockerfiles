#include "common.Dockerfile"
#include "image/debian_sid.Dockerfile"
#include "env.Dockerfile"

#define APP_DEPS libpcre3 zlib1g libgd3 util-linux libzstd1
#define APP_BUILD_TOOLS binutils build-essential git autoconf automake libtool wget libgd-dev libpcre3-dev zlib1g-dev libzstd-dev unzip patch cmake libunwind-dev pkg-config python3 python3-psutil golang curl LINUX_HEADERS mercurial

#if !defined(ARCH_AMD64) && !defined(ARCH_ARM64V8)
#error "Only AMD64 and ARM64V8 is supported"
#endif

COPY patches /tmp/
RUN cd /tmp \
    && PKG_INSTALL(APP_DEPS APP_BUILD_TOOLS) \
    && cd /tmp \
    && hg clone -b quic https://hg.nginx.org/nginx-quic \
       && mv /tmp/nginx-quic /tmp/nginx \
       && cd /tmp/nginx \
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
    && git clone https://github.com/vozlt/nginx-module-sts.git \
    && git clone https://github.com/vozlt/nginx-module-stream-sts.git \
    && cd /tmp/boringssl \
       && mkdir -p /tmp/boringssl/build /tmp/boringssl/.openssl/lib /tmp/boringssl/.openssl/include \
       && ln -sf /tmp/boringssl/include/openssl /tmp/boringssl/.openssl/include/openssl \
       && touch /tmp/boringssl/.openssl/include/openssl/ssl.h \
       && cmake . && make -j4 \
       && cp /tmp/boringssl/crypto/libcrypto.a /tmp/boringssl/ssl/libssl.a /tmp/boringssl/.openssl/lib \
       && cd /tmp \
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
       --add-module=/tmp/ngx_devel_kit \
       --add-module=/tmp/array-var-nginx-module \
       --add-module=/tmp/echo-nginx-module \
       --add-module=/tmp/headers-more-nginx-module \
       --add-module=/tmp/set-misc-nginx-module \
       --add-module=/tmp/stream-echo-nginx-module \
       --add-module=/tmp/zstd-nginx-module \
       --add-module=/tmp/nginx-module-vts \
       --add-module=/tmp/nginx-module-sts \
       --add-module=/tmp/nginx-module-stream-sts \
       --with-openssl=/tmp/boringssl \
       --with-cc-opt="-I/tmp/boringssl/include -I/tmp/boringssl/oqs/include" \
       --with-ld-opt="-L/tmp/boringssl/build/ssl -L/tmp/boringssl/build/crypto -L/tmp/boringssl/oqs/lib" \
    && sed -i 's/libcrypto.a/libcrypto.a -loqs/g' objs/Makefile \
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
    && strip /usr/local/nginx/sbin/* \
    && PKG_UNINSTALL(APP_BUILD_TOOLS) \
    && cd / && FINAL_CLEANUP() \
    && ln -sf /usr/local/nginx/sbin/nginx /usr/sbin/nginx

ENTRYPOINT ["/usr/sbin/nginx"]
