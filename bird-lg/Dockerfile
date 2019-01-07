ARG THIS_ARCH_ALT=amd64
FROM multiarch/alpine:${THIS_ARCH_ALT}-edge

LABEL Lan Tian "lantian@lantian.pub"
RUN apk --no-cache add build-base git whois python2 py2-dnspython py2-gv py2-pip python2-dev py2-flask \
    && pip2 install pydot grequests \
    && cd / && git clone https://github.com/xddxdd/bird-lg.git \
    && apk del --purge git build-base py2-pip python2-dev
WORKDIR /bird-lg
ENTRYPOINT ["python2", "bird-lg.py"]
