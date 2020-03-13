#!/bin/sh
echo Target IP is $TARGET_IP
THIS_IP=$(ip addr show dev eth0 | grep inet | cut -d' ' -f6 | cut -d'/' -f1)
echo My IP is $THIS_IP
NEXT_IP=$(echo $THIS_IP | awk -F. '{print $1 "." $2 "." $3 "." $4 + 1}')
if [ $THIS_IP == $NEXT_IP ]; then
    echo I\'m the target, listening
else
    echo Routing $TARGET_IP to $NEXT_IP
    ip route add $TARGET_IP/32 via $NEXT_IP
fi
sleep infinity