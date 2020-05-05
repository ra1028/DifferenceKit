// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "DifferenceKit",
    platforms: [
        .iOS(.v9), .macOS(.v10_10), .tvOS(.v9), .watchOS(.v2)
    ],
    products: [
        .library(name: "DifferenceKit", targets: ["DifferenceKit"])
    ],
    targets: [
        .target(
            name: "DifferenceKit",
            path: "Sources"
        ),
        .testTarget(
            name: "DifferenceKitTests",
            dependencies: ["DifferenceKit"],
            path: "Tests"
        )
    ],
    swiftLanguageVersions: [.v4_2, .v5]
)
