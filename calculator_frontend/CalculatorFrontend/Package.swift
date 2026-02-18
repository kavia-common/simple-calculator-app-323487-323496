// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CalculatorFrontend",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .executable(name: "CalculatorFrontend", targets: ["CalculatorFrontend"])
    ],
    targets: [
        .executableTarget(
            name: "CalculatorFrontend",
            path: "Sources/CalculatorFrontend"
        ),
        .testTarget(
            name: "CalculatorFrontendTests",
            dependencies: ["CalculatorFrontend"],
            path: "Tests/CalculatorFrontendTests"
        )
    ]
)
