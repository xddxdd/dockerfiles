#include "common.Dockerfile"
#include "image/alpine_edge.Dockerfile"
#include "env.Dockerfile"

RUN PKG_INSTALL(git python) \
    && git clone https://github.com/HFO4/plus1s.live.git \
    && PKG_UNINSTALL(git)

WORKDIR /plus1s.live/
ENTRYPOINT ["python", "stream.py"]
