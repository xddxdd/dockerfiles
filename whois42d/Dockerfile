ARG THIS_ARCH_ALT=amd64
FROM multiarch/alpine:${THIS_ARCH_ALT}-edge

LABEL Lan Tian "lantian@lantian.pub"
RUN apk --no-cache add go git musl-dev \
    && go get github.com/Mic92/whois42d \
    && cp /root/go/bin/whois42d /whois42d \
    && rm -rf /root/go \
    && apk --no-cache del go musl-dev
COPY run.sh /
RUN chmod +x /run.sh
ENTRYPOINT ["/run.sh"]
