// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StreamDeckKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "StreamDeckKit",
            targets: ["StreamDeckKit", "StreamDeckLayout"]
        ),
        .library(
            name: "StreamDeckSimulator",
            targets: ["StreamDeckSimulator"]
        )
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
            dependencies: ["StreamDeckKit"]
        )
    ]
)
