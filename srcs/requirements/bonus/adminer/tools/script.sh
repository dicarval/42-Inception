#!/bin/bash
ADM_DIR="/var/www/adminer"
INIT_MARKER="$ADM_DIR/.initialized"

if [ ! -f "$INIT_MARKER" ]; then
  mkdir -p "$ADM_DIR"
  echo "Downloading Adminer..."
  curl -sSL https://www.adminer.org/latest.php -o "$ADM_DIR/index.php"
  chmod 644 "$ADM_DIR/index.php"
  touch "$INIT_MARKER"
fi

echo "Starting Adminer on :8080"
php -S 0.0.0.0:8080 -t "$ADM_DIR" 2>/dev/null &
PHP_PID=$!

graceful_stop() {
  kill -TERM "$PHP_PID" 2>/dev/null || true
  wait "$PHP_PID" 2>/dev/null || true
  exit 0
}

trap graceful_stop SIGTERM SIGINT

# Wait for the php server process
wait "$PHP_PID"
