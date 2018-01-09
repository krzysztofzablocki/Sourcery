// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Sourcery",
    products: [
        .executable(name: "sourcery", targets: ["Sourcery"]),
        .library(name: "SourceryRuntime", targets: ["SourceryRuntime"]),
    ],
    dependencies: [
        // https://github.com/kylef/Stencil/pull/84
        .package(url: "https://github.com/kylef/Commander.git", from: "0.6.1"),
        .package(url: "https://github.com/kylef/PathKit.git", from: "0.8.0"),
        .package(url: "https://github.com/jpsim/SourceKitten.git", from: "0.18.4"),
        .package(url: "https://github.com/vknabel/SwiftTryCatch.git", from: "1.1.0"),
        .package(url: "https://github.com/IBM-Swift/CommonCrypto.git", from: "0.0.1"),
        .package(url: "https://github.com/SwiftGen/StencilSwiftKit.git", from: "2.3.0"),
        .package(url: "https://github.com/tomlokhorst/XcodeEdit.git", from: "1.1.0"),
    ],
    targets: [
        .target(name: "Sourcery", dependencies: ["SourceryRuntime"]),
	    .target(name: "SourceryRuntime"),
    ]
)
