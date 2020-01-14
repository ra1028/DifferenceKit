// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Modules",
    dependencies: [
        .package(url: "https://github.com/ra1028/swift-mod.git", .exact("0.0.1"))
    ]
)
