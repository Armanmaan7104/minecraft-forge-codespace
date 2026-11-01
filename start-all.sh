#!/usr/bin/env bash

# Kill any stale instances
pkill -f 'node.*app.js' || true
pkill -f 'socat TCP-LISTEN:8080' || true
pkill -f 'playit' || true

# Start MCSManager Daemon and Web
if [ -d "/opt/mcsmanager/mcsmanager" ]; then
    cd /opt/mcsmanager/mcsmanager/daemon && nohup node --enable-source-maps app.js > /tmp/mcsmanager-daemon.log 2>&1 &
    sleep 2
    cd /opt/mcsmanager/mcsmanager/web && nohup node --enable-source-maps app.js > /tmp/mcsmanager-web.log 2>&1 &
fi

# Start playit tunnel
nohup playit -s > /tmp/playit.log 2>&1 &

# Forward port 8080 -> MCSManager (23333)
nohup socat TCP-LISTEN:8080,fork,reuseaddr TCP:127.0.0.1:23333 > /dev/null 2>&1 &
