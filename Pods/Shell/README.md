# 🧪 Shell

Shell is a µ-library written Swift to run shell tasks.

[![CircleCI](https://circleci.com/gh/tuist/shell.svg?style=svg)](https://circleci.com/gh/tuist/shell)
[![Swift Package Manager](https://img.shields.io/badge/swift%20package%20manager-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Release](https://img.shields.io/github/release/tuist/shell.svg)](https://github.com/tuist/shell/releases)
[![Code Coverage](https://codecov.io/gh/tuist/shell/branch/master/graph/badge.svg)](https://codecov.io/gh/tuist/shell)
[![Slack](http://slack.tuist.io/badge.svg)](http://slack.tuist.io/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/tuist/shell/blob/master/LICENSE.md)

## Install 🛠

### Swift Package Manager

Add the dependency in your `Package.swift` file:

```swift
let package = Package(
    name: "myproject",
    dependencies: [
        .package(url: "https://github.com/tuist/shell.git", .upToNextMajor(from: "2.0.3")),
        ],
    targets: [
        .target(
            name: "myproject",
            dependencies: ["shell"]),
        ]
)
```

### CocoaPods

Add the following line to your project Podfile:

```ruby
pod "Shell", "2.0.3"
```

### Carthage

Add the following line to your project Cartfile:

```ruby
github "tuist/shell" "2.0.3"
```

### Marathon

If you want to use Shell in a [Marathon](https://github.com/johnsundell/marathon) script, either add it to your `Marathonfile` (see the Marathon repo for instructions on how to do that), or point Marathon to Shell using the inline dependency syntax:

```swift
import Shell // https://github.com/tuist/shell.git
```

## Usage 🚀

To run commands in the system, you need to create an instance of `Shell`:

```swift
let shell = Shell()
```

Shell exposes methods for running the commands synchronously, asynchronously, and capturing the output:

```swift
// Synchronous running
let result = shell.sync(["xcodebuild", "-project", "Shell", "-scheme", "Shell"])

// Asynchronous running
shell.async(["xcodebuild", "-project", "Shell", "-scheme", "Shell"]) { result in
  // Process the result
})

// Capturing output
let result = shell.capture(["xcode-select", "-p"])
```

## Testing ✅

We understand how inconvenient testing might be in Swift and thus, we designed Shell's API to facilitate testing by avoiding many syntactic sugar and static interfaces. The library comes with a library, `ShellTesting` that you can import in your tests target to mock the `Shell` interface and stub the result of running commands:

```swift
import ShellTesting

let mock = Shell.mock()
let xcodebuild = XcodeBuild(shell: mock)

shell.succeed(["xcodebuild", "-project", "Shell.xcodeproj", "-scheme", "Shell"])

XCTAssertNoThrow(try xcodebuild.build(project: "Shell.xcodeproj", scheme: "Shell"))
```

## Setup for development 👩‍💻

1.  Git clone: `git@github.com:tuist/shell.git`
2.  Generate Xcode project with `swift package generate-xcodeproj`.
3.  Open `Shell.xcodeproj`.
4.  Have fun 🤖

## Open source

Tuist is a proud supporter of the [Software Freedom Conservacy](https://sfconservancy.org/)

<a href="https://sfconservancy.org/supporter/"><img src="https://sfconservancy.org/img/supporter-badge.png" width="194" height="90" alt="Become a Conservancy Supporter!" border="0"/></a>
