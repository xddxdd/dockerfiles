#include "common.Dockerfile"
#include "image/alpine_edge.Dockerfile"
#include "env.Dockerfile"

#if !defined(ARCH_I386) && !defined(ARCH_AMD64) && !defined(ARCH_ARM32V7) && !defined(ARCH_ARM64V8)
#error "FRP only supports i386 or amd64"
#endif

ENV FRP_VER=0.28.2
RUN PKG_INSTALL(wget tar) \
  && mkdir /frp \
  && UNTARGZ(https://github.com/fatedier/frp/releases/download/v${FRP_VER}/frp_${FRP_VER}_linux_${THIS_ARCH_GO}.tar.gz) \
  && mv frp_${FRP_VER}_linux_${THIS_ARCH_GO}/frpc /usr/bin/ \
  && mv frp_${FRP_VER}_linux_${THIS_ARCH_GO}/frpc.ini /frp/ \
  && rm -rf frp_${FRP_VER}_linux_${THIS_ARCH_GO} \
  && chmod +x /usr/bin/frpc \
  && PKG_UNINSTALL(wget tar)
WORKDIR /frp
ENTRYPOINT ["/usr/bin/frpc"]
