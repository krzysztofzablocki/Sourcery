[![CircleCI](https://circleci.com/gh/krzysztofzablocki/Sourcery.svg?style=shield)](https://circleci.com/gh/krzysztofzablocki/Sourcery)
[![codecov](https://codecov.io/gh/krzysztofzablocki/Sourcery/branch/master/graph/badge.svg)](https://codecov.io/gh/krzysztofzablocki/Sourcery)
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

- [What is Sourcery?](#what-is-sourcery)
- [Why?](#why)
- [Examples](#examples)
- [Writing templates](#writing-templates)
  - [Custom Stencil tags and filter](#custom-stencil-tags-and-filter)
  - [Using Source Annotations](#using-source-annotations)
    - [Rules:](#rules)
    - [Format:](#format)
    - [Accessing in templates:](#accessing-in-templates)
  - [Inline code generation](#inline-code-generation)
  - [Per file code generation](#per-file-code-generation)
- [Installing](#installing)
- [Usage](#usage)
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

## Examples

<details>
<summary>I want to generate `Equatable` implementation</summary>

Template used to generate equality for all types that conform to `:AutoEquatable`, allowing us to avoid writing boilerplate code.

It adds `:Equatable` conformance to all types, except protocols (because it would require turning them into PAT's).
For protocols it's just generating `func ==`.

#### [Stencil template](Templates/AutoEquatable.stencil)

#### Available variable annotations:

- `skipEquality` allows you to skip variable from being compared.
- `arrayEquality` mark this to use array comparsion for variables that have array of items that don't implement `Equatable` but have `==` operator e.g. Protocols

#### Example output:

```swift
// MARK: - AdNodeViewModel AutoEquatable
extension AdNodeViewModel: Equatable {}

internal func == (lhs: AdNodeViewModel, rhs: AdNodeViewModel) -> Bool {
    guard lhs.remoteAdView == rhs.remoteAdView else { return false }
    guard lhs.hidesDisclaimer == rhs.hidesDisclaimer else { return false }
    guard lhs.type == rhs.type else { return false }
    guard lhs.height == rhs.height else { return false }

    guard lhs.attributedDisclaimer == rhs.attributedDisclaimer else { return false }

    return true
}
```
</details>

<details>
<summary>I want to generate `Hashable` implementation</summary>

Template used to generate hashing for all types that conform to `:AutoHashable`, allowing us to avoid writing boilerplate code.

It adds `:Hashable` conformance to all types, except protocols (because it would require turning them into PAT's).
For protocols it's just generating `var hashValue` comparator.

#### [Stencil template](Templates/AutoHashable.stencil)

#### Available variable annotations:

- `skipHashing` allows you to skip variable from being compared.
- `includeInHashing` is only applied on enums and allows us to add some computed variable into hashing logic

#### Example output:

```swift
// MARK: - AdNodeViewModel AutoHashable
extension AdNodeViewModel: Hashable {

    internal var hashValue: Int {
        return combineHashes(remoteAdView.hashValue, hidesDisclaimer.hashValue, type.hashValue, height.hashValue, attributedDisclaimer.hashValue, 0)
    }
}
```

</details>

<details>
<summary>I want to list all cases in an enum</summary>

Generate `count` and `allCases` for any enumeration that is marked with `AutoCases` phantom protocol.

#### [Stencil Template](Templates/AutoCases.stencil)

#### Example output:

```swift
extension BetaSettingsGroup {
  static var count: Int { return 8 }

  static var allCases: [BetaSettingsGroup] {
    return [
      .featuresInDevelopment,
      .advertising,
      .analytics,
      .marketing,
      .news,
      .notifications,
      .tech,
      .appInformation
    ]
  }
}
```

</details>

<details>
<summary>I want to generate test mocks for protocols</summary>

_Contributed by [@marinbenc](http://twitter.com/marinbenc)_

#### For each protocol implementing `AutoMockable` it will...
Create a class called `ProtocolNameMock` in which it will...

**For each function:**
 - Implement the function
 - Add a `functionCalled` boolean to check if the function was called
 - Add a `functionRecievedArguments` tuple to check the arguments that were passed to the function
 - Add a `functionReturnValue` variable and return it when the function is called.

**For each variable:**
 - Add a gettable and settable variable with the same name and type

#### Issues and limitations:
* Overloaded methods will produce compiler erros since the variables above the functions have the same name. Workaround: delete the variables on top of one of the functions, or rename them.
* Handling success/failure cases (for callbacks) is tricky to do automatically, so you have to do that yourself.
* This is **not** a full replacement for hand-written mocks, but it will get you 90% of the way there. Any more complex logic than changing return types, you will have to implement yourself. This only removes the most boring boilerplate you have to write.

#### [Stencil template](Templates/AutoMockable.stencil)

#### Example output:

```swift
class MockableServiceMock: MockableService {
    //MARK: - functionWithArguments
    var functionWithArgumentsCalled = false
    var functionWithArgumentsRecievedArguments: (firstArgument: String, onComplete: (String)-> Void)?

    //MARK: - functionWithCallback
    var functionWithCallbackCalled = false
    var functionWithCallbackRecievedArguments: (firstArgument: String, onComplete: (String)-> Void)?

    func functionWithCallback(_ firstArgument: String, onComplete: @escaping (String)-> Void) {
        functionWithCallbackCalled = true
        functionWithCallbackRecievedArguments = (firstArgument: firstArgument, onComplete: onComplete)
    }
  ...
```
</details>

<details>
<summary>I want to generate Lenses for all structs</summary>

_Contributed by [@filip_zawada](http://twitter.com/filip_zawada)_

What are Lenses? Great explanation by @mbrandonw

This script assumes you follow swift naming convention, e.g. structs start with an upper letter.

#### [Stencil template](Templates/AutoLenses.stencil)

#### Example output:

```swift
extension House {

  static let roomsLens = Lens<House, Room>(
    get: { $0.rooms },
    set: { rooms, house in
       House(rooms: rooms, address: house.address, size: house.size)
    }
  )
  static let addressLens = Lens<House, String>(
  get: { $0.address },
  set: { address, house in
     House(rooms: house.rooms, address: address, size: house.size)
    }
  )
  ...
```
</details>

<details>
<summary>I want to have diffing in tests</summary>

Template used to generate much better output when using equality in tests, instead of having to read wall of text it's used to generate precise property level differences. This template uses [Sourcery Diffable implementation](../../Sourcery/Models/Diffable.swift)

from this:
<img width="600" alt="before" src="https://cloud.githubusercontent.com/assets/1468993/21425370/0e3dd990-c849-11e6-877a-6dc80ae8f039.png">

to this:
<img width="373" alt="after" src="https://cloud.githubusercontent.com/assets/1468993/21425376/11e9ad94-c849-11e6-882a-e7927a3b2b08.png">


#### [Stencil Template](Sourcery/Templates/Diffable.stencil)

#### Available annotations:

- `skipEquality` allows you to skip variable from being compared.
</details>

<details>
<summary>I want to generate `LinuxMain.swift` for all my tests</summary>

For all test cases generates `allTests` static variable and passes all of them as `XCTestCaseEntry` to `XCTMain`. Run with `--args testimports='import MyTests'` parameter to import test modules.

#### [Stencil template](Templates/LinuxMain.stencil)

#### Available annotations:

- `disableTests` allows you to disable the whole test case.

#### Example output:

```swift
import XCTest
//testimports

extension AutoInjectionTests {
  static var allTests = [
    ("testThatItResolvesAutoInjectedDependencies", testThatItResolvesAutoInjectedDependencies),
    ...
  ]
}

extension AutoWiringTests {
  static var allTests = [
    ("testThatItCanResolveWithAutoWiring", testThatItCanResolveWithAutoWiring),
    ...
  ]
}

...

XCTMain([
  testCase(AutoInjectionTests.allTests),
  testCase(AutoWiringTests.allTests),
  ...
])

```

</details>

## Writing templates

Sourcery supports several types of templates:

- [Stencil](https://github.com/kylef/Stencil) templates
- [Swift](https://github.com/krzysztofzablocki/Sourcery/blob/master/SourceryTests/Stub/SwiftTemplates/Equality.swifttemplate) templates
- [JavaScript](https://github.com/krzysztofzablocki/Sourcery/blob/master/SourceryTests/Stub/JavaScriptTemplates/Equality.js) templates (using [EJS](http://ejs.co))

Make sure you leverage Sourcery built-in daemon to make writing templates a pleasure:
you can open template side-by-side with generated code and see it change live.

There are multiple ways to access your types:

- `type.TypeName` => access specific type by name
- `types.all` => all types, excluding protocols
- `types.classes`
- `types.structs`
- `types.enums`
- `types.protocols` => lists all protocols (that were defined in the project)
- `types.inheriting.BaseClass` => lists all types inherting from known BaseClass (only those that were defined in source code that Sourcery scanned)
- `types.implementing.Protocol` => lists all types conforming to given Protocol (only those that were defined in source code that Sourcery scanned)
- `types.based.BaseClassOrProtocol` => lists all types implementing or inheriting from `BaseClassOrProtocol` (all type names encountered, even those that Sourcery didn't scan)

All of these properties return `Type` objects.

<details><summary>**What are _known_ and _unknown_ types**</summary>

Currently Sourcery only scans files from a directory that you tell it to scan. This way it can get full information about types _defined_ in these sources. These types are considered _known_ types. For each of known types Sourcery provides `Type` object. You can get it for example by its name from `types` collection. `Type` object contains information about whether type that it describes is a struct, enum, class or a protocol, what are its properties and methods, what protocols it implements and so on. This is done recursively, so if you have a class that inherits from another class (or struct that implements a protocol) and they are both known types you will have information about both of them and you will be able to access parent type's `Type` object using `type.inherits.TypeName` (or `type.implements.ProtocolName`).

Everything _defined_ outside of scanned sources is considered as _unknown_ types. For such types Sourcery doesn't provide `Type` object. For that reason variables (and other "typed" types, like method parameters etc.) of such types will only contain `typeName` property, but their `type` property will be `nil`. 

If you have an extension of unknown type defined in scanned sources Sourcery will create `Type` for it (it's `kind` property will be `extension`). But this object will contain only declarations defined in this extension. Several extensions of unknown type will be merged into one `Type` object the same way as extensions of known types.

See #87 for details.
</details>

Available types:

<details><summary>**Type**. Properties:</summary>

- `name` <- name
- `kind` <- convience accessor that will contain one of `enum`, `class`, `struct`, `protocol`, it will also provide `extension` for types that are unknown to us(e.g. 3rd party or objc), but had extension in the project
- `isGeneric` <- info whether the type is generic
- `localName` <- name within parent scope
- `variables` <- list of all variables defined in this type, excluding variables from protocols or inheritance
  - if you want to access all available variables, including those from inherited / protocol, then use `allVariables`
  - if you want to accces computed, stored, instance, or static variables, you can do so using our [custom filters](#custom-stencil-tags-and-filter) on both `variables` and `allVariables`
- `methods` <- list of all methods defined in this type, excluding those from protocols or inheritance
- `allMethods` <- same principles as in `allVariables`
- `initializers` <- list of all initializers
- `inherits.BaseClass` => if type is a class and it inherits from a known class named `BaseClass` this property returns `Type` object for `BaseClass`, otherwise returns `nil`
- `implements.Protocol` => if type implements a known protocol named `Protocol` this property returns `Type` object for `Protocol`, otherwise returns `nil`
- `based.BaseClassOrProtocol` => if type either implements a protocol or inherits from a class named `BaseClassOrProtocol` this property returns `BaseClassOrProtocol` itself, otherwise returns `nil`. All type names encountered, even those that Sourcery didn't scan
- `containedTypes` <- list of types contained within this type
- `parentName` <- list of parent type (for contained ones)
- `attributes` <- type attributes, i.e. `type.attributes.objc`
- `annotations` <- dictionary with configured [annotations](#source-annotations)

</details>

<details><summary> **Enum**. Built on top of `Type` and provides some additional properties:</summary>

- `rawType` <- enum raw type
- `cases` <- list of `Enum.Case`
- `hasAssociatedValues` <- true if any of cases has associated values

</details>

<details><summary>**EnumCase**. Properties:</summary>

- `name` <- name
- `rawValue` <- raw value
- `associatedValues` <- list of `AssociatedValue`
- `annotations` <- dictionary with configured [annotations](#source-annotations)

</details>

<details><summary>**AssociatedValue**. Properties:</summary>

- `localName` <- name to use to construct value, i.e. `value` in `Foo.foo(value: ...)`
- `externalName` <- name to use when binding value, i.e. `value` or `other` in `enum Foo { case foo(value: ..., other: ... )}`. Will use index as a fallback
- `typeName` <- name of type of associated value (*TypeName*)
- `actualTypeName` <- returns `typeName.actualTypeName` or if it's `nil` returns `typeName`
- `unwrappedTypeName` <- shorthand for `typeName.unwrappedTypeName`
- `isOptional` <- shorthand for `typeName.isOptional`
- `isImplicitlyUnwrappedOptional` <- shorthand for `typeName. isImplicitlyUnwrappedOptional `
- `isTuple` <- shorthand for `typeName.isTuple`
- `isClosure` <- shorthand for `typeName.isClosure`
- `isArray` <- shorthand for `typeName.isArray`

</details>

<details><summary>**Variable**. Properties:</summary>

- `name` <- Name
- `type` <- type of the variable, if known
- `typeName` <- returns name of the type (*TypeName*)
- `actualTypeName` <- returns `typeName.actualTypeName` or if it's `nil` returns `typeName`
- `unwrappedTypeName` <- shorthand for `typeName.unwrappedTypeName`
- `isOptional` <- shorthand for `typeName.isOptional`
- `isImplicitlyUnwrappedOptional` <- shorthand for `typeName. isImplicitlyUnwrappedOptional `
- `isComputed` <- whether is computed
- `isStatic` <- whether is static variable
- `isTuple` <- shorthand for `typeName.isTuple`
- `isClosure` <- shorthand for `typeName.isClosure`
- `isArray` <- shorthand for `typeName.isArray`
- `readAccess` <- what is the protection access for reading?
- `writeAccess` <- what is the protection access for writing?
- `attributes` <- variable attributes, i.e. `var.attributes.NSManaged`
- `annotations` <- dictionary with configured [annotations](#source-annotations)

</details>

<details><summary>**Method**. Properties:</summary>

- `name` <- full name of the method including generic constraints, i.e. `func foo(bar: Bar)` or `foo<T>(bar: T)`
- `selectorName` <- selector name of the method, i.e for `func foo(bar: Bar) -> Bar` it is `foo(bar:)`, for `func foo<T>(bar: T)` it is `foo(bar:)`
- `shortName` <- short method name, i.e. for `func foo(bar: Bar) -> Bar` it is `foo`, for `func foo<T>(bar: T)` it is `foo<T>`
- `parameters` <- list of all method parameters
- `returnType` <- return type, if known, for initializers - containing type
- `returnTypeName` <- return type name (*TypeName*). Will be `Void` for methods without return value or empty string for initializers. For generic methods can include generic constraints specified with `where`, i.e. `func foo<T>(bar: T) -> T where T: Equatable` it is `T where T: Equatable`
- `actualReturnTypeName` <- returns `returnTypeName.actualTypeName` or if it's `nil` returns `returnTypeName`
- `unwrappedReturnTypeName` <- shorthand for `returnTypeName.unwrappedTypeName`
- `isOptionalReturnType` <- shorthand for `returnTypeName.isOptional`
- `isImplicitlyUnwrappedOptionalReturnType` <- shorthand for `returnTypeName. isImplicitlyUnwrappedOptional`
- `accessLevel` <- method access level
- `isStatic` <- whether method is static
- `isClass` <- whether method is class (can be overriden by subclasses)
- `isInitializer` <- whether method is an initializer
- `isFailableInitializer` <- whether method is failable initializer
- `attributes` <- method attributes, i.e. `method.attributes.discardableResult`
- `annotations` <- dictionary with configured [annotations](#source-annotations)

</details>

<details><summary>**MethodParameter**. Properties:</summary>

- `name` <- parameter name
- `argumentLabel` <- argument label (external name), if not set will be eqal to `name`
- `type` <- type of parameter, if known
- `typeName` <- parameter type name (*TypeName*)
- `actualTypeName` <- returns `typeName.actualTypeName` or if it's `nil` returns `typeName`
- `unwrappedTypeName` <- shorthand for `typeName.unwrappedTypeName`
- `isOptional` <- shorthand for `typeName.isOptional`
- `isImplicitlyUnwrappedOptional` <- shorthand for `typeName. isImplicitlyUnwrappedOptional `
- `isTuple` <- shorthand for `typeName.isTuple`
- `isClosure` <- shorthand for `typeName.isClosure`
- `isArray` <- shorthand for `typeName.isArray`
- `typeAttributes` <- parameter's type attributes, shorthand for `typeName.attributes`, i.e. `param.typeAttributes.escaping`

</details>

<details><summary>**TypeName**. Properties:</summary>

- `name` <- type name
- `actualTypeName` <- if given type is a typealias or contained type name will contain actual fully qualified type name
- `unwrappedTypeName` <- returns name of the type, unwrapping the optional e.g. for variable with type `Int?` this would return `Int`, removing attributes and generic constraints
- `isOptional` <- whether is optional
- `isImplicitlyUnwrappedOptional` <- whether is implicitly unwrapped optional
- `isVoid` <- whether type is Void (`Void` or `()`)
- `isTuple` <- whether given type is a tuple
- `tuple` <- returns information about tuple type (*TupleType*) based on `actualTypeName.unwrappedTypeName`
- `isClosure` <- shorthand for `typeName.isClosure`
- `isArray` <- shorthand for `typeName.isArray`
- `attributes` <- type attributes, i.e. `typeName.attributes.escaping`

</details>

<details><summary>**TupleType**. Properties:</summary>

- `name` <- type name
- `elements` <- returns tuple elements information (*TupleElement*)

</details>

<details><summary>**TupleElement**. Properties:</summary>

- `name` <- element name
- `type` <- type of element, if known
- `typeName` <- element type name (*TypeName*)
- `unwrappedTypeName` <- shorthand for `typeName.unwrappedTypeName`
- `isOptional` <- shorthand for `typeName.isOptional`
- `isTuple` <- shorthand for `typeName.isTuple`
- `isClosure` <- shorthand for `typeName.isClosure`

</details>

<details><summary>**ArrayType**. Properties:</summary>

- `name` <- type name
- `elementType` <- array element type, if known
- `elementTypeName` <- array element type name (*TypeName*)

</details>

### Custom Stencil tags and filter

- `{{ name|upperFirst }}` - makes first letter in `name` uppercase
- `{{ name|replace:"substring","replacement" }}` - replaces occurances of `substring` with `replacement` in `name` (case sensitive)
- `{% if name|contains:"Foo" %}` - check if `name` contains arbitrary substring, can be negated with `!` prefix.
- `{% if name|hasPrefix:"Foo" %}`- check if `name` starts with arbitrary substring, can be negated with `!` prefix.
- `{% if name|hasSuffix:"Foo" %}`- check if `name` ends with arbitrary substring, can be negated with `!` prefix.
- `static`, `instance`, `computed`, `stored`, `tuple` - can be used on Variable[s] as filter e.g. `{% for var in variables|instance %}`, can be negated with `!` prefix.
- `static`, `instance`, `class`, `initializer` - can be used on Method[s] as filter e.g. `{% for method in allMethods|instance %}`, can be negated with `!` prefix.
- `enum`, `class`, `struct`, `protocol` - can be used for Type[s] as filter, can be negated with `!` prefix.
- `based`, `implements`, `inherits` - can be used for Type[s], Variable[s], Associated value[s], can be negated with `!` prefix.
- `count` - can be used to get count of filtered array
- `annotated` - can be used on Type[s], Variable[s], Method[s] and Enum Case[s] to filter by annotation, e.g. `{% for var in variable|annotated: \"skipDescription\"%}`, can be negated with `!` prefix.

### Using Source Annotations

Sourcery supports annotating your classes and variables with special annotations, similar how attributes work in Rust / Java

```swift
/// sourcery: skipPersistence
/// Some documentation comment
/// sourcery: anotherAnnotation = 232, yetAnotherAnnotation = "value"
/// Documentation
var precomputedHash: Int
```

If you want to attribute multiple items with same attributes, you can use section annotations:
```swift
/// sourcery:begin: skipEquality, skipPersistence
  var firstVariable: Int
  var secondVariable: Int
/// sourcery:end
```

#### Rules:

- Multiple annotations can occur on the same line
- You can add multiline annotations
- You can interleave annotations with documentation
- Sourcery scans all `sourcery:` annotations in the given comment block above the source until first non-comment/doc line

#### Format:

- simple entry, e.g. `sourcery: skipPersistence`
- key = number, e.g. `sourcery: another = 123`
- key = string, e.g. `sourcery: jsonKey = "json_key"`

#### Accessing in templates:

```swift
{% ifnot variable.annotations.skipPersistence %}
  var local{{ variable.name|capitalize }} = json["{{ variable.annotations.jsonKey }}"] as? {{ variable.typeName }}
{% endif %}
```

#### Checking for existance of at least one annotation:

Sometimes it is desirable to only generate code if there's at least one field annotated.

```swift
{% if type.variables|annotated:"jsonKey" %}{% for var in type.variables|instance|annotated:"jsonKey" %}
  var local{{ var.name|capitalize }} = json["{{ var.annotations.jsonKey }}"] as? {{ var.typeName }}
{% endfor %}{% endif %}
```

### Inline code generation

Sourcery supports inline code generation, you just need to put same markup in your code and template, e.g.

```swift
// in template:

{% for type in types.all %}
// sourcery:inline:{{ type.name }}.TemplateName
// sourcery:end
{% endfor %}

// in source code:

class MyType {

// sourcery:inline:MyType.TemplateName
// sourcery:end

}
```

Sourcery will generate the template code and then perform replacement in your source file. Inlined generated code is not parsed to avoid chicken-egg problem.

### Per file code generation

Sourcery supports generating code in a separate file per type, you just need to put `file` annotation in a template, e.g.

```swift
{% for type in types.all %}
// sourcery:file:Generated/{{ type.name}}+TemplateName
// sourcery:end
{% endfor %}
```

Sourcery will generate the template code and then write its annotated parts to corresponding files. In example above it will create `Generated/<type name>+TemplateName.generated.swift` file for each of scanned types.

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
Sourcery is a command line tool `sourcery`:
```
$ ./sourcery <source> <templates> <output> [--args arg1=value,arg2]
```
Arguments:

- source - Path to a source swift files.
- templates - Path to templates. File or Directory.
- output - Path to output. File or Directory.
- args - Additional arguments to pass to templates. Each argument can have explicit value or will have implicit `true` value. Arguments should be separated with `,` without spaces. Arguments are accessible in templates via `argument.name`

Options:

- `--watch` [default: false] - Watch both code and template folders for changes and regenerate automatically.
- `--verbose` [default: false] - Turn on verbose logging for ignored entities

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
