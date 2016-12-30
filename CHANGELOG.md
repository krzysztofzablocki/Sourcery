# Sourcery CHANGELOG

---
## Master

### New Features
- You can now pass arbitrary values to templates with `--args` argument.
- Added `open` access level
- Type `inherits` and `implements` now allow you to access full type information, not just name
- Type `allVariables` will now include all variables, including those inherited from supertype and known protocols.
- New Available stencil filters:
  - `static`, `instance`, `computed`, `stored` for Variables
  - `enum`, `class`, `struct`, `protocol` for Types
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
