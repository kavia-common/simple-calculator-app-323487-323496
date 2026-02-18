#!/usr/bin/env bash
set -euo pipefail
PID_FILE="$(cd "$(dirname "$0")" && pwd)/demo.pid"
if [ ! -f "$PID_FILE" ]; then echo "ERROR: pid file not found at $PID_FILE" >&2; exit 2; fi
PID=$(cat "$PID_FILE")
if kill -0 "$PID" >/dev/null 2>&1; then kill "$PID" && rm -f "$PID_FILE"; else rm -f "$PID_FILE"; fi
