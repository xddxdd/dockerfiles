#!/bin/sh
cd /
# Initialize git repository
if [ ! -e /registry/.git ]; then
    git clone git@git.dn42.dev:dn42/registry.git
fi
# Start whois42d in background
/whois42d -registry /registry &
cd /registry
while true; do
    for i in $(seq 1 600); do
        # Check if whois42d is still running
        ps | grep whois42d >/dev/null 2>/dev/null
        [ $? -eq 0 ] || exit $?
        sleep 6
    done
    # Update git repository every hour
    git pull
done
