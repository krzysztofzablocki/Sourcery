[![CircleCI](https://circleci.com/gh/krzysztofzablocki/Sourcery.svg?style=shield)](https://circleci.com/gh/krzysztofzablocki/Sourcery)
[![macOS](https://github.com/krzysztofzablocki/Sourcery/actions/workflows/macOS.yml/badge.svg)](https://github.com/krzysztofzablocki/Sourcery/actions/workflows/macOS.yml)
[![Ubuntu (Experimental)](https://github.com/krzysztofzablocki/Sourcery/actions/workflows/Ubuntu.yml/badge.svg)](https://github.com/krzysztofzablocki/Sourcery/actions/workflows/Ubuntu.yml)
<!-- [![codecov](https://codecov.io/gh/krzysztofzablocki/Sourcery/branch/master/graph/badge.svg)](https://codecov.io/gh/krzysztofzablocki/Sourcery) -->
[![docs](https://krzysztofzablocki.github.io/Sourcery/badge.svg)](https://krzysztofzablocki.github.io/Sourcery/index.html)
[![Version](https://img.shields.io/cocoapods/v/Sourcery.svg?style=flat)](http://cocoapods.org/pods/Sourcery)
[![License](https://img.shields.io/cocoapods/l/Sourcery.svg?style=flat)](http://cocoapods.org/pods/Sourcery)
[![Platform](https://img.shields.io/cocoapods/p/Sourcery.svg?style=flat)](http://cocoapods.org/pods/Sourcery)

**There is now a new powerful way to both write and integrate Sourcery functionality: Sourcery Pro provides a powerful Stencil editor and extends Xcode with the ability to handle live AST templates: [available on Mac App Store](https://apps.apple.com/us/app/sourcery-pro/id1561780836?mt=12)**

https://user-images.githubusercontent.com/1468993/114271090-f6c19200-9a0f-11eb-9bd8-d7bb15129eb2.mp4

[Learn more about Sourcery Pro](http://merowing.info/sourcery-pro/)

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

Sourcery removes the need to write any of the mocks code, how many protocols do you have in your project? Imagine how much time you'll save, using Sourcery will also make every single mock consistent and if you refactor or add properties, the mock code will be automatically updated for you, eliminating possible human errors. 

Sourcery can be applied to arbitrary problems across your codebase, if you can describe an algorithm to another human, you can automate it using Sourcery.

Most common uses are:

- [Equality](https://krzysztofzablocki.github.io/Sourcery/equatable.html) & [Hashing](https://krzysztofzablocki.github.io/Sourcery/hashable.html)
- [Enum cases & Counts](https://krzysztofzablocki.github.io/Sourcery/enum-cases.html)
- [Lenses](https://krzysztofzablocki.github.io/Sourcery/lenses.html)
- [Mocks & Stubs](https://krzysztofzablocki.github.io/Sourcery/mocks.html)
- [LinuxMain](https://krzysztofzablocki.github.io/Sourcery/linuxmain.html)
- [Decorators](https://krzysztofzablocki.github.io/Sourcery/decorator.html)
- [Persistence and advanced Codable](https://krzysztofzablocki.github.io/Sourcery/codable.html)
- [Property level diffing](https://krzysztofzablocki.github.io/Sourcery/diffable.html)

But how about more specific use-cases, like automatically generating all the UI for your app `BetaSetting`? [you can use Sourcery for that too](https://github.com/krzysztofzablocki/AutomaticSettings)

Once you start writing your own template and learn the power of Sourcery you won't be able to live without it.

## How To Get Started
There are plenty of tutorials for different uses of Sourcery, and you can always ask for help in our [Swift Forum Category](https://forums.swift.org/c/related-projects/sourcery).

- [The Magic of Sourcery](https://www.caseyliss.com/2017/3/31/the-magic-of-sourcery) is a great starting tutorial
- [Generating Swift Code for iOS](https://www.raywenderlich.com/158803/sourcery-tutorial-generating-swift-code-ios) deals with JSON handling code
- [How To Automate Swift Boilerplate with Sourcery](https://atomicrobot.io/blog/sourcery/) generates conversions to dictionaries
- [Codable Enums](https://littlebitesofcocoa.com/318-codable-enums) implements Codable support for Enumerations
- [Sourcery Workshops](https://github.com/krzysztofzablocki/SourceryWorkshops)

### Quick Mocking Intro & Getting Started Video

You can also watch this quick getting started and intro to mocking video by Inside iOS Dev: 
<br />

[![Watch the video](Resources/Inside-iOS-Dev-Sourcery-Intro-To-Mocking-Video-Thumbnail.png)](https://youtu.be/-ZbBNuttlt4?t=214)

## Installation

- _Binary form_

    Download the latest release with the prebuilt binary from [release tab](https://github.com/krzysztofzablocki/Sourcery/releases/latest). Unzip the archive into the desired destination and run `bin/sourcery`
    
- _[Homebrew](https://brew.sh)_

	`brew install sourcery`

- _[CocoaPods](https://cocoapods.org)_

    Add `pod 'Sourcery'` to your `Podfile` and run `pod update Sourcery`. This will download the latest release binary and will put it in your project's CocoaPods path so you will run it with `$PODS_ROOT/Sourcery/bin/sourcery`

    If you only want to install the `sourcery` binary, you may want to use the `CLI-Only` subspec: `pod 'Sourcery', :subspecs => ['CLI-Only']`.

- _[Mint](https://github.com/yonaskolb/Mint)_

    `mint run krzysztofzablocki/Sourcery`

- _Building from Source_

    Download the latest release source code from [the release tab](https://github.com/krzysztofzablocki/Sourcery/releases/latest) or clone the repository and build Sourcery manually.

    - _Building with Swift Package Manager_

        Run `swift build -c release` in the root folder and then copy `.build/release/sourcery` to your desired destination.

        > Note: JS templates are not supported when building with SPM yet.

    - _Building with Xcode_

        Run `xcodebuild -scheme sourcery -destination generic/platform=macOS -archivePath sourcery.xcarchive archive` and export the binary from the archive.

- _SPM (for plugin use only)_
Add the package dependency to your `Package.swift` manifest from version `1.8.3`.

```
.package(url: "https://github.com/krzysztofzablocki/Sourcery.git", from: "1.8.3")
```

- _[pre-commit](https://pre-commit.com/)_
Add the dependency to `.pre-commit-config.yaml`.

```
- repo: https://github.com/krzysztofzablocki/Sourcery
  rev: 1.9.1
  hooks:
  - id: sourcery
```

## Documentation

Full documentation for the latest release is available [here](http://merowing.info/Sourcery/).

## Linux Support

Linux support is [described on this page](LINUX.md).

## Usage

### Running the executable

Sourcery is a command line tool; you can either run it manually or in a custom build phase using the following command:

```
$ ./bin/sourcery --sources <sources path> --templates <templates path> --output <output path>
```

> Note: this command differs depending on how you installed Sourcery (see [Installation](#installation))

### Swift Package command

Sourcery can now be used as a Swift package command plugin. In order to do this, the package must be added as a dependency to your Swift package or Xcode project (see [Installation](#installation) above).

To provide a configuration for the plugin to use, place a `.sourcery.yml` file at the root of the target's directory (in the sources folder rather than the root of the package).

#### Running from the command line

To verify the plugin can be found by SwiftPM, use:

```
$ swift package plugin --list
```

To run the code generator, you need to allow changes to the project with the `--allow-writing-to-package-directory` flag:

```
$ swift package --allow-writing-to-package-directory sourcery-command
```

#### Running in Xcode

Inside a project/package that uses this command plugin, right-click the project and select "SourceryCommand" from the "SourceryPlugins" menu group.

> ⚠️ Note that this is only available from Xcode 14 onwards.

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
- `--cacheBasePath` - Base path to the cache directory. Can be overriden by the config file.
- `--buildPath` - Path to directory used when building from .swifttemplate files. This defaults to system temp directory

### Configuration file

Instead of CLI arguments, you can use a `.sourcery.yml` configuration file:

```yaml
sources:
  - <sources path>
  - <sources path>
templates:
  - <templates path>
  - <templates path>
forceParse:
  - <string value>
  - <string value>
output:
  <output path>
args:
  <name>: <value>
```

Read more about this configuration file [here](https://krzysztofzablocki.github.io/Sourcery/usage.html#configuration-file).

## Issues
If you get an unverified developer warning when using binary zip distribution try:
`xattr -dr com.apple.quarantine Sourcery-1.1.1`

## Contributing

Contributions to Sourcery are welcomed and encouraged!

It is easy to get involved. Please see the [Contributing guide](CONTRIBUTING.md) for more details.

[A list of contributors is available through GitHub](https://github.com/krzysztofzablocki/Sourcery/graphs/contributors).

To clarify what is expected of our community, Sourcery has adopted the code of conduct defined by the Contributor Covenant. This document is used across many open source communities, and articulates my values well. For more, see the [Code of Conduct](CODE_OF_CONDUCT.md).

## Sponsoring

If you'd like to support Sourcery development you can do so through [GitHub Sponsors](https://github.com/sponsors/krzysztofzablocki) or [Open Collective](https://opencollective.com/sourcery), it's highly appreciated 🙇‍

If you are a company and would like to sponsor the project directly and get it's logo here, you can [contact me directly](mailto:krzysztof.zablocki@pixle.pl?subject=[Sourcery-Sponsorship]) 

[![Bumble Inc L Logo](https://github.com/krzysztofzablocki/Sourcery/assets/1468993/159e0943-c890-42b7-9de7-9de9e70dd720)
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="1200" zoomAndPan="magnify" viewBox="0 0 900 209.999996" height="280" preserveAspectRatio="xMidYMid meet" version="1.0"><path fill="#4e4833" d="M 59.578125 80.644531 C 46.0625 80.644531 33.609375 87.773438 28 97.832031 L 28 44.007812 C 27.894531 41.652344 26.894531 39.40625 25.1875 37.777344 C 23.480469 36.152344 21.222656 35.230469 18.875 35.230469 C 16.53125 35.230469 14.25 36.152344 12.566406 37.777344 C 10.859375 39.40625 9.855469 41.652344 9.75 44.007812 L 9.75 163.8125 C 9.855469 166.164062 10.859375 168.414062 12.566406 170.039062 C 14.269531 171.664062 16.53125 172.585938 18.875 172.585938 C 21.222656 172.585938 23.503906 171.664062 25.1875 170.039062 C 26.894531 168.414062 27.894531 166.164062 28 163.8125 L 28 155.785156 C 33.160156 165.910156 46.082031 172.972656 59.578125 172.972656 C 82.394531 172.972656 102.753906 154.480469 102.753906 126.808594 C 102.753906 99.136719 82.457031 80.644531 59.578125 80.644531 Z M 56.59375 156.683594 C 42.203125 156.683594 28 145.234375 28 126.742188 C 27.894531 122.890625 28.578125 119.0625 29.964844 115.464844 C 31.347656 111.871094 33.4375 108.59375 36.105469 105.8125 C 38.769531 103.03125 41.945312 100.828125 45.484375 99.308594 C 49.003906 97.789062 52.800781 96.976562 56.636719 96.929688 C 72.605469 96.929688 85.078125 108.550781 85.078125 126.871094 C 85.078125 145.191406 72.628906 156.8125 56.636719 156.8125 " fill-opacity="1" fill-rule="nonzero"/><path fill="#4e4833" d="M 422.324219 80.644531 C 408.808594 80.644531 396.375 87.769531 390.746094 97.828125 L 390.746094 44.003906 C 390.746094 41.585938 389.789062 39.253906 388.082031 37.519531 C 386.375 35.808594 384.050781 34.84375 381.621094 34.84375 C 379.191406 34.84375 376.886719 35.808594 375.160156 37.519531 C 373.457031 39.234375 372.496094 41.566406 372.496094 44.003906 L 372.496094 163.8125 C 372.496094 166.25 373.457031 168.5625 375.160156 170.296875 C 376.867188 172.027344 379.191406 172.96875 381.621094 172.96875 C 384.050781 172.96875 386.355469 172.007812 388.082031 170.296875 C 389.789062 168.582031 390.746094 166.25 390.746094 163.8125 L 390.746094 155.785156 C 395.90625 165.90625 408.828125 172.96875 422.324219 172.96875 C 445.136719 172.96875 465.5 154.480469 465.5 126.808594 C 465.5 99.136719 445.136719 80.644531 422.324219 80.644531 Z M 419.339844 156.683594 C 404.945312 156.683594 390.726562 145.234375 390.726562 126.742188 C 390.640625 122.890625 391.300781 119.058594 392.6875 115.484375 C 394.074219 111.890625 396.164062 108.617188 398.828125 105.855469 C 401.492188 103.074219 404.671875 100.867188 408.1875 99.347656 C 411.707031 97.828125 415.5 97.015625 419.339844 96.953125 C 435.308594 96.953125 447.761719 108.574219 447.761719 126.894531 C 447.761719 145.210938 435.308594 156.832031 419.339844 156.832031 " fill-opacity="1" fill-rule="nonzero"/><path fill="#4e4833" d="M 189.382812 83.105469 C 186.976562 83.105469 184.652344 84.070312 182.945312 85.800781 C 181.238281 87.515625 180.28125 89.847656 180.257812 92.265625 L 180.257812 123.363281 C 180.257812 145.382812 170.089844 155.957031 154.4375 155.957031 C 141.796875 155.957031 133.542969 146.261719 133.542969 132.007812 L 133.542969 92.265625 C 133.542969 89.847656 132.582031 87.515625 130.878906 85.78125 C 129.171875 84.070312 126.847656 83.105469 124.417969 83.105469 C 121.988281 83.105469 119.683594 84.070312 117.957031 85.78125 C 116.25 87.492188 115.292969 89.828125 115.292969 92.265625 L 115.292969 135.796875 C 115.292969 157.820312 129.171875 172.96875 150.21875 172.96875 C 163.03125 172.96875 175.632812 165.800781 180.214844 155.785156 L 180.214844 163.8125 C 180.324219 166.164062 181.324219 168.410156 183.03125 170.039062 C 184.734375 171.664062 186.996094 172.585938 189.34375 172.585938 C 191.6875 172.585938 193.96875 171.664062 195.675781 170.039062 C 197.378906 168.410156 198.382812 166.164062 198.488281 163.8125 L 198.488281 92.265625 C 198.488281 89.828125 197.53125 87.515625 195.800781 85.78125 C 194.074219 84.070312 191.773438 83.105469 189.34375 83.105469 " fill-opacity="1" fill-rule="nonzero"/><path fill="#4e4833" d="M 323.070312 80.644531 C 308.679688 80.644531 296.867188 86.722656 290.597656 98.171875 C 285.78125 87.472656 274.117188 80.644531 261.644531 80.644531 C 255.886719 80.773438 250.28125 82.421875 245.398438 85.4375 C 240.492188 88.457031 236.484375 92.714844 233.753906 97.808594 L 233.753906 92.289062 C 233.648438 89.933594 232.644531 87.6875 230.941406 86.058594 C 229.234375 84.433594 226.976562 83.511719 224.628906 83.511719 C 222.285156 83.511719 220.003906 84.433594 218.296875 86.058594 C 216.589844 87.6875 215.589844 89.933594 215.484375 92.289062 L 215.484375 163.8125 C 215.589844 166.164062 216.589844 168.414062 218.296875 170.039062 C 220.003906 171.664062 222.261719 172.585938 224.628906 172.585938 C 226.996094 172.585938 229.257812 171.664062 230.941406 170.039062 C 232.644531 168.414062 233.648438 166.164062 233.753906 163.8125 L 233.753906 127.148438 C 233.753906 107.589844 242.878906 97.550781 256.910156 97.550781 C 268.148438 97.550781 276.570312 105.664062 276.570312 118.503906 L 276.652344 163.789062 C 276.761719 166.144531 277.761719 168.390625 279.46875 170.015625 C 281.175781 171.644531 283.433594 172.5625 285.800781 172.5625 C 288.167969 172.5625 290.429688 171.644531 292.113281 170.015625 C 293.816406 168.390625 294.820312 166.144531 294.925781 163.789062 L 294.839844 127.128906 C 294.839844 107.566406 304.136719 97.53125 318.359375 97.53125 C 329.574219 97.53125 338.019531 105.640625 338.019531 118.484375 L 337.824219 163.769531 C 337.933594 166.121094 338.933594 168.371094 340.640625 169.996094 C 342.347656 171.621094 344.605469 172.542969 346.953125 172.542969 C 349.296875 172.542969 351.578125 171.621094 353.285156 169.996094 C 354.988281 168.371094 355.992188 166.121094 356.097656 163.769531 L 356.097656 114.78125 C 356.097656 94.191406 341.171875 80.601562 323.09375 80.601562 Z M 323.070312 80.644531 " fill-opacity="1" fill-rule="nonzero"/><path fill="#4e4833" d="M 519.8125 161.585938 C 519.339844 159.53125 518.082031 157.753906 516.335938 156.597656 C 514.585938 155.441406 512.449219 155.015625 510.382812 155.398438 C 509.363281 155.570312 508.339844 155.679688 507.3125 155.679688 C 500.660156 155.679688 496.097656 151.460938 496.097656 145.46875 L 496.097656 44.003906 C 496.097656 41.585938 495.140625 39.253906 493.433594 37.519531 C 491.730469 35.808594 489.402344 34.84375 486.976562 34.84375 C 484.542969 34.84375 482.242188 35.808594 480.511719 37.519531 C 478.8125 39.234375 477.847656 41.566406 477.847656 44.003906 L 477.847656 146.367188 C 477.828125 153.367188 480.558594 160.066406 485.441406 165.050781 C 490.324219 170.039062 496.976562 172.882812 503.925781 172.96875 C 507.484375 173.035156 511.027344 172.519531 514.433594 171.472656 C 516.375 170.851562 518.015625 169.523438 519.019531 167.726562 C 520.023438 165.949219 520.320312 163.851562 519.875 161.863281 L 519.8125 161.605469 Z M 519.8125 161.585938 " fill-opacity="1" fill-rule="nonzero"/><path fill="#4e4833" d="M 609.761719 125.867188 C 608.355469 112.832031 601.34375 80.644531 566.609375 80.644531 C 542.046875 80.644531 521.515625 99.15625 521.515625 126.976562 C 521.515625 154.800781 542.171875 172.96875 565.90625 172.96875 C 581.046875 172.96875 593.792969 167.339844 602.046875 156.105469 C 602.683594 155.226562 603.132812 154.246094 603.390625 153.214844 C 603.644531 152.167969 603.6875 151.078125 603.515625 150.027344 C 603.34375 148.957031 602.984375 147.953125 602.429688 147.03125 C 601.875 146.113281 601.148438 145.320312 600.273438 144.675781 C 599.402344 144.035156 598.421875 143.585938 597.398438 143.328125 C 596.355469 143.074219 595.261719 143.03125 594.222656 143.179688 C 593.15625 143.351562 592.152344 143.714844 591.234375 144.269531 C 590.320312 144.828125 589.507812 145.554688 588.886719 146.433594 C 582.769531 155.078125 574.28125 157.132812 565.90625 157.132812 C 553.09375 157.132812 541.339844 147.460938 539.59375 131.214844 L 605.007812 131.214844 C 605.6875 131.214844 606.355469 131.066406 606.96875 130.789062 C 607.589844 130.511719 608.144531 130.101562 608.59375 129.609375 C 609.035156 129.097656 609.378906 128.519531 609.589844 127.855469 C 609.808594 127.191406 609.867188 126.527344 609.785156 125.84375 L 609.785156 125.886719 Z M 540.105469 118.140625 C 541.386719 112.0625 544.710938 106.625 549.550781 102.75 C 554.394531 98.878906 560.425781 96.824219 566.609375 96.953125 C 578.527344 96.953125 588.550781 103.992188 591.34375 118.269531 Z M 540.105469 118.140625 " fill-opacity="1" fill-rule="nonzero"/><path fill="#4e4833" d="M 666.289062 60.828125 C 666.289062 67.460938 661.28125 72.296875 654.5 72.296875 C 647.722656 72.296875 642.539062 67.460938 642.539062 60.828125 C 642.539062 54.558594 647.550781 49.164062 654.5 49.164062 C 661.449219 49.164062 666.289062 54.535156 666.289062 60.828125 Z M 645.226562 163.769531 L 645.226562 93.230469 C 645.226562 88.15625 649.339844 84.027344 654.394531 84.027344 C 659.59375 84.027344 663.796875 88.265625 663.796875 93.464844 L 663.796875 163.511719 C 663.796875 168.734375 659.570312 172.949219 654.394531 172.949219 C 649.339844 172.949219 645.226562 168.839844 645.226562 163.746094 Z M 645.226562 163.769531 " fill-opacity="1" fill-rule="nonzero"/><path fill="#4e4833" d="M 764.6875 119.167969 L 764.6875 163.511719 C 764.6875 168.710938 760.488281 172.949219 755.289062 172.949219 C 750.128906 172.949219 745.925781 168.753906 745.925781 163.554688 L 745.925781 122.933594 C 745.925781 108.402344 737.523438 98.730469 724.839844 98.730469 C 708.933594 98.730469 698.402344 109.496094 698.402344 131.902344 L 698.402344 163.53125 C 698.402344 168.734375 694.199219 172.949219 689.015625 172.949219 C 683.945312 172.949219 679.832031 168.820312 679.832031 163.726562 L 679.832031 93.25 C 679.832031 88.15625 683.945312 84.027344 689.015625 84.027344 C 694.199219 84.027344 698.402344 88.242188 698.402344 93.445312 L 698.402344 94.960938 C 705.546875 86.359375 715.90625 81.523438 729.125 81.523438 C 750.382812 81.523438 764.667969 96.933594 764.667969 119.167969 Z M 764.6875 119.167969 " fill-opacity="1" fill-rule="nonzero"/><path fill="#4e4833" d="M 854.855469 139.734375 C 860.398438 141.191406 863.257812 147.566406 860.335938 152.511719 C 852.832031 165.265625 838.375 172.972656 822.214844 172.972656 C 797.398438 172.972656 776.417969 154.542969 776.417969 127 C 776.417969 99.457031 797.398438 81.03125 822.214844 81.03125 C 838.054688 81.03125 852.40625 88.84375 860.1875 101.660156 C 863.085938 106.457031 860.488281 112.726562 855.109375 114.289062 L 854.367188 114.503906 C 850.464844 115.636719 846.457031 113.730469 844.496094 110.136719 C 839.910156 101.789062 831.574219 97.851562 822.214844 97.851562 C 806.140625 97.851562 794.238281 109.792969 794.238281 126.980469 C 794.238281 144.164062 806.117188 156.105469 822.214844 156.105469 C 831.703125 156.105469 839.996094 152.320312 844.984375 143.949219 C 847.035156 140.503906 850.976562 138.707031 854.832031 139.710938 Z M 854.855469 139.734375 " fill-opacity="1" fill-rule="nonzero"/><path fill="#4e4833" d="M 893.855469 161.476562 C 893.855469 167.941406 889.035156 172.949219 882.234375 172.949219 C 875.429688 172.949219 870.441406 167.917969 870.441406 161.476562 C 870.441406 155.378906 875.453125 150.175781 882.234375 150.175781 C 889.011719 150.175781 893.855469 155.378906 893.855469 161.476562 Z M 893.855469 161.476562 " fill-opacity="1" fill-rule="nonzero"/></svg>](https://team.bumble.com/teams/engineering)

[![airbnb](https://github.com/krzysztofzablocki/Sourcery/assets/1468993/b1c06e1c-06da-4a77-a4f1-7dabd02bbaba)](https://airbnb.io/)

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
