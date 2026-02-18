#!/usr/bin/env bash
set -euo pipefail
# Delegates to the project-local start helper which finds project root
WORKSPACE="/home/kavia/workspace/code-generation/simple-calculator-app-323487-323496/calculator_frontend"
cd "$WORKSPACE"
[ -x ./.init/start_demo.sh ] || { echo "ERROR: start helper missing; run .init/scaffold.sh" >&2; exit 2; }
./.init/start_demo.sh
echo "started"
