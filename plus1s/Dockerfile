ARG THIS_ARCH_ALT=amd64
FROM multiarch/alpine:${THIS_ARCH_ALT}-edge

LABEL Lan Tian "lantian@lantian.pub"
RUN apk --no-cache add git python \
    && git clone https://github.com/HFO4/plus1s.live.git \
    && apk del --purge git

WORKDIR /plus1s.live/
ENTRYPOINT ["python", "stream.py"]
