#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/simple-calculator-app-323487-323496/calculator_frontend"
mkdir -p "$WORKSPACE"
cd "$WORKSPACE"
command -v swift >/dev/null 2>&1 || { echo "ERROR: swift not found; run install step" >&2; exit 2; }
# create Package.swift
cat >Package.swift <<'SWIFT'
// swift-tools-version:5.9
import PackageDescription
let package = Package(
  name: "CalculatorPackage",
  products: [
    .library(name: "Calculator", targets: ["Calculator"]),
    .executable(name: "calc-demo", targets: ["CalcDemo"])
  ],
  targets: [
    .target(name: "Calculator", path: "Sources/Calculator"),
    .executableTarget(name: "CalcDemo", dependencies: ["Calculator"], path: "Sources/CalcDemo"),
    .testTarget(name: "CalculatorTests", dependencies: ["Calculator"], path: "Tests/CalculatorTests")
  ]
)
SWIFT

# sources
mkdir -p Sources/Calculator Sources/CalcDemo Tests/CalculatorTests .init
cat >Sources/Calculator/Calculator.swift <<'SW'
public struct Calculator {
  public init() {}
  public func add(_ a: Int, _ b: Int) -> Int { a + b }
  public func sub(_ a: Int, _ b: Int) -> Int { a - b }
  public func mul(_ a: Int, _ b: Int) -> Int { a * b }
  public func div(_ a: Int, _ b: Int) -> Int { a / b }
}
SW

cat >Sources/CalcDemo/main.swift <<'SW'
import Foundation
import Calculator
let calc = Calculator()
print("calc-demo: 2+3=\(calc.add(2,3))")
// keep running until killed to allow start/stop validation
while true { sleep(3600) }
SW

cat >Tests/CalculatorTests/CalculatorTests.swift <<'SW'
import XCTest
@testable import Calculator
final class CalculatorTests: XCTestCase {
  func testAdd() {
    let c = Calculator()
    XCTAssertEqual(c.add(2,3), 5)
  }
}
SW

# start helper: locate project root relative to helper script location (portable)
cat >start_demo.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail
# change to project root (one level up from this script)
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_ROOT=$(cd "$SCRIPT_DIR"/.. && pwd)
cd "$PROJECT_ROOT"
EXEC=".build/debug/calc-demo"
if [ ! -x "$EXEC" ]; then echo "ERROR: exec not found at $EXEC; build first" >&2; exit 2; fi
"$EXEC" &
PID=$!
# ensure .init exists and write pid for external stop scripts
mkdir -p "$SCRIPT_DIR"/../.init
echo "$PID" > "$SCRIPT_DIR"/../.init/demo.pid
SH
chmod +x start_demo.sh

# also create a stop helper that reads pid from .init/demo.pid
cat >.init/stop_demo.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail
PID_FILE="$(cd "$(dirname "$0")" && pwd)/demo.pid"
if [ ! -f "$PID_FILE" ]; then echo "ERROR: pid file not found at $PID_FILE" >&2; exit 2; fi
PID=$(cat "$PID_FILE")
if kill -0 "$PID" >/dev/null 2>&1; then kill "$PID" && rm -f "$PID_FILE"; else echo "WARNING: process $PID not running" >&2; rm -f "$PID_FILE"; fi
SH
chmod +x .init/stop_demo.sh

echo "scaffold created"
