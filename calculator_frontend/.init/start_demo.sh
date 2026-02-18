#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_ROOT=$(cd "$SCRIPT_DIR"/.. && pwd)
cd "$PROJECT_ROOT"
EXEC=".build/debug/calc-demo"
[ -x "$EXEC" ] || { echo "ERROR: exec not found at $EXEC; run swift build" >&2; exit 2; }
"$EXEC" &
PID=$!
echo "$PID" > "$SCRIPT_DIR/demo.pid"
