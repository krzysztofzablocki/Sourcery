// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Sourcery",
    products: [
        .executable(name: "sourcery", targets: ["Sourcery"]),
        .library(name: "SourceryRuntime", targets: ["SourceryRuntime"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/Commander.git", from: "0.6.1"),
        // PathKit needs to be exact to avoid a SwiftPM bug where dependency resolution takes a very long time.
        .package(url: "https://github.com/kylef/PathKit.git", .exact("0.8.0")),
        .package(url: "https://github.com/jpsim/SourceKitten.git", from: "0.18.1"),
        .package(url: "https://github.com/IBM-Swift/CommonCrypto.git", from: "0.1.5"),
        .package(url: "https://github.com/SwiftGen/StencilSwiftKit.git", from: "2.3.0"),
        .package(url: "https://github.com/seanparsons/SwiftTryCatch.git", .revision("e7074a72e4d4dc516f391bc4d4afd8ca6a845b4b")),
        .package(url: "https://github.com/tomlokhorst/XcodeEdit.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "Sourcery", dependencies: [
            "SourceryRuntime",
            "Commander",
            "PathKit",
            "SourceKittenFramework",
            "CommonCrypto",
            "StencilSwiftKit",
            "XcodeEdit",
            "SwiftTryCatch",
        ]),
        .target(name: "SourceryRuntime"),
    ]
)
