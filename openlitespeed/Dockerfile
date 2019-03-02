ARG THIS_ARCH_ALT=amd64
FROM multiarch/debian-debootstrap:${THIS_ARCH_ALT}-stretch

ARG THIS_ARCH=amd64
ARG THIS_ARCH_ALT=amd64

LABEL Lan Tian "lantian@lantian.pub"
RUN sh -c "echo \"deb http://rpms.litespeedtech.com/debian/ jessie main\" > /etc/apt/sources.list.d/lst_debian_repo.list" \
    && sh -c "echo \"deb http://rpms.litespeedtech.com/debian/ stretch main\" >> /etc/apt/sources.list.d/lst_debian_repo.list" \
    && wget -O /etc/apt/trusted.gpg.d/lst_debian_repo.gpg http://rpms.litespeedtech.com/debian/lst_debian_repo.gpg \
    && wget -O /etc/apt/trusted.gpg.d/lst_repo.gpg http://rpms.litespeedtech.com/debian/lst_repo.gpg \
    && apt-get update \
    && cd /tmp \
      && wget http://ftp.debian.org/debian/pool/main/libo/libonig/libonig2_5.9.5-3.2+deb8u1_${THIS_ARCH_ALT}.deb \
      && dpkg -i libonig2_5.9.5-3.2+deb8u1_${THIS_ARCH_ALT}.deb \
      && rm libonig2_5.9.5-3.2+deb8u1_${THIS_ARCH_ALT}.deb \
      && cd / \
    && apt-get install -y supervisor openlitespeed ols-pagespeed ols-modsecurity \
    && sh -c "apt-cache search lsphp | cut -f1 -d' ' | egrep -v \"(dbg|dev|source)\" | xargs apt-get install -y" \
    && ln -sf /usr/local/lsws/lsphp53/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp53 \
    && ln -sf /usr/local/lsws/lsphp54/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp54 \
    && ln -sf /usr/local/lsws/lsphp55/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp55 \
    && ln -sf /usr/local/lsws/lsphp56/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp56 \
    && ln -sf /usr/local/lsws/lsphp70/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp70 \
    && ln -sf /usr/local/lsws/lsphp71/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp71 \
    && ln -sf /usr/local/lsws/lsphp72/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp72 \
    && ln -sf /usr/local/lsws/lsphp73/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp73 \
    && ln -sf /usr/local/lsws/lsphp73/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp \
    && rm -rf /var/cache/apt
COPY openlitespeed.conf /etc/supervisor/conf.d/openlitespeed.conf
ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
