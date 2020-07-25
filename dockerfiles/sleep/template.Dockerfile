#include "common.Dockerfile"
#include "image/debian_sid.Dockerfile"
#include "env.Dockerfile"

WORKDIR /
RUN PKG_INSTALL(build-essential)
COPY sleep.${THIS_ARCH}.s /sleep.s
RUN as sleep.s -o sleep.obj && ld -s sleep.obj -o sleep

FROM scratch
COPY --from=step_0 /sleep /
ENTRYPOINT [ "/sleep" ]
