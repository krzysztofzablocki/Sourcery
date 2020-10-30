# XcodeProj

[![CircleCI](https://circleci.com/gh/tuist/xcodeproj.svg?style=svg)](https://circleci.com/gh/tuist/xcodeproj)
[![Swift Package Manager](https://img.shields.io/badge/swift%20package%20manager-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Release](https://img.shields.io/github/release/tuist/xcodeproj.svg)](https://github.com/tuist/xcodeproj/releases)
[![Code Coverage](https://codecov.io/gh/tuist/xcodeproj/branch/master/graph/badge.svg)](https://codecov.io/gh/tuist/xcodeproj)
[![Slack](http://slack.tuist.io/badge.svg)](http://slack.tuist.io/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/tuist/xcodeproj/blob/master/LICENSE.md)

XcodeProj is a library written in Swift for parsing and working with Xcode projects. It's heavily inspired in [CocoaPods XcodeProj](https://github.com/CocoaPods/Xcodeproj) and [xcode](https://www.npmjs.com/package/xcode).

---

- [Projects Using XcodeProj](#projects-using-xcodeproj)
- [Installation](#installation)
- [Contributing](#contributing)
- [License](#license)

## Projects Using XcodeProj

| Project  | Repository                                                                             |
| -------- | -------------------------------------------------------------------------------------- |
| Tuist    | [github.com/tuist/tuist](https://github.com/tuist/tuist)                               |
| Sourcery | [github.com/krzysztofzablocki/Sourcery](https://github.com/krzysztofzablocki/Sourcery) |
| ProjLint | [github.com/JamitLabs/ProjLint](https://github.com/JamitLabs/ProjLint)                 |
| XcodeGen | [github.com/yonaskolb/XcodeGen](https://github.com/yonaskolb/XcodeGen)                 |
| xspm     | [gitlab.com/Pyroh/xspm](https://gitlab.com/Pyroh/xspm)                                 |

If you are also leveraging XcodeProj in your project, feel free to open a PR to include it in the list above.

## Installation

### Swift Package Manager

Add the dependency in your `Package.swift` file:

```swift
let package = Package(
    name: "myproject",
    dependencies: [
        .package(url: "https://github.com/tuist/xcodeproj.git", .upToNextMajor(from: "7.0.0")),
        ],
    targets: [
        .target(
            name: "myproject",
            dependencies: ["XcodeProj"]),
        ]
)
```

### Carthage

**Only macOS**

```bash
# Cartfile
github "tuist/xcodeproj" ~> 7.0.0
```

### CocoaPods

```ruby
pod 'xcodeproj', '~> 7.0.0'
```

### Scripting

Using [`swift-sh`] you can automate project-tasks using scripts, for example we
can make a script that keeps a project’s version key in sync with the current
git tag that represents the project’s version:

```swift
#!/usr/bin/swift sh
import Foundation
import XcodeProj  // @tuist ~> 7.0.0
import PathKit

guard CommandLine.arguments.count == 3 else {
    let arg0 = Path(CommandLine.arguments[0]).lastComponent
    fputs("usage: \(arg0) <project> <new-version>\n", stderr)
    exit(1)
}

let projectPath = Path(CommandLine.arguments[1])
let newVersion = CommandLine.arguments[2]
let xcodeproj = try XcodeProj(path: projectPath)
let key = "CURRENT_PROJECT_VERSION"

for conf in xcodeproj.pbxproj.buildConfigurations where conf.buildSettings[key] != nil {
    conf.buildSettings[key] = newVersion
}

try xcodeproj.write(path: projectPath)
```

You could then store this in your repository, for example at
`scripts/set-project-version` and then run it:

```bash
$ scripts/set-project-version ./App.xcodeproj 1.2.3
$ git add App.xcodeproj
$ git commit -m "Bump version"
$ git tag 1.2.3
```

Future adaption could easily include determining the version and bumping it
automatically. If so, we recommend using a library that provides a `Version`
object.

[`swift-sh`]: https://github.com/mxcl/swift-sh

## Documentation 📝

Want to start using XcodeProj? Start by digging into our [documentation](/Documentation) which will help you get familiar with the API and get to know more about the Xcode projects structure.

## References 📚

- [Xcode Project File Format](http://www.monobjc.net/xcode-project-file-format.html)
- [A brief look at the Xcode project format](http://danwright.info/blog/2010/10/xcode-pbxproject-files/)
- [pbexplorer](https://github.com/mjmsmith/pbxplorer)
- [pbxproj identifiers](https://pewpewthespells.com/blog/pbxproj_identifiers.html)
- [mob-pbxproj](https://github.com/kronenthaler/mod-pbxproj)
- [Xcodeproj](https://github.com/CocoaPods/Xcodeproj)
- [Nanaimo](https://github.com/CocoaPods/Nanaimo)
- [Facebook Buck](https://buckbuild.com/javadoc/com/facebook/buck/apple/xcode/xcodeproj/package-summary.html)
- [Swift Package Manager - Xcodeproj](https://github.com/apple/swift-package-manager/tree/master/Sources/Xcodeproj)

## Contributing

1. Git clone the repository `git@github.com:tuist/xcodeproj.git`.
2. Generate xcodeproj with `swift package generate-xcodeproj`.
3. Open `XcodeProj.xcodeproj`.

## License

XcodeProj is released under the MIT license. [See LICENSE](https://github.com/tuist/xcodeproj/blob/master/LICENSE.md) for details.

[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Ftuist%2Fxcodeproj.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Ftuist%2Fxcodeproj?ref=badge_large)

## Open source

Tuist is a proud supporter of the [Software Freedom Conservacy](https://sfconservancy.org/)

<a href="https://sfconservancy.org/supporter/"><img src="https://sfconservancy.org/img/supporter-badge.png" width="194" height="90" alt="Become a Conservancy Supporter!" border="0"/></a>
