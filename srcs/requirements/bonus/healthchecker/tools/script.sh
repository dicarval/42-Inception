#!/bin/bash

# require docker socket
DOCKER_SOCK=/var/run/docker.sock
if [ ! -S "$DOCKER_SOCK" ]; then
  echo "Docker socket not found at $DOCKER_SOCK"
  exit 1
fi

echo "Healthchecker starting (interval=${CHECK_INTERVAL}s)"
running=true
sleep "$CHECK_INTERVAL"

check_once() {
  curl -s --unix-socket "$DOCKER_SOCK" http://localhost/containers/json?all=1 \
    | jq -c '.[]' \
    | while read -r c; do
        ID=$(echo "$c" | jq -r .Id)
        NAME=$(echo "$c" | jq -r .Names[0] | sed 's@^/@@')
        INFO=$(curl -s --unix-socket "$DOCKER_SOCK" "http://localhost/containers/$ID/json")
        HEALTH=$(echo "$INFO" | jq -r '.State.Health.status // empty')
        STATUS=$(echo "$INFO" | jq -r '.State.Status // "unknown"')
        # choose reported status
        REP="${HEALTH:-$STATUS}"
        echo "$(date -u +"%d-%m-%Y %H:%M:%S") $NAME : $REP"
      done
}

shutdown() {
  running=false
  # try to kill background jobs started by this shell
  for pid in $(jobs -p); do
    kill "$pid" 2>/dev/null
  done
  # fallback: kill the whole process group of this shell
  kill -TERM -- -$$ 2>/dev/null
  exit 0
}
trap shutdown SIGTERM SIGINT

while $running; do
  check_once
  sleep "$CHECK_INTERVAL" &
  wait $!
done
