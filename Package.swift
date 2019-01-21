// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "DifferenceKit",
    products: [
        .library(name: "DifferenceKit", targets: ["DifferenceKit"])
    ],
    targets: [
        .target(
            name: "DifferenceKit",
            path: "Sources",
            exclude: ["Extensions"]
        ),
        .testTarget(
            name: "DifferenceKitTests",
            dependencies: ["DifferenceKit"],
            path: "Tests"
        )
    ]
)