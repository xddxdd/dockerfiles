#include "common.Dockerfile"
#include "image/golang.Dockerfile"

RUN cd / \
    && go get -d github.com/Mic92/whois42d \
    && CGO_ENABLED=0 go build -ldflags="-s -w" github.com/Mic92/whois42d

#include "image/scratch.Dockerfile"
COPY --from=step_0 /whois42d /

ENTRYPOINT ["/whois42d", "-registry", "/registry"]
