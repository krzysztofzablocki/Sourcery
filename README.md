[![CI Status](http://img.shields.io/travis/krzysztofzablocki/Insanity.svg?style=flat)](https://travis-ci.org/krzysztofzablocki/Insanity)
[![codecov](https://codecov.io/gh/krzysztofzablocki/Insanity/branch/master/graph/badge.svg)](https://codecov.io/gh/krzysztofzablocki/Insanity)
[![Version](https://img.shields.io/cocoapods/v/Insanity.svg?style=flat)](http://cocoapods.org/pods/Insanity)
[![License](https://img.shields.io/cocoapods/l/Insanity.svg?style=flat)](http://cocoapods.org/pods/Insanity)
[![Platform](https://img.shields.io/cocoapods/p/Insanity.svg?style=flat)](http://cocoapods.org/pods/Insanity)

<img style="float: left;" src="Resources/icon-256.png">

### What is Insanity?
> Doing the same thing over and over again and expecting different results.

Swift is a beautiful language that powers a lot of great iOS apps. Unfortunately it features very limited runtime and no meta-programming features.
This has led our projects to contain a lot of duplicated code patterns, they can be considered the same code, just with minimal variations.
<br><br>

Have you ever?

- Had to write NSCoding support?
- Had to implement JSON serialization?
- Wanted value types to be equatable and hashable?
- Used enum to wrap decoupled types?

If you did then you probably found yourself writing a lot of repetitive code to deal with those scenarios, does this feel right?

Even worse, if you ever add a new property to a type all of those implementations have to be updated, or you'll end up with bugs.
In those scenarios usually **compiler won't generate the error for you**, which leads to error prone code.

_**Insanity** is a tool that scans your source code, applies your personal templates and generates Swift code for you, allowing you to use meta-programming techniques to save time and decrease potential mistakes._

- Scans your project code.
- Allows your templates to access information about project types.
- Generates swift code.
- **Immediate feedback:** Insanity features built-in daemon support, allowing you to write your templates in real-time side-by-side with generated code.

There are multiple benefits in using Insanity approach:

- Write less boilerplate code and make it easy adhere to [DRY principle](https://en.wikipedia.org/wiki/Don't_repeat_yourself)
- Avoid the risk of forgetting to update boilerplate when refactoring
- Gives you meta-programming powers, while still allowing the compiler to ensure everything is correct.
- **Insanity is so crazy that it uses itself to code-generate boilerplate**

Daemon mode in action:

![Daemon demo](Resources/daemon.gif)

How everything connects:

```bash

                                   +--------------+
         Scans code to build AST   |              |  Generates new code
      +---------------------------->   INSANITY   +--------------------------------+
      |                            |              |                                |
      |                            +--^--------^--+                                |
      |                               |        |                                   |
      |                               |        | Reads templates                   |
      |                               |        |                                   |
+-----+------+       +----------------+--+  +--+----------------+        +---------v---------+
|            |       |                   |  |                   |        |                   |
|   Source   |       | Equality Template |  | NSCoding Template |        |  Generated Swift  |
|            |       |                   |  |                   |        |                   |
+-----^------+       +-------------------+  +-------------------+        +-------------------+
      |                                                                            |
      |                                                                            |
      |                                                                            |
      +----------------------------------------------------------------------------+
                              Compiled into your project

```

## Examples

##### Use case: `I want to know how many elements are in each enum`
Template:
```swift
{% for enum in types.enums %}
extension {{ enum.name }} {
  static var count: Int { return {{ enum.cases.count }} }
}
{% endfor %}
```

Result:

```swift
extension AdType {
  static var count: Int { return 2 }
}
```

----

##### Use case: `I want to generate Equality for types implementing specific protocol.'

Template:

```swift
{% for type in types.implementing.AutoEquatable %}
extension {{ type.name }}: Equatable {}

func == (lhs: {{ type.name }}, rhs: {{ type.name }}) -> Bool {
    {% for variable in type.storedVariables %} if lhs.{{ variable.name }} != rhs.{{ variable.name }} { return false }
    {% endfor %}
    return true
}
{% endfor %}
```

Result:
```swift
extension AccountSectionConfiguration: Equatable {}

func == (lhs: AccountSectionConfiguration, rhs: AccountSectionConfiguration) -> Bool {
     if lhs.status != rhs.status { return false }
     if lhs.user != rhs.user { return false }
     if lhs.entitlements != rhs.entitlements { return false }

    return true
}
```

##### Use case: `I want to list all computed variables in a given type.'

Template:

```swift
{% for variable in type.VideoViewModel.computedVariables %} {{ variable.name }}: {{ variable.type }}
{% endfor %}
```

Result:
```swift
attributedTitle: NSAttributedString
attributedKicker: NSAttributedString
attributedHeadline: NSAttributedString
attributedSummary: NSAttributedString
```
## Writing templates
*Insanity templates are powered by [Stencil](https://github.com/kylef/Stencil)*

Make sure you leverage Insanity built-in daemon to make writing templates a pleasure:
you can open template side-by-side with generated code and see it change live.

There are multiple ways to access your types:

- `type.TypeName` => access specific type by name
- `types.all` => all types, excluding protocols
- `types.classes`
- `types.structs`
- `types.enums`
- `types.protocols` => lists all protocols (that were defined in the project)
- `types.inheriting.BaseClassOrProtocol` => lists all types inheriting from given BaseClass or implementing given Protocol
- `types.implementing.BaseClassOrProtocol` => convience alias that works exactly the same as `.inheriting`

For each type you can access following properties:

- `name`
- `localName` <- name within parent scope
- `staticVariables` <- list of static variables
- `variables` <- list of instance variables
- `computedVariables` <- list of computed instance variables
- `storedVariables` <- list of computed stored variables
- `inheritedTypes` <- list of type names that this type implements / inherits
- `containedTypes` <- list of types contained within this type
- `parentName` <- list of parent type (for contained ones)

**Enum** types builts on top of regular types and adds:

- `rawType` <- enum raw type
- `cases` <- list of `Enum.Case`

**Enum.Case** provides:

- `name` <- name
- `rawValue` <- raw value
- `associatedValues` <- list of `AssociatedValue`

**Enum.Case.AssociatedValue** provides:

- `name` <- name
- `type` <- type of associated value

# Installing

## Installation

<details>
<summary>Via CocoaPods</summary>
If you're using CocoaPods, you can simply add pod 'Insanity' to your Podfile.

This will download the Insanity binaries and dependencies in `Pods/`.
You just need to add `$PODS_ROOT/Insanity/bin/insanity {source} {templates} {output}` in your Script Build Phases.
</details>

<details>
<summary>From Source</summary>
You can clone it from the repo and just run `Insanity.xcworkspace`.
</details>

## Usage
Insanity is a command line tool `Insanity`:
```
$ ./insanity <source> <templates> <output>
```
Arguments:

- source - Path to a source swift files.
- templates - Path to templates. File or Directory.
- output - Path to output. File or Directory.

Options:

- `--watch` [default: false] - Watch template for changes and regenerate as needed. Only works with specific template path (not directory).
- `--verbose` [default: false] - Turn on verbose logging for ignored entities

## Contributing

Contributions to Insanity are welcomed and encouraged!

Please see the [Contributing guide](CONTRIBUTING).

[A list of contributors is available through GitHub.](https://github.com/krzysztofzablocki/Insanity/graphs/contributors)

To give clarity of what is expected of our community, Insanity has adopted the code of conduct defined by the Contributor Covenant. This document is used across many open source communities, and I think it articulates my values well. For more, see the [Code of Conduct](CODE_OF_CONDUCT).

## License

Insanity is available under the MIT license. See [LICENSE](LICENSE) for more information.

# Attributions

This tool is powered by

- [SourceKitten](https://github.com/jpsim/SourceKitten) by [JP Simard](https://github.com/jpsim)
- [Stencil](https://github.com/kylef/Stencil) and few other libs by [Kyle Fuller](https://github.com/kylef)

[Olivier Halligon](https://github.com/AliSoftware) pointed me to few of his setup scripts for CLI tools, very helpful, thank you!

# Other Libraries / Tools

If you want to generate code for asset related logic, I highly recommend [SwiftGen](https://github.com/AliSoftware/SwiftGen)

Make sure to check my other libraries and tools, especially:
- [KZPlayground](https://github.com/krzysztofzablocki/KZPlayground) - Powerful playgrounds for Swift and Objective-C
- [KZFileWatchers](https://github.com/krzysztofzablocki/KZFileWatchers) - Daemon for observing local and remote file changes, used for building other developer tools (Insanity uses it)

You can [follow me on twitter][7] for news / updates about other projects I'm creating.

 [2]: http://foldifyapp.com
 [7]: http://twitter.com/merowing_
