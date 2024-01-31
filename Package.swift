// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StreamDeckKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "StreamDeckKit",
            targets: ["StreamDeckKit"]
        ),
        .library(
            name: "StreamDeckLayout",
            targets: ["StreamDeckLayout"]
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
    ],
    targets: [
        .target(
            name: "StreamDeckSimulator",
            dependencies: ["StreamDeckLayout"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "StreamDeckLayout",
            dependencies: ["StreamDeckKit"]
        ),
        .target(
            name: "StreamDeckKit",
            dependencies: ["StreamDeckCApi"]
        ),
        .target(
            name: "StreamDeckCApi",
            linkerSettings: [.linkedFramework("IOKit")]
        ),
        .testTarget(
            name: "StreamDeckSDKTests",
            dependencies: [
                "StreamDeckKit",
                "StreamDeckLayout",
                "StreamDeckSimulator",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]
        )
    ]
)
