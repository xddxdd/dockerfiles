ARG THIS_ARCH_ALT=amd64 THIS_ARCH_GO=amd64
FROM multiarch/alpine:${THIS_ARCH_ALT}-edge

LABEL Lan Tian "lantian@lantian.pub"
ENV FRP_VER=0.22.0
RUN apk --no-cache add wget tar \
  && mkdir /frp \
  && wget --no-check-certificate https://github.com/fatedier/frp/releases/download/v${FRP_VER}/frp_${FRP_VER}_linux_${THIS_ARCH_GO}.tar.gz \
  && tar xf frp_${FRP_VER}_linux_${THIS_ARCH_GO}.tar.gz \
  && rm frp_${FRP_VER}_linux_${THIS_ARCH_GO}.tar.gz \
  && mv frp_${FRP_VER}_linux_${THIS_ARCH_GO}/frpc /usr/bin/ \
  && mv frp_${FRP_VER}_linux_${THIS_ARCH_GO}/frpc.ini /frp/ \
  && rm -rf frp_${FRP_VER}_linux_${THIS_ARCH_GO} \
  && chmod +x /usr/bin/frpc \
  && apk del --purge wget tar
WORKDIR /frp
ENTRYPOINT ["/usr/bin/frpc"]
