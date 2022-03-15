// swift-tools-version:5.3

import PackageDescription
import Foundation

let package = Package(
    name: "Sourcery",
    platforms: [
       .macOS(.v10_12),
    ],
    products: [
        // SPM won't generate .swiftmodule for a target directly used by a product,
        // hence it can't be imported by tests. Executable target can't be imported too.
        .executable(name: "sourcery", targets: ["SourceryExecutable"]),
        .library(name: "SourceryRuntime", targets: ["SourceryRuntime"]),
        .library(name: "SourceryStencil", targets: ["SourceryStencil"]),
        .library(name: "SourceryJS", targets: ["SourceryJS"]),
        .library(name: "SourcerySwift", targets: ["SourcerySwift"]),
        .library(name: "SourceryFramework", targets: ["SourceryFramework"]),
    ],
    dependencies: [
        .package(name: "Yams", url: "https://github.com/jpsim/Yams.git", from: "4.0.6"),
        .package(name: "Commander", url: "https://github.com/kylef/Commander.git", .exact("0.9.1")),
        // PathKit needs to be exact to avoid a SwiftPM bug where dependency resolution takes a very long time.
        .package(name: "PathKit", url: "https://github.com/kylef/PathKit.git", .exact("1.0.1")),
        .package(name: "StencilSwiftKit", url: "https://github.com/SwiftGen/StencilSwiftKit.git", .exact("2.8.0")),
        .package(name: "XcodeProj", url: "https://github.com/tuist/xcodeproj", .exact("8.3.1")),
        .package(name: "SwiftSyntax",
                 url: "https://github.com/apple/swift-syntax.git",
                 .exact("0.50500.0")),
        .package(url: "https://github.com/Quick/Quick.git", from: "3.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "9.0.0")
    ],
    targets: [
        .target(
            name: "SourceryExecutable",
            dependencies: ["SourceryLib"],
            path: "SourceryExecutable",
            exclude: [
                "Info.plist"
            ]
        ),
        .target(
            // Xcode doesn't like when a target has the same name as a product but in different case.
            name: "SourceryLib",
            dependencies: [
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
                "lib_InternalSwiftSyntaxParser",
                "XcodeProj",
                "TryCatch"
            ],
            path: "Sourcery",
            exclude: [
                "Templates",
            ]
        ),
        .target(
            name: "SourceryRuntime",
            path: "SourceryRuntime",
            exclude: [
                "Supporting Files/Info.plist"
            ]
        ),
        .target(
            name: "SourceryUtils",
            dependencies: [
                "PathKit"
            ],
            path: "SourceryUtils",
            exclude: [
                "Supporting Files/Info.plist"
            ]
        ),
        .target(
            name: "SourceryFramework",
            dependencies: [
              "PathKit",
              "SwiftSyntax",
              "lib_InternalSwiftSyntaxParser",
              "SourceryUtils",
              "SourceryRuntime"
            ],
            path: "SourceryFramework",
            exclude: [
                "Info.plist"
            ]
        ),
        .target(
            name: "SourceryStencil",
            dependencies: [
              "PathKit",
              "SourceryRuntime",
              "StencilSwiftKit",
            ],
            path: "SourceryStencil",
            exclude: [
                "Info.plist"
            ]
        ),
        .target(
            name: "SourceryJS",
            dependencies: [
                "PathKit"
            ],
            path: "SourceryJS",
            exclude: [
                "Info.plist"
            ],
            resources: [
                .copy("Resources/ejs.js")
            ]
        ),
        .target(
            name: "SourcerySwift",
            dependencies: [
              "PathKit",
              "SourceryRuntime",
              "SourceryUtils"
            ],
            path: "SourcerySwift",
            exclude: [
                "Info.plist"
            ]
        ),
        .target(
            name: "CodableContext",
            path: "Templates/Tests",
            exclude: [
                "Context/AutoCases.swift",
                "Context/AutoEquatable.swift",
                "Context/AutoHashable.swift",
                "Context/AutoLenses.swift",
                "Context/AutoMockable.swift",
                "Context/LinuxMain.swift",
                "Generated/AutoCases.generated.swift",
                "Generated/AutoEquatable.generated.swift",
                "Generated/AutoHashable.generated.swift",
                "Generated/AutoLenses.generated.swift",
                "Generated/AutoMockable.generated.swift",
                "Generated/LinuxMain.generated.swift",
                "Expected",
                "Info.plist",
                "TemplatesTests.swift"
            ],
            sources: [
                "Context/AutoCodable.swift",
                "Generated/AutoCodable.generated.swift"
            ]
        ),
        .target(name: "TryCatch", path: "TryCatch", exclude: ["Info.plist"]),
        .testTarget(
            name: "SourceryLibTests",
            dependencies: [
                "SourceryLib",
                "Quick",
                "Nimble"
            ],
            exclude: [
                "Info.plist"
            ],
            resources: [
                .copy("Stub/Configs"),
                .copy("Stub/Errors"),
                .copy("Stub/JavaScriptTemplates"),
                .copy("Stub/SwiftTemplates"),
                .copy("Stub/Performance-Code"),
                .copy("Stub/Result"),
                .copy("Stub/Templates"),
                .copy("Stub/Source")
            ]
        ),
        .testTarget(
            name: "CodableContextTests",
            dependencies: [
                "CodableContext",
                "Quick",
                "Nimble"
            ],
            path: "Templates/CodableContextTests",
            exclude: [
                "Info.plist"
            ]
        ),
        .testTarget(
            name: "TemplatesTests",
            dependencies: [
                "Quick",
                "Nimble",
                "PathKit"
            ],
            path: "Templates",
            exclude: [
                "CodableContext",
                "CodableContextTests",
                "Tests/Generated",
                "Tests/Info.plist",
                "default.profraw"
            ],
            sources: [
                // LinuxMain is not compiled as part of the target
                // since there is no way to run script before compilation begins.
                "Tests/TemplatesTests.swift"
            ],
            resources: [
                .copy("Templates"),
                .copy("Tests/Context"),
                .copy("Tests/Expected")
            ]
        ),
        .binaryTarget(
            name: "lib_InternalSwiftSyntaxParser",
            url: "https://github.com/keith/StaticInternalSwiftSyntaxParser/releases/download/5.5.2/lib_InternalSwiftSyntaxParser.xcframework.zip",
            checksum: "96bbc9ab4679953eac9ee46778b498cb559b8a7d9ecc658e54d6679acfbb34b8"
        )
    ]
)
