FROM golang:alpine AS build
ARG THIS_ARCH_GO=amd64
ENV GOOS=linux GOARCH=${THIS_ARCH_GO}
COPY . /root/
RUN cd /root \
  && apk -q --no-cache add build-base upx \
  && make

ARG THIS_ARCH_ALT=amd64
FROM multiarch/alpine:${THIS_ARCH_ALT}-edge
LABEL Lan Tian "lantian@lantian.pub"
COPY --from=build /root/bird-lgproxy-go /
ENTRYPOINT ["/bird-lgproxy-go"]
