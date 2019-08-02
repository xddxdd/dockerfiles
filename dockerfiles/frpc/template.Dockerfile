#include "common.Dockerfile"
#include "image/multiarch_alpine_edge.Dockerfile"
#include "env.Dockerfile"

ENV FRP_VER=0.22.0
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
