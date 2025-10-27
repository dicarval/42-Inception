#!/bin/bash

# require docker socket
DOCKER_SOCK=/var/run/docker.sock
if [ ! -S "$DOCKER_SOCK" ]; then
  echo "Docker socket not found at $DOCKER_SOCK"
  exit 1
fi

echo "Healthchecker starting (interval=${CHECK_INTERVAL}s)"
running=true

shutdown() {
  running=false
  # try to kill background jobs started by this shell
  if [ -n "$CHECK_PID" ]; then
    kill -TERM "$CHECK_PID" 2>/dev/null || true
    wait "$CHECK_PID" 2>/dev/null || true
  fi
  # kill any background jobs (sleep etc)
  for pid in $(jobs -p); do
    kill -TERM "$pid" 2>/dev/null || true
  done
  if [ -n "$SLEEP_PID" ]; then
    kill -TERM "$SLEEP_PID" 2>/dev/null || true
  fi
  exit 0
}
trap shutdown SIGTERM SIGINT

check_once() {
  curl -s --unix-socket "$DOCKER_SOCK" http://localhost/containers/json?all=1 \
    | jq -c '.[]' \
    | while read -r c; do
        ID=$(echo "$c" | jq -r .Id)
        NAME=$(echo "$c" | jq -r .Names[0] | sed 's@^/@@')
        INFO=$(curl -s --unix-socket "$DOCKER_SOCK" "http://localhost/containers/$ID/json")
        HEALTH=$(echo "$INFO" | jq -r '.State.Health.status // empty')
        STATUS=$(echo "$INFO" | jq -r '.State.Status // "unknown"')
        PID=$(echo "$INFO" | jq -r '.State.Pid // "unknown"')
        # chosen reported status
        REP="${HEALTH:-$STATUS}"
        echo "$(date -u +"%d-%m-%Y %H:%M:%S") PID: $PID - $NAME : $REP"
      done
}

while $running; do
  sleep "$CHECK_INTERVAL" & SLEEP_PID=$!
  # wait for the sleep to finish or be killed by shutdown()
  wait "$SLEEP_PID" 2>/dev/null || true
  check_once &
  CHECK_PID=$!
done
