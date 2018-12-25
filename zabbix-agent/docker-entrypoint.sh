#!/bin/sh

if [ -z "$ZBX_SERVER_HOST" ]; then
    echo "ZBX_SERVER_HOST not defined"
    exit 1
fi

if [ -z "$ZBX_HOSTNAME" ]; then
    echo "ZBX_HOSTNAME not defined"
    exit 1
fi

mkdir -p /etc/zabbix/zabbix_agentd.d

cat <<EOF > /etc/zabbix/zabbix_agentd.conf
LogType=console
EnableRemoteCommands=1
Server=$ZBX_SERVER_HOST
ServerActive=$ZBX_SERVER_HOST
Hostname=$ZBX_HOSTNAME
AllowRoot=1
Include=/etc/zabbix/zabbix_agentd.d/
LoadModulePath=/var/lib/zabbix/modules/
EOF

cat <<EOF > /etc/mysql/my.cnf
[client]
${MYSQL_USER:+user=}${MYSQL_USER}
${MYSQL_PASSWORD:+password=}${MYSQL_PASSWORD}
EOF

zabbix_agentd -f -c /etc/zabbix/zabbix_agentd.conf
