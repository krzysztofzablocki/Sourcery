# Sourcery CHANGELOG

---

## 0.9.0

### New Features

- Added support for file paths in `config` parameter
- Added `isDeinitializer` property for methods
- Improved config file validation and error reporting
- Various improvements for `AutoMockable` template:
  - support methods with reserved keywords name
  - support methods that throws
  - improved generated declarations names

### Bug fixes

- Fixed single file generation not skipping writing the file when there is no generated content

### Internal changes

- Updated dependencies for Swift 4
- Update internal ruby dependencies

## 0.8.0

### New Features

- Added support in `AutoHashable` for static variables, `[Hashable]` array and `[Hashable: Hashable]` dictionary
- Added `definedInType` property for `Method` and `Variable`
- Added `extensions` filter for stencil template
- Added include support in Swift templates
- Swift templates now can throw errors. You can also throw just string literals.
- Added support for TypeName in string filters (except filters from StencilSwiftKit).

### Bug fixes

- Fixed linker issue when using Swift templates
- Updated `AutoMockable` to exclude generated code collisions
- Fixed parsing of default values for variables that also have a body (e.g. for `didSet`)
- Fixed line number display when an error occur while parsing a Swift template
- Fixed `rsync` issue on `SourceryRuntime.framework` when using Swift templates
- Fixed `auto:inline` for nested types (this concerns the first time the code is inserted)

### Internal changes

- Fix link for template in docs
- Fix running Sourcery in the example app
- Add step to update internal boilerplate code during the release


## 0.7.2

### Internal changes

- Add Version.swift to represent CLI tool version


## 0.7.1

### Bug fixes

- Fixed regression in parsing templates from config file
- Removed meaningless `isMutating` property for `Variable`

### Internal changes

- Improvements in release script
- Updated boilerplate code to reflect latest changes


## 0.7.0

### New Features

- Added `inout` flag for `MethodParameter`
- Added parsing `mutating` and `final` attributes with convenience `isMutating` and `isFinal` properties
- Added support for `include` Stencil tag
- Added support for excluded paths

### Bug fixes

- Fixed inserting generated code inline automatically at wrong position
- Fixed regression in AutoEquatable & AutoHashable template with private computed variables

### Internal changes

- Internal release procedure improvements
- Improved `TemplatesTests` scheme running
- Fixed swiftlint warnings (version 0.19.0)


## 0.6.1

### New Features

- Paths in config file are now relative to config file path by default, absolute paths should start with `/`
- Improved logging and error reporting, added `--quiet` CLI option, added runtime errors for using invalid types in `implementing` and `inheriting`
- Added support for includes in EJS templates (for example: `<%- include('myTemplate.js') %>`)
- Add the `lowerFirst` filter for Stencil templates.
- Added `isRequired` property for `Method`
- Improved parsing of closure types
- Check if Current Project Version match version in podspec in release task
- Improved swift templates performance
- Added `// sourcery:file` annotation for source code

### Bug fixes

- Fixed detecting computed properties
- Fixed typo in `isConvenienceInitialiser` property
- Fixed creating cache folder when cache is disabled
- Fixed parsing multiple enum cases annotations
- Fixed parsing inline annotations when there is an access level or attribute
- Fixed parsing `required` attribute
- Fixed typo in `guides/Writing templates.md`

### Internal changes

- Improved `AutoMockable.stencil` to support protocols with `init` methods
- Improved `AutoCases.stencil` to use `let` instead of computed `var`
- Updated StencilSwiftKit to 1.0.2 which includes Stencil 0.9.0
- Adding docset to release archive
- Add tests for bundled stencil templates
- Moved to CocoaPods 1.2.1
- Made Array.parallelMap's block non-escaping


## 0.6.0

### New Features

- Added some convenience accessors for classic, static and instance methods, and types and contained types grouped by names

## 0.6

### New Features

- Added support for inline code generation without requiring explicit `// sourcery:inline` comments in the source files. To use, use `sourcery:inline:auto` in a template: `// sourcery:inline:auto:MyType.TemplateName`
- Added `isMutable` property for `Variable`
- Added support for scanning multiple targets
- Added access level filters and disabled filtering private declarations
- Added support for inline comments for annotations with `/*` and `*/`
- Added annotations for enum case associated values and method parameters
- Added `isConvenienceInitializer` property for `Method`
- Added `defaultValue` for variables and method parameters
- Added docs generated with jazzy
- Sourcery now will not create empty files and will remove existing generated files with empty content if CLI flag `prune` is set to `true` (`false` by default)
- Sourcery now will remove inline annotation comments from generated code.
- Added `rethrows` property to `Method`
- Allow duplicated annotations to be agregated into array
- Added ejs-style tags to control whitespaces and new lines in swift templates
- Added CLI option to provide path to config file

