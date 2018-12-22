ARG THIS_ARCH_ALT=amd64
FROM multiarch/alpine:${THIS_ARCH_ALT}-edge

LABEL Lan Tian "lantian@lantian.pub"
COPY route.sh /
RUN chmod +x /route.sh
ENTRYPOINT ["/route.sh"]
