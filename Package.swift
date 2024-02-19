// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "StreamDeckKit",
    platforms: [.iOS(.v17), .macOS(.v10_15)],
    products: [
        .library(
            name: "StreamDeckKit",
            targets: ["StreamDeckKit"]
        ),
        .library(
            name: "StreamDeckSimulator",
            targets: ["StreamDeckSimulator"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.12.0"
          ),
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            from: "509.0.0"
        ),
    ],
    targets: [
        .target(
            name: "StreamDeckSimulator",
            dependencies: ["StreamDeckKit"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "StreamDeckKit",
            dependencies: ["StreamDeckCApi", "StreamDeckMacro"]
        ),
        .target(
            name: "StreamDeckCApi",
            linkerSettings: [.linkedFramework("IOKit")]
        ),
        .macro(
            name: "StreamDeckMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "StreamDeckSDKTests",
            dependencies: [
                "StreamDeckKit",
                "StreamDeckMacro",
                "StreamDeckSimulator",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        )
    ]
)