### Bug Fixes

- Inserting multiple inline code block in one file
- Suppress warnings when compiling swift templates
- Accessing protocols in Swift templates
- Crash that would happen sometimes when parsing typealiases

### Internal changes

- Replaced `TypeReflectionBox` and `GenerationContext` types with common `TemplateContext`.

## 0.5.9

### New Features

- Added flag to check if `TypeName` is dictionary
- Added support for multiple sources and templates paths, sources, templates and output paths now should be provided with `--sources`, `--templates` and `--output` options
- Added support for YAML file configuration
- Added generation of non-swift files using `sourcery:file` annotation

### Bug Fixes

- Fixed observing swift and js templates
- Fixed parsing generic array types
- Fixed using dictionary in annotations

## 0.5.8

### New Features

- Added parsing array types
- Added support for JavaScript templates (using EJS)

### Bug Fixes

- Fixed escaping variables with reserved names
- Fixed duplicated methods and variables in `allMethods` and `allVariables`
- Fixed trimming attributes in type names

## 0.5.7

### Bug Fixes
- Cache initial file contents, including the inline generated ranges so that they are always up to date

## 0.5.6

### New Features

- Added per file code generation

### Bug Fixes

- Fixed parsing annotations with complex content
- Fixed inline parser using wrong caching logic

## 0.5.5

### New Features

- Sourcery will no longer write files if content didn't change, this improves behaviour of things depending on modification date like Xcode, Swiftlint.

### Internal changes

- Improved support for contained types

### Bug Fixes

- Fixes cache handling that got broken in 0.5.4

## 0.5.4

### New Features

- Added inline code generation
- Added `isClosure` property to `TypeName` to detect closure types

### Bug Fixes

- Fixed parsing of associated values separater by newlines
- Fixed preserving order of inherited types
- Improved support for throwing methods in protocols
- Fixed extracting parameters of methods with closures in their bodies
- Fixed extracting method return types of tuple types
- Improved support for typealises as tuple elements types
- Method parameters with `_` argument label will now have `nil` in `argumentLabel` property
- Improved support for generic methods
- Improved support for contained types

### Internal changes

- adjusted internal templates and updated generated code
- moved methods parsing related tests in a separate spec

## 0.5.3

### New Features
- Added support for method return types with `throws` and `rethrows`
- Added a new filter `replace`. Usage: `{{ name|replace:"substring","replacement" }}` - replaces occurrences of `substring` with `replacement` in `name` (case sensitive)
- Improved support for inferring types of variables with initial values
- Sourcery is now bundling a set of example templates, you can access them in Templates folder.
- We now use parallel parsing and cache source artifacts. This leads to massive performance improvements:
- e.g. on big codebase of over 300 swift files:
```
Sourcery 0.5.2
Processing time 8.69941002130508 seconds

Sourcery 0.5.3
First time 4.69904798269272 seconds
Subsequent time: 0.882099032402039 seconds
```

### Bug Fixes
- Method `accessLevel` was not exposed as string so not accessible properly via templates, fixed that.
- Fixes on Swift Templates

## 0.5.2

### New Features

- Added support for `ImplicitlyUnwrappedOptional`
- `actualTypeName` property of `Method.Parameter`, `Variable`, `Enum.Case.AssociatedValue`, `TupleType.Element` now returns `typeName` if type is not a type alias
- `Enum` now contains type information for its raw value type. `rawType` now return `Type` object, `rawTypeName` returns its `TypeName`
- Added `annotated` filter to filter by annotations
- Added negative filters counterparts
- Added support for attributes, i.e. `@escaping`
- Experimental support for Swift Templates

- Swift Templates are now supported

```
<% for type in types.classes { %>
    extension <%= type.name %>: Equatable {}

    <% if type.annotations["showComment"] != nil { %> // <%= type.name %> has Annotations <% } %>

        func == (lhs: <%= type.name %>, rhs: <%= type.name %>) -> Bool {
    <% for variable in type.variables { %> if lhs.<%= variable.name %> != rhs.<%= variable.name %> { return false }
        <% } %>
        return true
    }
<% } %>
```

