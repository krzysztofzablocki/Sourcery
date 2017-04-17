[![CircleCI](https://circleci.com/gh/krzysztofzablocki/Sourcery.svg?style=shield)](https://circleci.com/gh/krzysztofzablocki/Sourcery)
[![codecov](https://codecov.io/gh/krzysztofzablocki/Sourcery/branch/master/graph/badge.svg)](https://codecov.io/gh/krzysztofzablocki/Sourcery)
[![docs](https://cdn.rawgit.com/krzysztofzablocki/Sourcery/master/docs/badge.svg)](https://cdn.rawgit.com/krzysztofzablocki/Sourcery/master/docs/index.html)
[![Version](https://img.shields.io/cocoapods/v/Sourcery.svg?style=flat)](http://cocoapods.org/pods/Sourcery)
[![License](https://img.shields.io/cocoapods/l/Sourcery.svg?style=flat)](http://cocoapods.org/pods/Sourcery)
[![Platform](https://img.shields.io/cocoapods/p/Sourcery.svg?style=flat)](http://cocoapods.org/pods/Sourcery)

## What is Sourcery?
_**Sourcery** scans your source code, applies your personal templates and generates Swift code for you, allowing you to use meta-programming techniques to save time and decrease potential mistakes._

<img src="Resources/icon-128.png">

Using it offers many benefits:

- Write less repetitive code and make it easy to adhere to [DRY principle](https://en.wikipedia.org/wiki/Don't_repeat_yourself).
- It allows you to create better code, one that would be hard to maintain without it, e.g. [performing automatic property level difference in tests](https://github.com/krzysztofzablocki/Sourcery/blob/master/Sourcery/Templates/Diffable.stencil)
- Limits the risk of introducing human error when refactoring.
- Sourcery **doesn't use runtime tricks**, in fact, it allows you to leverage compiler, even more, creating more safety.
- **Immediate feedback:** Sourcery features built-in daemon support, enabling you to write your templates in real-time side-by-side with generated code.

![Daemon demo](Resources/daemon.gif)

**Sourcery is so meta that it is used to code-generate its boilerplate code**

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Why?](#why)
- [Installing](#installing)
- [Usage](#usage)
  - [Command line options](#command-line-options)
  - [Configuration file](#configuration-file)
  - [Features](#features)
- [Contributing](#contributing)
- [License](#license)
- [Attributions](#attributions)
- [Other Libraries / Tools](#other-libraries--tools)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Why?

Swift features very limited runtime and no meta-programming features. Which leads our projects to contain boilerplate code.

Sourcery exists to allow Swift developers to stop doing the same thing over and over again while still maintaining strong typing, preventing bugs and leveraging compiler.

Have you ever?

- Had to write equatable/hashable?
- Had to write NSCoding support?
- Had to implement JSON serialization?
- Wanted to use Lenses?

If you did then you probably found yourself writing repetitive code to deal with those scenarios, does this feel right?

Even worse, if you ever add a new property to a type all of those implementations have to be updated, or you will end up with bugs.
In those scenarios usually **compiler will not generate the error for you**, which leads to error prone code.

## Installing

<details>
<summary>Binary form</summary>
The easiest way to download the tool right now is to just grab a newest `.zip` distribution from [releases tab](https://github.com/krzysztofzablocki/Sourcery/releases).
</details>

<details>
<summary>Via CocoaPods</summary>
If you're using CocoaPods, you can simply add pod 'Sourcery' to your Podfile.

This will download the Sourcery binaries and dependencies in `Pods/`.
You just need to add `$PODS_ROOT/Sourcery/bin/sourcery {source} {templates} {output}` in your Script Build Phases.
</details>

<details>
<summary>Via Swift Package Manager</summary>
If you're using SwiftPM, you can simply add 'Sourcery' to your manifest.

Sourcery is placed in `Packages`.
After your first `swift build`, you can run `.build/debug/sourcery {source} {templates} {output}`.
</details>

<details>
<summary>From Source</summary>
You can clone it from the repo and just run `Sourcery.xcworkspace`.
</details>

## Usage

Sourcery is a command line tool `sourcery`, you can either run it manually or in a custom build phase using following command:

```
$ ./sourcery --sources <sources path> --templates <templates path> --output <output path> [--args arg1=value,arg2]
```

### Command line options

- `--sources` - Path to a source swift files. You can provide multiple paths using multiple `--sources` option.
- `--templates` - Path to templates. File or Directory. You can provide multiple paths using multiple `--templates` options.
- `--output` - Path to output. File or Directory. Default is current path.
- `--config` - Path to config file. Directory. Default is current path.
- `--args` - Additional arguments to pass to templates. Each argument can have explicit value or will have implicit `true` value. Arguments should be separated with `,` without spaces. Arguments are accessible in templates via `argument.name`
- `--watch` [default: false] - Watch both code and template folders for changes and regenerate automatically.
- `--verbose` [default: false] - Turn on verbose logging for ignored entities
- `--disableCache` [default: false] - Turn off caching of parsed data
- `--prune` [default: false] - Prune empty generated files

### Configuration file

You can also provide arguments using `.sourcery.yml` file in project's root directory, like this:

```yaml
sources:
  - <sources path>
  - <sources path>
templates:
  - <templates path>
  - <templates path>
output:
  <output path>
args:
  <name>: <value>
```

You can provide either sources paths or targets to scan:

```yaml
project:
  file:
    <path to xcodeproj file>
  root:
    <path to project sources root>
  target:
    name: <target name>
    module: <module name> //required if different from target name
```

You can use several `project` or `target` objects to scan multiple targets from one project or to scan multiple projects.

### Features

- Stencil, Swift, JavaScript templates
- Watch mode
- Source annotations
- Inline and per file code generation

For more information please read [DOCUMENTATION](https://cdn.rawgit.com/krzysztofzablocki/Sourcery/master/docs/index.html).

## Contributing

Contributions to Sourcery are welcomed and encouraged!

It is easy to get involved. Please see the [Contributing guide](CONTRIBUTING.md) for more details.

[A list of contributors is available through GitHub.](https://github.com/krzysztofzablocki/Sourcery/graphs/contributors)

To give clarity of what is expected of our community, Sourcery has adopted the code of conduct defined by the Contributor Covenant. This document is used across many open source communities, and I think it articulates my values well. For more, see the [Code of Conduct](CODE_OF_CONDUCT.md).

## License

Sourcery is available under the MIT license. See [LICENSE](LICENSE) for more information.

## Attributions

This tool is powered by

- [SourceKitten](https://github.com/jpsim/SourceKitten) by [JP Simard](https://github.com/jpsim)
- [Stencil](https://github.com/kylef/Stencil) and few other libs by [Kyle Fuller](https://github.com/kylef)

Thank you! for:

- [Mariusz Ostrowski](http://twitter.com/faktory) for creating the logo.
- [Artsy Eidolon](https://github.com/artsy/eidolon) team, because we use their codebase as a stub data for performance testing the parser.
- [Olivier Halligon](https://github.com/AliSoftware) for showing me his setup scripts for CLI tools which are powering our rakefile.

## Other Libraries / Tools

If you want to generate code for asset related data like .xib, .storyboards etc. use [SwiftGen](https://github.com/AliSoftware/SwiftGen). SwiftGen and Sourcery are complementary tools.

Make sure to check my other libraries and tools, especially:
- [KZPlayground](https://github.com/krzysztofzablocki/KZPlayground) - Powerful playgrounds for Swift and Objective-C
- [KZFileWatchers](https://github.com/krzysztofzablocki/KZFileWatchers) - Daemon for observing local and remote file changes, used for building other developer tools (Sourcery uses it)

You can [follow me on twitter][1] for news/updates about other projects I am creating.

 [1]: http://twitter.com/merowing_
