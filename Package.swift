// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Sourcery",
    products: [
        .executable(name: "sourcery", targets: ["Sourcery"]),
        .library(name: "SourceryRuntime", targets: ["SourceryRuntime"]),
        .library(name: "SourceryJS", targets: ["SourceryJS"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/Commander.git", .exact("0.7.1")),
        // PathKit needs to be exact to avoid a SwiftPM bug where dependency resolution takes a very long time.
        .package(url: "https://github.com/kylef/PathKit.git", .exact("0.9.1")),
        .package(url: "https://github.com/jpsim/SourceKitten.git", .exact("0.21.2")),
        .package(url: "https://github.com/kylef/Stencil.git", .exact("0.12.1")),
        .package(url: "https://github.com/SwiftGen/StencilSwiftKit.git", .exact("2.6.0")),
        .package(url: "https://github.com/seanparsons/SwiftTryCatch.git", .revision("e7074a72e4d4dc516f391bc4d4afd8ca6a845b4b")),
        .package(url: "https://github.com/xcodeswift/xcproj.git", .exact("4.3.1")),
        .package(url: "https://github.com/tadija/AEXML.git", .exact("4.3.3")),
    ],
    targets: [
        .target(name: "Sourcery", dependencies: [
            "SourceryRuntime",
            "SourceryJS",
            "Commander",
            "PathKit",
            "SourceKittenFramework",
            "StencilSwiftKit",
            "xcproj",
            "SwiftTryCatch",
        ]),
        .target(name: "SourceryRuntime"),
        .target(name: "SourceryJS", dependencies: [
          "PathKit"
        ])
    ]
)