### 0.5.1

### New Features
- Variables with default initializer are now supported, e.g. `var variable = Type(...)`
- Added support for special escaped names in enum cases e.g. `default` or `for`
- Added support for tuple types and `tuple` filter for variables
- Enum associated values now have `localName` and `externalName` properties.
- Added `actualTypeName` for `TypeName` that is typealias
- Added `implements`, `inherits` and `based` filters

### Bug Fixes
- Using protocols doesn't expose variables using KVC, which meant some of the typeName properties weren't accessible via Templates, we fixed that using Sourcery itself to generate specific functions.
- Fixed parsing typealiases for tuples and closure types
- Fixed parsing associated values of generic types

### Internal Changes
- Performed significant refactoring and simplified mutations in parsers

## 0.5.0
- You can now pass arbitrary values to templates with `--args` argument.
- Added `open` access level
- Type `inherits` and `implements` now allow you to access full type information, not just name
- Type `allVariables` will now include all variables, including those inherited from supertype and known protocols.
- Type `allMethods` will now include all methods, including those inherited from supertype and known protocols.
- AssociatedValue exposes `unwrappedTypeName`, `isOptional`
- New Available stencil filters:
  - `static`, `instance`, `computed`, `stored` for Variables
  - `enum`, `class`, `struct`, `protocol` for Types
  - `class`, `initializer`, `static`, `instance` for Methods
  - `count` for Arrays, this is used when chaining arrays with filters where Stencil wouldn't allow us to do `.count`, e.g. `{{ variables|instance|count }}`
- Now you can avoid inferring unknown protocols as enum raw types by adding conformance in extension (instead of `enum Foo: Equatable {}` do `enum Foo {}; extension Foo: Equatable {}`)

### Internal changes
- Refactor code around typenames

## 0.4.9

### New Features
- Watch mode now works with folders, reacting to source-code changes and adding templates/source files.
- When using watch mode, status info will be displayed in the generated code so that you don't need to look at console at all.
- You can now access types of enum's associated values
- You can now access type's `methods` and `initializers`

## 0.4.8

### New Features
- You can now access `supertype` of a class
- Associated values will now automatically use idx as name if no name is provided

### Bug Fixes
- Fix dealing with multibyte characters
- `types.implementing` and `types.based` should include protocols that are based on other protocols

### Internal changes
- TDD Development is now easier thanks to Diffable results, no longer we need to scan wall of text on failures, instead we see exactly what's different.

## 0.4.7

### New Features
- Added `contains`, `hasPrefix`, `hasPrefix` filters

### Bug Fixes
- AccessLevel is now stored as string

## 0.4.6

### Bug Fixes
- Typealiases parsing could cause crash, implemented a workaround for that until we can find a little more reliable solution

## 0.4.5

### New Features

* Swift Package Manager support.

## 0.4.4

### New Features

* Enum cases also have annotation support

### Internal changes

* Improved handling of global and local typealiases.

## 0.4.3

### New Features
* Add upperFirst stencil filter

## 0.4.2

### Bug Fixes

* Fixes a bug with flattening `inherits`, `implements` for protocols implementing other protocols
* Improve `rawType` logic for Enums

### New Features

* Annotations can now be declared also with sections e.g. `sourcery:begin: attribute1, attribute2 = 234`
* Adds scanning class variables as static

### Internal changes

* Refactored models
* Improved performance of annotation scanning

## 0.4.1

### New Features

* Implements inherits, implements, based reflection on each Type
* Flattens inheritance, e.g. Foo implements Decodable, then FooSubclass also implements it

### Internal changes

* Stop parsing private variables as they wouldn't be accessible to code-generated code

## 0.4.0

### New Features

* improve detecting raw type
* add `isGeneric` property

## 0.3.9

### New Features

* Enables support for scanning extensions of unknown type, providing partial metadata via types.based or types.all reflection

## 0.3.8
### New Features

* Adds real type reflection into Variable, not only it's name
* Resolves known typealiases

## 0.3.7
### Bug Fixes

* Fixes a bug that caused Sourcery to drop previous type information when encountering generated code, closes #33

## 0.3.6
### Bug Fixes

* Fixes bug in escaping path
* Fixes missing protocol variant in kind


## 0.3.5

### New Features
* added support for type/variable source annotations
* added property kind to Type, it contains info whether this is struct, class or enum entry
* Automatically skips .swift files that were generated with Sourcery

### Internal changes

* improved detecting enums with rawType
