# KZFileWatchers

![Demo GIF](Images/Demo.gif)


[![CI Status](http://img.shields.io/travis/krzysztofzablocki/KZFileWatchers.svg?style=flat)](https://travis-ci.org/krzysztofzablocki/KZFileWatchers)
[![Version](https://img.shields.io/cocoapods/v/KZFileWatchers.svg?style=flat)](http://cocoapods.org/pods/KZFileWatchers)
[![License](https://img.shields.io/cocoapods/l/KZFileWatchers.svg?style=flat)](http://cocoapods.org/pods/KZFileWatchers)
[![Platform](https://img.shields.io/cocoapods/p/KZFileWatchers.svg?style=flat)](http://cocoapods.org/pods/KZFileWatchers)

Wouldn't it be great if we could adjust feeds and configurations of our native apps without having to sit back to Xcode, change code, recompile and navigate back to screen we were at?

One of the basis of building tools that allow us to do just that is the way we observe for data changes, this micro-framework provides you File observers for Local and Remote assets.

This framework provides:

- `FileWatcher.Local` useful for observing local file changes, it can also be used to breach Sandbox env for debug simulator builds and e.g. observe file on the developer desktop (like the demo app does).

- `FileWatcher.Remote` can be used to observe files on the web, it supports both `Etag` headers and `Last-Modified-Date` so you can just put file on Dropbox or real ftp server.

## Installation

KZFileWatchers is available through [CocoaPods](http://cocoapods.org) and [Swift Package Manager](http://github.com/apple/swift-package-manager).

### CocoaPods

In order to install KZFileWatchers by using CocoaPods, simply add the following line to your Podfile:

```ruby
pod "KZFileWatchers"
```

Last version to support Swift 2.3 is `0.1.2`

### Swift Package Manager

Installing KZFileWatchers over SwiftPM is only supported since version 1.0.1. You just need to add it as a dependency to your Package.swift manifest:

```swift
import PackageDescription

let package = Package(
    name: "YourTarget",
    dependencies: [
        .Package(url: "https://github.com/krzysztofzablocki/KZFileWatchers.git", majorVersion: 1),
    ]
)
```

## Author

Krzysztof Zabłocki, krzysztof.zablocki@pixle.pl

## Contributing

Contributions to KZFileWatchers are welcomed and encouraged! Please see the [Contributing guide](https://github.com/krzysztofzablocki/KZFileWatchers/blob/master/CONTRIBUTING.md).

[A list of contributors is available through GitHub.](https://github.com/krzysztofzablocki/KZFileWatchers/graphs/contributors)

To give clarity of what is expected of our members, KZFileWatchers has adopted the code of conduct defined by the Contributor Covenant. This document is used across many open source communities. For more, see the [Code of Conduct](https://github.com/krzysztofzablocki/KZFileWatchers/blob/master/CODE_OF_CONDUCT.md).

## License

KZFileWatchers is available under the MIT license. See [LICENSE](https://github.com/krzysztofzablocki/KZFileWatchers/blob/master/LICENSE) for more information.
