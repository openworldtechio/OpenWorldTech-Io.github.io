#!/bin/bash

# Ensure script always runs from the project root directory
cd "$(dirname "$0")/.." || exit 1

# Configuration
LOG_DIR="scripts/logs"
LOG_FILE="$LOG_DIR/jekyll.log"
PID_FILE="$LOG_DIR/jekyll.pid"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

start() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "Jekyll is already running (PID: $(cat "$PID_FILE"))."
    else
        echo "Starting local Jekyll server..."
        arch -x86_64 bundle exec jekyll serve --livereload > "$LOG_FILE" 2>&1 &
        PID=$!
        echo $PID > "$PID_FILE"
        echo "Jekyll started in background with PID $PID."
        echo "Logs are being written to $LOG_FILE"
        echo "You can view logs using: $0 logs"
    fi
}

stop() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 $PID 2>/dev/null; then
            echo "Stopping Jekyll (PID: $PID)..."
            kill $PID
            rm "$PID_FILE"
            echo "Jekyll stopped."
        else
            echo "Jekyll is not running, but PID file exists. Cleaning up..."
            rm "$PID_FILE"
        fi
    else
        echo "Jekyll is not currently running."
    fi
}

status() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 $PID 2>/dev/null; then
            echo "Jekyll is RUNNING (PID: $PID)."
            echo "Local URL: http://localhost:4000"
        else
            echo "Jekyll is STOPPED (stale PID file found)."
        fi
    else
        echo "Jekyll is STOPPED."
    fi
}

logs() {
    if [ -f "$LOG_FILE" ]; then
        echo "Tailing logs from $LOG_FILE (Press Ctrl+C to exit)..."
        tail -f "$LOG_FILE"
    else
        echo "Log file $LOG_FILE does not exist yet."
    fi
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    logs)
        logs
        ;;
    *)
        echo "Usage: $0 {start|stop|status|logs}"
        exit 1
        ;;
esac
