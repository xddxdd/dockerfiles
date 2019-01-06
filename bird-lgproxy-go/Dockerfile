ARG THIS_ARCH_ALT=amd64
FROM multiarch/alpine:${THIS_ARCH_ALT}-edge
ARG THIS_ARCH_GO=amd64

LABEL Lan Tian "lantian@lantian.pub"
ENV GOOS=linux GOARCH=${THIS_ARCH_GO}
COPY . /root/bird-lgproxy-go
RUN apk -q --no-cache add go build-base upx \
  && cd /root/bird-lgproxy-go && make \
  && mv bird-lgproxy-go / && cd / && rm -rf /root/bird-lgproxy-go \
  && apk del go build-base upx

ENTRYPOINT ["/bird-lgproxy-go"]
