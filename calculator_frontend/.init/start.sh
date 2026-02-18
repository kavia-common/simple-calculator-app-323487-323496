#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/simple-calculator-app-323487-323496/calculator_frontend"
cd "$WORKSPACE"
# ensure built executable exists
if [ ! -x ".build/debug/calc-demo" ]; then echo "ERROR: .build/debug/calc-demo not found; run .init/build.sh or build script" >&2; exit 2; fi
# call start helper (keeps pid in .init/demo.pid)
./start_demo.sh
sleep 1
PID_FILE=".init/demo.pid"
if [ ! -f "$PID_FILE" ]; then echo "ERROR: start failed; pid file missing" >&2; exit 2; fi
PID=$(cat "$PID_FILE")
if kill -0 "$PID" >/dev/null 2>&1; then echo "$PID"; else echo "ERROR: process $PID not running after start" >&2; exit 3; fi
