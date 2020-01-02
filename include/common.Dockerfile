#define WGET(url) wget --no-check-certificate -q url
#define PATCH(url) WGET(url) -O- | patch -p1
#define PATCH_LOCAL(path) cat path | patch -p1
#define UNTARGZ(url) WGET(url) -O download.tar.gz \
    && tar xf download.tar.gz && rm download.tar.gz
