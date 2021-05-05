#include "common.Dockerfile"
#include "image/golang.Dockerfile"

COPY patches /patches
RUN cd / \
    && PKG_INSTALL(patch) \
    && git clone https://github.com/coredns/coredns \
    && cd coredns \
       && patch -p1 < /patches/large-axfr.patch \
    && echo "alias:github.com/serverwentdown/alias" >> plugin.cfg \
       && go get github.com/serverwentdown/alias \
    && make

#include "image/scratch.Dockerfile"
COPY --from=step_0 /coredns/coredns /

ENTRYPOINT ["/coredns"]
