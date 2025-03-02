#!/bin/sh
dig +time=1 +tries=1 @127.0.0.1 || exit 1