#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/simple-calculator-app-323487-323496/calculator_frontend"
cd "$WORKSPACE"
command -v swift >/dev/null 2>&1 || { echo "ERROR: swift not found; run install step" >&2; exit 2; }
# run unit tests
swift test --parallel
