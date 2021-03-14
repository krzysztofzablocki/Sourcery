// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Sourcery",
    platforms: [
       .macOS(.v10_12),
    ],
    products: [
        .executable(name: "sourcery", targets: ["Sourcery"]),
        .library(name: "SourceryParser", targets: ["SourceryParser"]),
        .library(name: "SourceryRuntime", targets: ["SourceryRuntime"]),
        .library(name: "SourceryStencil", targets: ["SourceryStencil"]),
        .library(name: "SourceryJS", targets: ["SourceryJS"]),
        .library(name: "SourcerySwift", targets: ["SourcerySwift"]),
        .library(name: "SourceryFramework", targets: ["SourceryFramework"]),
    ],
    dependencies: [
        .package(name: "Yams", url: "https://github.com/jpsim/Yams.git", .exact("4.0.0")),
        .package(name: "Commander", url: "https://github.com/kylef/Commander.git", .exact("0.9.1")),
        // PathKit needs to be exact to avoid a SwiftPM bug where dependency resolution takes a very long time.
        .package(name: "PathKit", url: "https://github.com/kylef/PathKit.git", .exact("1.0.0")),
        .package(name: "StencilSwiftKit", url: "https://github.com/SwiftGen/StencilSwiftKit.git", .exact("2.8.0")),
        .package(name: "XcodeProj", url: "https://github.com/tuist/xcodeproj", .exact("7.18.0")),
        .package(name: "SwiftSyntax",
                 url: "https://github.com/apple/swift-syntax.git",
                 .exact("0.50300.0"))
    ],
    targets: [
        .target(name: "Sourcery", dependencies: [
            "SourceryParser",
            "SourceryFramework",
            "SourceryRuntime",
            "SourceryStencil",
            "SourceryJS",
            "SourcerySwift",
            "Commander",
            "PathKit",
            "Yams",
            "StencilSwiftKit",
            "SwiftSyntax",
        ]),
        .target(name: "SourceryParser", dependencies: [
            "SourceryFramework",
            "SourceryRuntime",
            "PathKit",
            "Yams",
            "XcodeProj",
            "TryCatch",
        ]),
        .target(name: "SourceryRuntime"),
        .target(name: "SourceryUtils", dependencies: [
          "PathKit"
        ]),
        .target(name: "SourceryFramework", dependencies: [
          "PathKit",
          "SwiftSyntax",
          "SourceryUtils",
          "SourceryRuntime"
        ]),
        .target(name: "SourceryStencil", dependencies: [
          "PathKit",
          "SourceryRuntime",
          "StencilSwiftKit",
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
