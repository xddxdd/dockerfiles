FROM multiarch/alpine:i386-edge
ENV FRP_VER=0.20.0
RUN apk --no-cache add wget tar \
  && mkdir /frp \
  && wget --no-check-certificate https://github.com/fatedier/frp/releases/download/v${FRP_VER}/frp_${FRP_VER}_linux_arm64.tar.gz \
  && tar xf frp_${FRP_VER}_linux_arm64.tar.gz \
  && rm frp_${FRP_VER}_linux_arm64.tar.gz \
  && mv frp_${FRP_VER}_linux_arm64/frpc /usr/bin/ \
  && mv frp_${FRP_VER}_linux_arm64/frpc.ini /frp/ \
  && rm -rf frp_${FRP_VER}_linux_arm64 \
  && chmod +x /usr/bin/frpc \
  && apk del --purge wget tar
WORKDIR /frp
ENTRYPOINT ["/usr/bin/frpc"]
