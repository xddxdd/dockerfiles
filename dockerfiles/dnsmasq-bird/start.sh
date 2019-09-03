#!/bin/sh
/usr/sbin/bird -f &
/usr/sbin/dnsmasq -d $@