#include "common.Dockerfile"
#include "image/alpine_edge.Dockerfile"
#include "env.Dockerfile"

RUN PKG_INSTALL(zabbix-agent mariadb-client wget curl) \
    && mkdir -p /etc/zabbix/zabbix_agentd.d
COPY docker-entrypoint.sh /
COPY userparameter_mysql.conf /etc/zabbix/zabbix_agentd.d/

EXPOSE 10050

ENTRYPOINT ["/docker-entrypoint.sh"]
