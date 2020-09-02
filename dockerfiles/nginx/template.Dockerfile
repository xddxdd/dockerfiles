#include "common.Dockerfile"
#include "image/debian_sid.Dockerfile"
#include "env.Dockerfile"

#if defined(ARCH_RISCV64)
#define APP_DEPS libpcre3 zlib1g libgd3 util-linux libzstd1
#else
#define APP_DEPS libpcre3 zlib1g libatomic-ops-dev libgd3 util-linux libzstd1
#endif

#define APP_BUILD_TOOLS binutils build-essential git autoconf automake libtool wget libgd-dev libpcre3-dev zlib1g-dev libzstd-dev libssl-dev unzip patch python3-pytest python3-pytest-xdist xsltproc doxygen graphviz cmake LINUX_HEADERS

ENV NGINX_VERSION=1.19.2
COPY patches /tmp/
RUN cd /tmp \
    && PKG_INSTALL(APP_DEPS APP_BUILD_TOOLS) \
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
      && PATCH(https://github.com/hakasenyang/openssl-patch/raw/master/nginx_strict-sni_1.15.10.patch) \
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
      && cd /tmp \
    && git clone -b master https://github.com/open-quantum-safe/liboqs.git \
      && mkdir /tmp/liboqs/build && cd /tmp/liboqs/build \
      && cmake -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX=/tmp/openssl/oqs .. \
      && make -j4 && make install && cd /tmp \
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
       --with-openssl=/tmp/openssl \
#if defined(ARCH_AMD64) || defined(ARCH_ARM64V8)
       --with-openssl-opt="zlib no-tests enable-ec_nistp_64_gcc_128" \
#else
       --with-openssl-opt="zlib no-tests" \
#endif
       --with-cc-opt="-I/tmp/openssl/oqs/include" \
       --with-ld-opt="-L/tmp/openssl/oqs/lib" \
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
