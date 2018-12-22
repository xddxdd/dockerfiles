ARG THIS_ARCH_ALT=amd64
FROM multiarch/alpine:${THIS_ARCH_ALT}-edge

LABEL Lan Tian "lantian@lantian.pub"
RUN apk --no-cache add dnsmasq
ENTRYPOINT ["/usr/sbin/dnsmasq", "-d"]
