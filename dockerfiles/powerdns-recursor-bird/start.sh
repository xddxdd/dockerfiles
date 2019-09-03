#!/bin/sh
/usr/sbin/bird -f &
/usr/sbin/pdns_recursor $@