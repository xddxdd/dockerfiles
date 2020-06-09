#include "common.Dockerfile"
#include "image/debian_sid.Dockerfile"
#include "env.Dockerfile"

#if defined(ARCH_RISCV64)
#define APP_DEPS libpcre3 zlib1g libgd3 util-linux libzstd1
#else
#define APP_DEPS libpcre3 zlib1g libatomic-ops-dev libgd3 util-linux libzstd1
#endif

#if defined(ARCH_AMD64)
#define APP_BUILD_TOOLS binutils build-essential git autoconf automake libtool wget libgd-dev libpcre3-dev zlib1g-dev libzstd-dev unzip patch LINUX_HEADERS cmake rustc cargo golang-go
#else
#define APP_BUILD_TOOLS binutils build-essential git autoconf automake libtool wget libgd-dev libpcre3-dev zlib1g-dev libzstd-dev unzip patch LINUX_HEADERS
#endif

ENV NGINX_VERSION=1.19.0 OPENSSL_VERSION=1.1.1g QUICHE_VERSION=98757ca
COPY patches /tmp/
RUN cd /tmp \
    && PKG_INSTALL(APP_DEPS APP_BUILD_TOOLS) \
    && cd /tmp \
    && git clone https://github.com/cloudflare/quiche \
      && cd /tmp/quiche \
      && git checkout ${QUICHE_VERSION} \
      && PATCH_LOCAL(/tmp/quiche-tls-add-feature-to-build-against-OpenSSL.patch) \
      && cd /tmp \
    && wget -q http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
      && tar xf nginx-${NGINX_VERSION}.tar.gz \
      && cd /tmp/nginx-${NGINX_VERSION} \
#if defined(ARCH_AMD64)
      && PATCH(https://github.com/kn007/patch/raw/master/nginx_with_quic.patch) \
      && PATCH_LOCAL(/tmp/nginx-spdy-patch-quic-aware.patch) \
      && PATCH_LOCAL(/tmp/nginx-1.17.10-quiche-remove_opennssl_make_fix.patch) \
      && PATCH_LOCAL(/tmp/nginx-quiche-openssl-feature.patch) \
#else
      && PATCH(https://github.com/kn007/patch/raw/master/nginx.patch) \
      && PATCH_LOCAL(/tmp/nginx-spdy-patch.patch) \
#endif
      && PATCH(https://github.com/hakasenyang/openssl-patch/raw/master/nginx_strict-sni_1.15.10.patch) \
      && PATCH(https://github.com/kn007/patch/raw/master/use_openssl_md5_sha1.patch) \
      && PATCH(https://github.com/kn007/patch/raw/master/Enable_BoringSSL_OCSP.patch) \
      && cd /tmp \
    && git clone https://github.com/eustas/ngx_brotli.git \
      && cd /tmp/ngx_brotli && git submodule update --init && cd /tmp \
#if defined(ARCH_AMD64) || defined(ARCH_ARM64V8)
      && git clone https://github.com/cloudflare/zlib.git \
      && cd /tmp/zlib && make -f Makefile.in distclean && cd /tmp \
#endif
    && wget -q https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
      && tar xf openssl-${OPENSSL_VERSION}.tar.gz \
      && mv /tmp/openssl-${OPENSSL_VERSION} /tmp/openssl \
      && cd /tmp/openssl \
#if defined(ARCH_AMD64)
      && PATCH_LOCAL(/tmp/patch-openssl/0001-Add-support-for-BoringSSL-QUIC-APIs.patch) \
      && PATCH_LOCAL(/tmp/patch-openssl/0002-Fix-resumption-secret.patch) \
      && PATCH_LOCAL(/tmp/patch-openssl/0003-QUIC-Handle-EndOfEarlyData-and-MaxEarlyData.patch) \
      && PATCH_LOCAL(/tmp/patch-openssl/0004-QUIC-Increase-HKDF_MAXBUF-to-2048.patch) \
      && PATCH_LOCAL(/tmp/patch-openssl/0005-Fall-through-for-0RTT.patch) \
      && PATCH_LOCAL(/tmp/patch-openssl/0006-Some-cleanup-for-the-main-QUIC-changes.patch) \
      && PATCH_LOCAL(/tmp/patch-openssl/0007-Prevent-KeyUpdate-for-QUIC.patch) \
      && PATCH_LOCAL(/tmp/patch-openssl/0008-Test-KeyUpdate-rejection.patch) \
      && PATCH_LOCAL(/tmp/patch-openssl/0009-Fix-out-of-bounds-read-when-TLS-msg-is-split-up-into.patch) \
      && PATCH_LOCAL(/tmp/patch-openssl/0001-update-quice-method.patch) \
      && PATCH_LOCAL(/tmp/patch-openssl/fupdatesetread.patch) \
      && PATCH_LOCAL(/tmp/patch-openssl/openssl-1.1.1e-sess_set_get_cb_yield.patch) \
#endif
      && cd /tmp \
    && git clone https://github.com/openresty/headers-more-nginx-module.git \
    && git clone https://github.com/tokers/zstd-nginx-module.git \
    && git clone https://github.com/vozlt/nginx-module-vts.git \
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
       --add-module=/tmp/nginx-module-vts \
#if defined(ARCH_AMD64)
       --with-http_v3_module \
       --with-quiche=/tmp/quiche \
#endif
       --with-openssl=/tmp/openssl \
#if defined(ARCH_AMD64) || defined(ARCH_ARM64V8)
       --with-openssl-opt="zlib no-tests enable-ec_nistp_64_gcc_128" \
#else
       --with-openssl-opt="zlib no-tests" \
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
    && cd / && FINAL_CLEANUP() \
    && ln -sf /usr/local/nginx/sbin/nginx /usr/sbin/nginx
#EXPOSE 80 443
ENTRYPOINT ["/usr/sbin/nginx"]
