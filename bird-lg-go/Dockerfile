ARG THIS_ARCH_ALT=amd64
FROM multiarch/alpine:${THIS_ARCH_ALT}-edge
ARG THIS_ARCH_GO=amd64

LABEL Lan Tian "lantian@lantian.pub"
ENV GOOS=linux GOARCH=${THIS_ARCH_GO}
RUN apk -q --no-cache add git go build-base upx \
  && cd /root \
  && git clone https://github.com/xddxdd/bird-lg-go.git \
  && cd /root/bird-lg-go/frontend && make \
  && mv frontend / && cd / && rm -rf /root/bird-lg-go \
  && apk del go build-base upx

ENTRYPOINT ["/frontend"]
