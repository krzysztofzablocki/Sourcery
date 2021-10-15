[![CircleCI](https://circleci.com/gh/krzysztofzablocki/Sourcery.svg?style=shield)](https://circleci.com/gh/krzysztofzablocki/Sourcery)
<!-- [![codecov](https://codecov.io/gh/krzysztofzablocki/Sourcery/branch/master/graph/badge.svg)](https://codecov.io/gh/krzysztofzablocki/Sourcery) -->
[![docs](https://merowing.info/Sourcery/badge.svg)](https://merowing.info/Sourcery/index.html)
[![Version](https://img.shields.io/cocoapods/v/Sourcery.svg?style=flat)](http://cocoapods.org/pods/Sourcery)
[![License](https://img.shields.io/cocoapods/l/Sourcery.svg?style=flat)](http://cocoapods.org/pods/Sourcery)
[![Platform](https://img.shields.io/cocoapods/p/Sourcery.svg?style=flat)](http://cocoapods.org/pods/Sourcery)

**There is now a new powerful way to both write and integrate Sourcery functionality: Sourcery Pro provides powerful Stencil editor and extends Xcode with ability to handle live AST templates: [available on Mac App Store](https://apps.apple.com/us/app/sourcery-pro/id1561780836?mt=12)**

[Learn more about Sourcery Pro](http://merowing.info/sourcery-pro/)

[![](https://user-images.githubusercontent.com/1468993/114271090-f6c19200-9a0f-11eb-9bd8-d7bb15129eb2.mp4)](https://apps.apple.com/us/app/sourcery-pro/id1561780836?mt=12)

<img src="Resources/icon-128.png">

**Sourcery** is a code generator for Swift language, built on top of Apple's own SwiftSyntax. It extends the language abstractions to allow you to generate boilerplate code automatically.

It's used in over 40,000 projects on both iOS and macOS and it powers some of the most popular and critically-acclaimed apps you have used (including Airbnb, Bumble, New York Times). Its massive community adoption was one of the factors that pushed Apple to implement derived Equality and automatic Codable conformance. Sourcery is maintained by a growing community of [contributors](https://github.com/krzysztofzablocki/Sourcery/graphs/contributors).

Try **Sourcery** for your next project or add it to an existing one -- you'll save a lot of time and be happy you did!

## TL;DR
Sourcery allows you to get rid of repetitive code and create better architecture and developer workflows. 
An example might be implementing `Mocks` for all your protocols, without Sourcery you will need to write **hundreds lines of code per each protocol** like this:

```swift
class MyProtocolMock: MyProtocol {

    //MARK: - sayHelloWith
    var sayHelloWithNameCallsCount = 0
    var sayHelloWithNameCalled: Bool {
        return sayHelloWithNameCallsCount > 0
    }
    var sayHelloWithNameReceivedName: String?
    var sayHelloWithNameReceivedInvocations: [String] = []
    var sayHelloWithNameClosure: ((String) -> Void)?

    func sayHelloWith(name: String) {
        sayHelloWithNameCallsCount += 1
        sayHelloWithNameReceivedName = name
        sayHelloWithNameReceivedInvocations.append(name)
        sayHelloWithNameClosure?(name)
    }

}
```

and with Sourcery ?

```swift
extension MyProtocol: AutoMockable {}
```

Sourcery removes the need to write any of the mocks code, how many protocol do you have in your project? Imagine how much time you'll save, using Sourcery will also make every single mock consistent and if you refactor or add properties, the mock code will be automatically updated for you, eliminating possible human errors. 

Sourcery can be applied to arbitrary problems across your codebase, if you can describe an algorithm to another human, you can automate it using Sourcery.

Most common uses are:

- [Equality](https://merowing.info/Sourcery/equatable.html) & [Hashing](https://merowing.info/Sourcery/hashable.html)
- [Enum cases & Counts](https://merowing.info/Sourcery/enum-cases.html)
- [Lenses](https://merowing.info/Sourcery/lenses.html)
- [Mocks & Stubs](https://merowing.info/Sourcery/mocks.html)
- [LinuxMain](https://merowing.info/Sourcery/linuxmain.html)
- [Decorators](https://merowing.info/Sourcery/decorator.html)
- [Persistence and advanced Codable](https://merowing.info/Sourcery/codable.html)
- [Property level diffing](https://merowing.info/Sourcery/diffable.html)

But how about more specific use-cases, like automatically generating all the UI for your app `BetaSetting`? [you can use Sourcery for that too](https://github.com/krzysztofzablocki/AutomaticSettings)

Once you start writing your own template and learn the power of Sourcery you won't be able to live without it.

## How To Get Started
There are plenty of tutorials for different uses of Sourcery, and you can always ask for help in our [Swift Forum Category](https://forums.swift.org/c/related-projects/sourcery).

- [The Magic of Sourcery](https://www.caseyliss.com/2017/3/31/the-magic-of-sourcery) is a great starting tutorial
- [Generating Swift Code for iOS](https://www.raywenderlich.com/158803/sourcery-tutorial-generating-swift-code-ios) deals with JSON handling code
- [How To Automate Swift Boilerplate with Sourcery](https://atomicrobot.io/blog/sourcery/) generates conversions to dictionaries
- [Codable Enums](https://littlebitesofcocoa.com/318-codable-enums) implements Codable support for Enumerations
- [Sourcery Workshops](https://github.com/krzysztofzablocki/SourceryWorkshops)

## Installation

- _Binary form_

    Download the  latest release with the prebuilt binary from [release tab](https://github.com/krzysztofzablocki/Sourcery/releases/latest). Unzip the archive into the desired destination and run `bin/sourcery`
    
- _[Homebrew](https://brew.sh)_

	`brew install sourcery`


- _[CocoaPods](https://cocoapods.org)_

    Add `pod 'Sourcery'` to your `Podfile` and run `pod update Sourcery`. This will download the latest release binary and will put it in your project's CocoaPods path so you will run it with `$PODS_ROOT/Sourcery/bin/sourcery`

    If you only want to install the `sourcery` binary and its `lib_InternalSwiftSyntaxParser.dylib` dependency, you may want to use the `CLI-Only` subspec: `pod 'Sourcery', :subspecs => ['CLI-Only']`.

- _[Mint](https://github.com/yonaskolb/Mint)_

    Mint is no longer recommended, due to how SwiftSyntax dylib linking and lack of SPM support for changing r-path, you can't just build sourcery with plain SPM and expect it to work with different Xcode versions across your team. 
    
- _Building from source_

    Download the latest release source code from [the release tab](https://github.com/krzysztofzablocki/Sourcery/releases/latest) or clone the repository and build Sourcery manually.

    - _Building with Swift Package Manager_

        Run `swift build -c release` in the root folder. This will create a `.build/release` folder and will put the binary there. Move the **whole `.build/release` folder** to your desired destination and run with `path_to_release_folder/sourcery`

        > Note: JS templates are not supported when building with SPM yet.

    - _Building with Xcode_

        Generate xcodeproj with `swift package generate-xcodeproj`

        Open `Sourcery.xcworkspace` and build with `Sourcery-Release` scheme. This will create `Sourcery.app` in the Derived Data folder. You can copy it to your desired destination and run with `path_to_sourcery_app/Sourcery.app/Contents/MacOS/Sourcery`

## Documentation

Full documentation for the latest release is available [here](http://merowing.info/Sourcery/).

## Usage

Sourcery is a command line tool; you can either run it manually or in a custom build phase using the following command:

```
$ ./bin/sourcery --sources <sources path> --templates <templates path> --output <output path>
```

> Note: this command differs depending on how you installed Sourcery (see [Installing](#installing))

### Command line options

- `--sources` - Path to a source swift files or directories. You can provide multiple paths using multiple `--sources` option.
- `--templates` - Path to templates. File or Directory. You can provide multiple paths using multiple `--templates` options.
- `--force-parse` - File extensions of Sourcery generated file you want to parse. You can provide multiple extension using multiple `--force-parse` options. (i.e. `file.toparse.swift` will be parsed even if generated by Sourcery if `--force-parse toparse`). Useful when trying to implement a multiple phases generation. `--force-parse` can also be used to process within a sourcery annotation. For example to process code within `sourcery:inline:auto:Type.AutoCodable` annotation you can use `--force-parse AutoCodable`
- `--output` [default: current path] - Path to output. File or Directory.
- `--config` [default: current path] - Path to config file. File or Directory. See [Configuration file](#configuration-file).
- `--args` - Additional arguments to pass to templates. Each argument can have an explicit value or will have implicit `true` value. Arguments should be separated with `,` without spaces (i.e. `--args arg1=value,arg2`). Arguments are accessible in templates via `argument.name`
- `--watch` [default: false] - Watch both code and template folders for changes and regenerate automatically.
- `--verbose` [default: false] - Turn on verbose logging
- `--quiet` [default: false] - Turn off any logging, only emit errors
- `--disableCache` [default: false] - Turn off caching of parsed data
- `--prune` [default: false] - Prune empty generated files
- `--version` - Display the current version of Sourcery
- `--help` - Display help information

### Configuration file

Instead of CLI arguments you can use a `.sourcery.yml` configuration file:

```yaml
sources:
  - <sources path>
  - <sources path>
templates:
  - <templates path>
  - <templates path>
force-parse:
  - <string value>
  - <string value>
output:
  <output path>
args:
  <name>: <value>
```

Read more about this configuration file [here](https://merowing.info/Sourcery/usage.html#configuration-file).

## Issues
If you get unverified developer warning when using binary zip distribution try:
`xattr -dr com.apple.quarantine Sourcery-1.1.1`

## Contributing

Contributions to Sourcery are welcomed and encouraged!

It is easy to get involved. Please see the [Contributing guide](CONTRIBUTING.md) for more details.

[A list of contributors is available through GitHub](https://github.com/krzysztofzablocki/Sourcery/graphs/contributors).

To clarify what is expected of our community, Sourcery has adopted the code of conduct defined by the Contributor Covenant. This document is used across many open source communities, and articulates my values well. For more, see the [Code of Conduct](CODE_OF_CONDUCT.md).

## Sponsoring

If you'd like to support Sourcery development you can do so through [GitHub Sponsors](https://github.com/sponsors/krzysztofzablocki) or [Open Collective](https://opencollective.com/sourcery), it's highly appreciated 🙇‍

## License

Sourcery is available under the MIT license. See [LICENSE](LICENSE) for more information.

## Attributions

This tool is powered by

- [Stencil](https://github.com/kylef/Stencil) and few other libs by [Kyle Fuller](https://github.com/kylef)

Thank you! to:

- [Mariusz Ostrowski](http://twitter.com/faktory) for creating the logo.
- [Artsy Eidolon](https://github.com/artsy/eidolon) team, because we use their codebase as a stub data for performance testing the parser.
- [Olivier Halligon](https://github.com/AliSoftware) for showing me his setup scripts for CLI tools which are powering our rakefile.
- [JP Simard](https://github.com/jpsim) for creating [SourceKitten](https://github.com/jpsim/SourceKitten) that originally powered Sourcery and was instrumental in making this project happen. 

## Other Libraries / Tools

If you want to generate code for asset related data like .xib, .storyboards etc. use [SwiftGen](https://github.com/AliSoftware/SwiftGen). SwiftGen and Sourcery are complementary tools.

Make sure to check my other libraries and tools, especially:
- [KZPlayground](https://github.com/krzysztofzablocki/KZPlayground) - Powerful playgrounds for Swift and Objective-C
- [KZFileWatchers](https://github.com/krzysztofzablocki/KZFileWatchers) - Daemon for observing local and remote file changes, used for building other developer tools (Sourcery uses it)

You can [follow me on Twitter][1] for news/updates about other projects I am creating.

 [1]: http://twitter.com/merowing_
