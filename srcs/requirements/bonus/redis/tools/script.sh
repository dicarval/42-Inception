#!/bin/bash

echo "Starting Redis..."

mkdir -p /data
chown -R redis:redis /data 2>/dev/null

exec redis-server \
  --protected-mode no \
  --bind 0.0.0.0 \
  --dir /data \
  --dbfilename dump.rdb \
  --appendonly yes \
  --appendfilename appendonly.aof > /dev/null 2>&1
