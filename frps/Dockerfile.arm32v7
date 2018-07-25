FROM multiarch/alpine:armhf-edge
ENV FRP_VER=0.20.0
RUN apk --no-cache add wget tar \
  && mkdir /frp \
  && wget --no-check-certificate https://github.com/fatedier/frp/releases/download/v${FRP_VER}/frp_${FRP_VER}_linux_arm.tar.gz \
  && tar xf frp_${FRP_VER}_linux_arm.tar.gz \
  && rm frp_${FRP_VER}_linux_arm.tar.gz \
  && mv frp_${FRP_VER}_linux_arm/frps /usr/bin/ \
  && mv frp_${FRP_VER}_linux_arm/frps.ini /frp/ \
  && rm -rf frp_${FRP_VER}_linux_arm \
  && chmod +x /usr/bin/frps \
  && apk del --purge wget tar
WORKDIR /frp
ENTRYPOINT ["/usr/bin/frps"]
