#include "common.Dockerfile"
#include "image/multiarch_alpine_edge.Dockerfile"
#include "env.Dockerfile"

ENV FRP_VER=0.22.0
RUN apk --no-cache add wget tar \
  && mkdir /frp \
  && UNTARGZ(https://github.com/fatedier/frp/releases/download/v${FRP_VER}/frp_${FRP_VER}_linux_${THIS_ARCH_GO}.tar.gz) \
  && mv frp_${FRP_VER}_linux_${THIS_ARCH_GO}/frps /usr/bin/ \
  && mv frp_${FRP_VER}_linux_${THIS_ARCH_GO}/frps.ini /frp/ \
  && rm -rf frp_${FRP_VER}_linux_${THIS_ARCH_GO} \
  && chmod +x /usr/bin/frps \
  && apk del --purge wget tar
WORKDIR /frp
ENTRYPOINT ["/usr/bin/frps"]
