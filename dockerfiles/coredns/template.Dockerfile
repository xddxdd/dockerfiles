#include "common.Dockerfile"
#include "image/golang.Dockerfile"

COPY patches /patches
ENV VERSION=1.8.3
RUN cd / \
    && PKG_INSTALL(patch) \
    && git clone https://github.com/coredns/coredns \
    && cd coredns \
       && git checkout ${VERSION} \
       && patch -p1 < /patches/large-axfr.patch \
    && echo "alias:github.com/serverwentdown/alias" >> plugin.cfg \
       && go get github.com/serverwentdown/alias \
    && echo "alternate:github.com/coredns/alternate" >> plugin.cfg \
       && go get github.com/coredns/alternate \
    && make

#include "image/scratch.Dockerfile"
COPY --from=step_0 /coredns/coredns /

ENTRYPOINT ["/coredns"]
