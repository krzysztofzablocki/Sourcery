import PackageDescription

let package = Package(
    name: "Sourcery",
    dependencies: [
        .Package(url: "https://github.com/kylef/Stencil.git", majorVersion: 0, minor: 7),
        .Package(url: "https://github.com/kylef/Commander.git", "0.6.0"),
        .Package(url: "https://github.com/kylef/PathKit.git", majorVersion: 0, minor: 7),
        .Package(url: "https://github.com/jpsim/SourceKitten.git", majorVersion: 0, minor: 15),
        .Package(url: "https://github.com/vknabel/SwiftTryCatch.git", majorVersion: 1, minor: 1),
        .Package(url: "https://github.com/krzysztofzablocki/KZFileWatchers.git", majorVersion: 1, minor: 0),
    ]
)
