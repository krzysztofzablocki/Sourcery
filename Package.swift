// swift-tools-version:5.3

import PackageDescription

let sourceryDependencies: [Target.Dependency] = [
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
    "XcodeProj",
    "TryCatch"
]

let package = Package(
    name: "Sourcery",
    platforms: [
       .macOS(.v10_12),
    ],
    products: [
        .executable(name: "sourcery", targets: ["Sourcery"]),
        // For testing purpose. The linker has problems linking against executable.
        .library(name: "SourceryLib", targets: ["SourceryLib"]),
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
                 .exact("0.50300.0")),
        .package(url: "https://github.com/Quick/Quick.git", from: "3.1.2"),
        .package(url: "https://github.com/HeMet/Nimble.git", .branch("win-support"))
    ],
    targets: [
        .target(name: "Sourcery", dependencies: sourceryDependencies),
        .target(name: "SourceryLib", dependencies: sourceryDependencies, path: "Sourcery", exclude: ["main.swift"]),
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
        .target(
            name: "SourceryJS",
            dependencies: [
                "PathKit"
            ],
            resources: [
                .copy("Resources/ejs.js")
            ]
        ),
        .target(name: "SourcerySwift", dependencies: [
          "PathKit",
          "SourceryRuntime",
          "SourceryUtils"
        ]),
        .target(
            name: "CodableContext",
            path: "Templates/Tests",
            sources: [
                "Context/AutoCodable.swift",
                "Generated/AutoCodable.generated.swift"
            ]
        ),
        .target(name: "TryCatch", path: "TryCatch"),
        .testTarget(
            name: "SourceryLibTests",
            dependencies: [
                "SourceryLib",
                "Quick",
                "Nimble"
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
            // If you want to run tests from Xcode by double clicking on Package.swift,
            // copy lib_InternalSwiftSyntaxParser.dylib into build output directory next to Sourcery binary.
            // This looks like Xcode SPM integration issue, since SPM alone has no such issue.
        ),
        .testTarget(
            name: "CodableContextTests",
            dependencies: [
                "CodableContext",
                "Quick",
                "Nimble"
            ],
            path: "Templates/CodableContextTests"
        ),
        .testTarget(
            name: "TemplatesTests",
            dependencies: [
                "Quick",
                "Nimble",
                "PathKit"
            ],
            path: "Templates",
            sources: [
                // LinuxMain is not compiled as part of the target
                // since there is no way atm to run custom script before compilation step.
                "Tests/TemplatesTests.swift"
            ],
            resources: [
                .copy("Templates"),
                .copy("Tests/Context"),
                .copy("Tests/Expected")
            ]
        )
    ]
)
