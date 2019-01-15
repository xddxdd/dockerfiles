ARG THIS_ARCH_ALT=amd64
FROM multiarch/alpine:${THIS_ARCH_ALT}-edge

LABEL Lan Tian "lantian@lantian.pub"
RUN apk --no-cache add build-base git whois python2 py2-dnspython py2-gv py2-pip python2-dev py2-flask py2-werkzeug uwsgi uwsgi-python \
    && pip2 install --upgrade pydot grequests flask \
    && cd / && git clone https://github.com/xddxdd/bird-lg.git \
    && apk del --purge git build-base py2-pip python2-dev \
    && touch /var/log/lg.log && chmod 777 /var/log/lg.log \
    && chmod 777 /run
WORKDIR /bird-lg
ENTRYPOINT ["uwsgi", "--socket", "/var/run/bird-lg.sock", "--plugin", "python", "--wsgi-file", "lg.py", "--callable", "app", "--threads", "4", "--thunder-lock", "--uid", "nobody", "--master"]
