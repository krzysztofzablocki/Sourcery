import PackageDescription

let package = Package(
    name: "Sourcery",
    targets: [
        Target(name: "sourcery", dependencies: [])
    ],
    dependencies: [
        // https://github.com/kylef/Stencil/pull/84
        .Package(url: "https://github.com/vknabel/Stencil.git", majorVersion: 0, minor: 7),
        .Package(url: "https://github.com/kylef/Commander.git", majorVersion: 0, minor: 6),
        // Requires new release including https://github.com/kylef/PathKit/commit/7b17207
        .Package(url: "https://github.com/vknabel/PathKit.git", majorVersion: 0, minor: 7),
        .Package(url: "https://github.com/jpsim/SourceKitten.git", majorVersion: 0, minor: 15),
        .Package(url: "https://github.com/vknabel/SwiftTryCatch.git", majorVersion: 1, minor: 1),
        .Package(url: "https://github.com/IBM-Swift/CommonCrypto.git", majorVersion: 0)
    ]
)
