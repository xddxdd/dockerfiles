ARG THIS_ARCH_ALT=amd64
FROM multiarch/alpine:${THIS_ARCH_ALT}-edge

LABEL Lan Tian "lantian@lantian.pub"
RUN apk --no-cache add build-base git whois python2 py2-dnspython py2-gv py2-pip python2-dev py2-flask py2-werkzeug \
        uwsgi uwsgi-python uwsgi-gevent font-bitstream-type1 \
    && pip2 install --upgrade pydot grequests flask \
    && cd / && git clone https://github.com/xddxdd/bird-lg.git \
    && apk del --purge git build-base py2-pip python2-dev \
    && touch /var/log/lg.log && chmod 777 /var/log/lg.log \
    && chmod 777 /run
WORKDIR /bird-lg
ENTRYPOINT ["sh", "-c", "chmod 777 /run && uwsgi --socket /run/bird-lg.sock --plugins python,gevent --wsgi-file lg.py --callable app --threads 4 --thunder-lock --uid 33 --master --buffer-size 32768 --gevent 40 --gevent-monkey-patch"]
