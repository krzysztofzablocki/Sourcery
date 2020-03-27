// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Sourcery",
    platforms: [
       .macOS(.v10_11),
    ],
    products: [
        .executable(name: "sourcery", targets: ["Sourcery"]),
        .library(name: "SourceryRuntime", targets: ["SourceryRuntime"]),
        .library(name: "SourceryJS", targets: ["SourceryJS"]),
        .library(name: "SourcerySwift", targets: ["SourcerySwift"]),
        .library(name: "SourceryFramework", targets: ["SourceryFramework"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/Commander.git", .exact("0.7.1")),
        // PathKit needs to be exact to avoid a SwiftPM bug where dependency resolution takes a very long time.
        .package(url: "https://github.com/kylef/PathKit.git", .exact("0.9.2")),
        .package(url: "https://github.com/jpsim/SourceKitten.git", .exact("0.23.1")),
        .package(url: "https://github.com/SwiftGen/StencilSwiftKit.git", .exact("2.7.0")),
        .package(url: "https://github.com/tuist/xcodeproj", .exact("4.3.1")),
    ],
    targets: [
        .target(name: "Sourcery", dependencies: [
            "SourceryFramework",
            "SourceryRuntime",
            "SourceryJS",
            "SourcerySwift",
            "Commander",
            "PathKit",
            "SourceKittenFramework",
            "StencilSwiftKit",
            "xcproj",
            "TryCatch",
        ]),
        .target(name: "SourceryRuntime"),
        .target(name: "SourceryUtils", dependencies: [
          "PathKit"
        ]),
        .target(name: "SourceryFramework", dependencies: [
          "PathKit",
          "SourceKittenFramework",
          "SourceryUtils",
          "SourceryRuntime"
        ]),
        .target(name: "SourceryJS", dependencies: [
          "PathKit"
        ]),
        .target(name: "SourcerySwift", dependencies: [
          "PathKit",
          "SourceryRuntime",
          "SourceryUtils"
        ]),
        .target(name: "TryCatch", path: "TryCatch"),
    ]
)
