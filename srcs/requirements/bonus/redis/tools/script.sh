#!/bin/bash

echo "Starting Redis..."

exec redis-server --protected-mode no --bind 0.0.0.0 > /dev/null 2>&1
