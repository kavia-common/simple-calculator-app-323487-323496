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
