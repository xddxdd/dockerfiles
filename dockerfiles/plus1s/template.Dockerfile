#include "image/multiarch_alpine_edge.Dockerfile"
#include "env.Dockerfile"

RUN apk --no-cache add git python \
    && git clone https://github.com/HFO4/plus1s.live.git \
    && apk del --purge git

WORKDIR /plus1s.live/
ENTRYPOINT ["python", "stream.py"]
