// swift-tools-version:5.8

import PackageDescription
import Foundation

var sourceryLibDependencies: [Target.Dependency] = [
    "SourceryFramework",
    "SourceryRuntime",
    "SourceryStencil",
    "SourceryJS",
    "SourcerySwift",
    "Commander",
    "PathKit",
    "Yams",
    "StencilSwiftKit",
    .product(name: "SwiftSyntax", package: "swift-syntax"),
    "XcodeProj",
    .product(name: "SwiftPM-auto", package: "swift-package-manager"),
]

// Note: when Swift Linux doesn't bug out on [String: String], add a test back for it
// See https://github.com/krzysztofzablocki/Sourcery/pull/1208#issuecomment-1752185381
#if canImport(ObjectiveC)
sourceryLibDependencies.append("TryCatch")
let templatesTestsResourcesCopy: [Resource] = [
    .copy("Templates"),
    .copy("Tests/Context"),
    .copy("Tests/Expected")
]
#else
sourceryLibDependencies.append(.product(name: "Crypto", package: "swift-crypto"))
let templatesTestsResourcesCopy: [Resource] = [
    .copy("Templates"),
    .copy("Tests/Context_Linux"),
    .copy("Tests/Expected")
]
#endif

// Note: when Swift Linux doesn't bug out on [String: String], add a test back for it
// See https://github.com/krzysztofzablocki/Sourcery/pull/1208#issuecomment-1752185381
#if canImport(ObjectiveC)
let sourceryLibTestsResources: [Resource] = [
    .copy("Stub/Configs"),
    .copy("Stub/Errors"),
    .copy("Stub/JavaScriptTemplates"),
    .copy("Stub/SwiftTemplates"),
    .copy("Stub/Performance-Code"),
    .copy("Stub/DryRun-Code"),
    .copy("Stub/Result"),
    .copy("Stub/Templates"),
    .copy("Stub/Source")
]
#else
let sourceryLibTestsResources: [Resource] = [
    .copy("Stub/Configs"),
    .copy("Stub/Errors"),
    .copy("Stub/JavaScriptTemplates"),
    .copy("Stub/SwiftTemplates"),
    .copy("Stub/Performance-Code"),
    .copy("Stub/DryRun-Code"),
    .copy("Stub/Result"),
    .copy("Stub/Templates"),
    .copy("Stub/Source_Linux")
]
#endif

var targets: [Target] = [
    .executableTarget(
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
        dependencies: sourceryLibDependencies,
        path: "Sourcery",
        exclude: [
            "Templates",
        ]
    ),
    .target(
        name: "SourceryRuntime",
        dependencies: [
            "StencilSwiftKit"
        ],
        path: "SourceryRuntime",
        exclude: [
            "Supporting Files/Info.plist"
        ]
    ),
    .target(
        name: "SourceryFramework",
        dependencies: [
            "PathKit",
            .product(name: "SwiftSyntax", package: "swift-syntax"),
            .product(name: "SwiftParser", package: "swift-syntax"),
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
        resources: sourceryLibTestsResources,
        swiftSettings: [.unsafeFlags(["-enable-testing"])]
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
        ],
        swiftSettings: [.unsafeFlags(["-enable-testing"])]
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
            "Tests/Info.plist"
        ],
        sources: [
            // LinuxMain is not compiled as part of the target
            // since there is no way to run script before compilation begins.
            "Tests/TemplatesTests.swift"
        ],
        resources: templatesTestsResourcesCopy,
        swiftSettings: [.unsafeFlags(["-enable-testing"])]
    ),
    .plugin(
        name: "SourceryCommandPlugin",
        capability: .command(
            intent: .custom(
                verb: "sourcery-command",
                description: "Sourcery command plugin for code generation"
            ),
            permissions: [
                .writeToPackageDirectory(reason: "Need permission to write generated files to package directory")
            ]
        ),
        dependencies: ["SourceryExecutable"]
    )
]

#if canImport(ObjectiveC)
let sourceryUtilsDependencies: [Target.Dependency] = ["PathKit"]
targets.append(.target(name: "TryCatch", path: "TryCatch", exclude: ["Info.plist"]))
#else
let sourceryUtilsDependencies: [Target.Dependency] = [
    "PathKit",
    .product(name: "Crypto", package: "swift-crypto")
]
#endif
targets.append(
    .target(
        name: "SourceryUtils",
        dependencies: sourceryUtilsDependencies,
        path: "SourceryUtils",
        exclude: [
            "Supporting Files/Info.plist"
        ]
    )
)

var dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.3"),
    .package(url: "https://github.com/kylef/Commander.git", exact: "0.9.1"),
    // PathKit needs to be exact to avoid a SwiftPM bug where dependency resolution takes a very long time.
    .package(url: "https://github.com/kylef/PathKit.git", exact: "1.0.1"),
    .package(url: "https://github.com/art-divin/StencilSwiftKit.git", exact: "2.10.4"),
    .package(url: "https://github.com/tuist/XcodeProj.git", exact: "8.16.0"),
    .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.0"),
    .package(url: "https://github.com/Quick/Quick.git", from: "3.0.0"),
    .package(url: "https://github.com/Quick/Nimble.git", from: "9.0.0"),
    .package(url: "https://github.com/art-divin/swift-package-manager.git", from: "1.0.3"),
]

#if !canImport(ObjectiveC)
dependencies.append(.package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0"))
#endif

var package = Package(
    name: "Sourcery",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        // SPM won't generate .swiftmodule for a target directly used by a product,
        // hence it can't be imported by tests. Executable target can't be imported too.
//        .executable(name: "sourcery", targets: ["SourceryExecutable"]),
        .library(name: "SourceryRuntime", targets: ["SourceryRuntime"]),
        .library(name: "SourceryStencil", targets: ["SourceryStencil"]),
        .library(name: "SourceryJS", targets: ["SourceryJS"]),
        .library(name: "SourcerySwift", targets: ["SourcerySwift"]),
        .library(name: "SourceryFramework", targets: ["SourceryFramework"]),
        .library(name: "SourceryLib", targets: ["SourceryLib"]),
        .plugin(name: "SourceryCommandPlugin", targets: ["SourceryCommandPlugin"])
    ],
    dependencies: dependencies,
    targets: targets
)

package.targets.append(
    .testTarget(
        name: "Jeff",
        dependencies: [
            "SourceryLib",
            "Quick",
            "Nimble"
        ]
    )
)
