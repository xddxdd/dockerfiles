FROM alpine
ENV FRP_VER=0.20.0
RUN apk add --update wget tar \
  && mkdir /frp \
  && wget --no-check-certificate https://github.com/fatedier/frp/releases/download/v${FRP_VER}/frp_${FRP_VER}_linux_amd64.tar.gz \
  && tar xf frp_${FRP_VER}_linux_amd64.tar.gz \
  && rm frp_${FRP_VER}_linux_amd64.tar.gz \
  && mv frp_${FRP_VER}_linux_amd64/frps /usr/bin/ \
  && mv frp_${FRP_VER}_linux_amd64/frpc /usr/bin/ \
  && mv frp_${FRP_VER}_linux_amd64/frps.ini /frp/ \
  && mv frp_${FRP_VER}_linux_amd64/frpc.ini /frp/ \
  && chmod +x /usr/bin/frp*
WORKDIR /frp
ENTRYPOINT ["/usr/bin/frps"]
