#!/bin/sh
/usr/sbin/bird -f &
/usr/sbin/smartdns -d $@