#!/bin/sh

echo "Starting Redis..."

exec redis-server --protected-mode no > /dev/null 2>&1
