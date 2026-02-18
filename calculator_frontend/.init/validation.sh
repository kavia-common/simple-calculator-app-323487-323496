#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/simple-calculator-app-323487-323496/calculator_frontend"
cd "$WORKSPACE"
command -v swift >/dev/null 2>&1 || { echo "ERROR: swift not found; install toolchain or run .init/install.sh" >&2; exit 2; }
# build
swift build --disable-sandbox >/dev/null
# test
swift test --disable-sandbox >/dev/null
# start demo
./.init/start_demo.sh
PID_FILE="$WORKSPACE/.init/demo.pid"
if [ ! -f "$PID_FILE" ]; then echo "ERROR: demo.pid not created" >&2; exit 2; fi
PID=$(cat "$PID_FILE")
if kill -0 "$PID" >/dev/null 2>&1; then echo "demo running pid=$PID"; else echo "ERROR: demo not running" >&2; exit 2; fi
# stop demo
./.init/stop_demo.sh
if [ -f "$PID_FILE" ]; then echo "ERROR: pid file still present after stop" >&2; exit 2; fi
echo "validation OK"
