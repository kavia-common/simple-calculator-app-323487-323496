#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/simple-calculator-app-323487-323496/calculator_frontend"
cd "$WORKSPACE"
# Fail fast with clear diagnostics
command -v swift >/dev/null 2>&1 || { echo "ERROR: swift not found; run install step first" >&2; exit 2; }
[ -f Package.swift ] || { echo "ERROR: Package.swift missing; run scaffold" >&2; exit 3; }
# Run tests (parallel where supported)
swift test --parallel || { echo "ERROR: swift tests failed" >&2; exit 4; }
