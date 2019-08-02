#include "image/multiarch_alpine_edge.Dockerfile"
#include "env.Dockerfile"

RUN apk --no-cache add zabbix-agent mariadb-client wget curl \
    && mkdir -p /etc/zabbix/zabbix_agentd.d
COPY docker-entrypoint.sh /
COPY userparameter_mysql.conf /etc/zabbix/zabbix_agentd.d/

EXPOSE 10050

ENTRYPOINT ["/docker-entrypoint.sh"]
