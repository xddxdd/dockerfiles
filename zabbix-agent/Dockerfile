ARG THIS_ARCH_ALT=amd64
FROM multiarch/alpine:${THIS_ARCH_ALT}-edge

LABEL Lan Tian "lantian@lantian.pub"
RUN apk --no-cache add zabbix-agent mariadb-client wget curl \
    && mkdir -p /etc/zabbix/zabbix_agentd.d
COPY docker-entrypoint.sh /
COPY userparameter_mysql.conf /etc/zabbix/zabbix_agentd.d/

EXPOSE 10050

ENTRYPOINT ["/docker-entrypoint.sh"]
