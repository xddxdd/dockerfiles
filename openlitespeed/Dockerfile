ARG THIS_ARCH_ALT=amd64
FROM multiarch/debian-debootstrap:${THIS_ARCH_ALT}-stretch

ARG THIS_ARCH=amd64
ARG THIS_ARCH_ALT=amd64

LABEL Lan Tian "lantian@lantian.pub"
RUN sh -c "echo \"deb http://rpms.litespeedtech.com/debian/ stretch main\" > /etc/apt/sources.list.d/lst_debian_repo.list" \
    && wget -O /etc/apt/trusted.gpg.d/lst_debian_repo.gpg http://rpms.litespeedtech.com/debian/lst_debian_repo.gpg \
    && wget -O /etc/apt/trusted.gpg.d/lst_repo.gpg http://rpms.litespeedtech.com/debian/lst_repo.gpg \
    && apt-get update \
    && apt-get install -y openlitespeed ols-pagespeed ols-modsecurity \
    && sh -c "apt-cache search lsphp | cut -f1 -d' ' | egrep -v \"(dbg|dev|source)\" | xargs apt-get install -y" \
    && ln -sf /usr/local/lsws/lsphp56/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp5 \
    && ln -sf /usr/local/lsws/lsphp73/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp7 \
    && rm -rf /var/cache/apt
ENTRYPOINT ["/usr/local/lsws/bin/openlitespeed","-d"]
