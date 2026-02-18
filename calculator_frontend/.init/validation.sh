#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/simple-calculator-app-323487-323496/calculator_frontend"
cd "$WORKSPACE"
# Ensure swift exists
command -v swift >/dev/null 2>&1 || { echo "ERROR: swift not found; run install step" >&2; exit 2; }
# Build
swift build
# Run tests
swift test --parallel
# Start demo
./start_demo.sh
sleep 1
PID_FILE=".init/demo.pid"
if [ ! -f "$PID_FILE" ]; then echo "ERROR: demo failed to start (pid file missing)" >&2; exit 3; fi
PID=$(cat "$PID_FILE")
if kill -0 "$PID" >/dev/null 2>&1; then echo "demo running: $PID"; else echo "ERROR: demo not running" >&2; exit 4; fi
# Stop demo
if [ -x ".init/stop_demo.sh" ]; then ./.init/stop_demo.sh; else kill "$PID" || true; fi
if [ -f "$PID_FILE" ]; then echo "ERROR: pid file still present after stop" >&2; exit 5; fi
echo "validation ok"
