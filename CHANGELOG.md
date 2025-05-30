# Sourcery CHANGELOG

## 2.2.7
* Feature/typed throws support by @alexandre-pod in https://github.com/krzysztofzablocki/Sourcery/pull/1401
* Add missing `isGeneric` dynamic member by @tayloraswift in https://github.com/krzysztofzablocki/Sourcery/pull/1408

## 2.2.6 
* Method/Initializer parameter types now resolve to the local type if it exists by @liamnichols in https://github.com/krzysztofzablocki/Sourcery/pull/1347
* Fixed wrong relative path in symbolic link by @pavel-trafimuk in https://github.com/krzysztofzablocki/Sourcery/pull/1350
* chore: add unchecked Sendable conformance to AutoMockable by @nekrich in https://github.com/krzysztofzablocki/Sourcery/pull/1355
* Fixes issue around mutable capture of 'inout' parameter 'buffer' is not allowed in concurrently-executing code by @mapierce in https://github.com/krzysztofzablocki/Sourcery/pull/1363
* chore(deps): bump rexml from 3.2.8 to 3.3.6 by @dependabot in https://github.com/krzysztofzablocki/Sourcery/pull/1360
* Updated swift-syntax package's url (#1354) by @akhmedovgg in https://github.com/krzysztofzablocki/Sourcery/pull/1364
* `Templates/AutoMockable.stencil`: fix stencil to consider nullable closures as escaping by @alexdmotoc in https://github.com/krzysztofzablocki/Sourcery/pull/1358
* Fix AutoMockable for closure with multiple parameters by @MontakOleg in https://github.com/krzysztofzablocki/Sourcery/pull/1373
* fix: AutoEquatable Stencil to use `any` for protocols by @iDevid in https://github.com/krzysztofzablocki/Sourcery/pull/1367
* Add support for child configs by @jimmya in https://github.com/krzysztofzablocki/Sourcery/pull/1338
* Try to fix associated types messing up types unification by @fabianmuecke in https://github.com/krzysztofzablocki/Sourcery/pull/1377
* Added annotations to typealiases and typealiases property to EJS template context. by @fabianmuecke in https://github.com/krzysztofzablocki/Sourcery/pull/1379
* Fix module name for xcframework by @till0xff in https://github.com/krzysztofzablocki/Sourcery/pull/1381
* Fix protocol inheritance by @till0xff in https://github.com/krzysztofzablocki/Sourcery/pull/1383
* Fixed nested type resolution by @till0xff in https://github.com/krzysztofzablocki/Sourcery/pull/1384
* fix: Fixes description of Method's genericParameters by @sergiocampama in https://github.com/krzysztofzablocki/Sourcery/pull/1386
* Ability to use custom header prefix by @ilia3546 in https://github.com/krzysztofzablocki/Sourcery/pull/1389
* Fixed tests under linux by @art-divin in https://github.com/krzysztofzablocki/Sourcery/pull/1390
* chore(deps): bump rexml from 3.3.6 to 3.3.9 by @dependabot in https://github.com/krzysztofzablocki/Sourcery/pull/1376
* Fixing dockerfile by @art-divin in https://github.com/krzysztofzablocki/Sourcery/pull/1391

## 2.2.5
* chore(deps): bump nokogiri from 1.16.2 to 1.16.5 by @dependabot in https://github.com/krzysztofzablocki/Sourcery/pull/1331
* Fix typo in Decorator.md by @ahmedk92 in https://github.com/krzysztofzablocki/Sourcery/pull/1339
* chore(deps): bump rexml from 3.2.5 to 3.2.8 by @dependabot in https://github.com/krzysztofzablocki/Sourcery/pull/1332
* Fixed incorrect case prefix parsing by @art-divin in https://github.com/krzysztofzablocki/Sourcery/pull/1341
* Fixed crash when inline function has out of bound indexes by @art-divin in https://github.com/krzysztofzablocki/Sourcery/pull/1342
* Improved concurrency support in SwiftTemplate caching by @art-divin in https://github.com/krzysztofzablocki/Sourcery/pull/1344
* Fix associatedtype generics by @art-divin in https://github.com/krzysztofzablocki/Sourcery/pull/1345
* AutoMockable: fix generating static reset func by @MontakOleg in https://github.com/krzysztofzablocki/Sourcery/pull/1336
* Enabled lookup for generic type information in arrays by @art-divin in https://github.com/krzysztofzablocki/Sourcery/pull/1346

## 2.2.4
- Fixed typealias resolution breaking resolution of real types. by @fabianmuecke ([#1325](https://github.com/krzysztofzablocki/Sourcery/pull/1325))
- Disabled type resolving for local method generic parameters by @art-divin ([#1327](https://github.com/krzysztofzablocki/Sourcery/pull/1327))
- Added hideVersionHeader to configuration arguments by @art-divin ([#1328](https://github.com/krzysztofzablocki/Sourcery/pull/1328))

## 2.2.3
## Changes
- Fixed Issue when Caching of SwiftTemplate Binary Failes by @art-divin ([#1323](https://github.com/krzysztofzablocki/Sourcery/pull/1323))

## 2.2.2
## Changes
- Improved Logging/Error Handling during SwiftTemplate Processing by @art-divin ([#1320](https://github.com/krzysztofzablocki/Sourcery/pull/1320))

## 2.2.1
## Changes
- Set minimum platform for macOS by @art-divin ([#1319](https://github.com/krzysztofzablocki/Sourcery/pull/1319))

## 2.2.0
## Changes
- Remove Sourcery version from header by @dcacenabes in ([#1309](https://github.com/krzysztofzablocki/Sourcery/pull/1309))
- Enable Single Print when Generating Based on Swifttemplate by @art-divin in ([#1308](https://github.com/krzysztofzablocki/Sourcery/pull/1308))
- [Bug] Annotations aren't being extracted from initializers by @liamnichols in ([#1311](https://github.com/krzysztofzablocki/Sourcery/pull/1311))
- Implemented Proper Protocol Composition Type Parsing by @art-divin in ([#1314](https://github.com/krzysztofzablocki/Sourcery/pull/1314))
- Renamed parenthesis to parentheses by @art-divin in ([#1315](https://github.com/krzysztofzablocki/Sourcery/pull/1315))
- Switched to Double for CLI argument processing by @art-divin in ([#1317](https://github.com/krzysztofzablocki/Sourcery/pull/1317))
- Added isDistributed to Actor and Method by @art-divin in ([#1318](https://github.com/krzysztofzablocki/Sourcery/pull/1318))
- Enable Quotes when parsing arguments in property wrapper parameters by @art-divin in ([#1316](https://github.com/krzysztofzablocki/Sourcery/pull/1316))

## 2.1.8
## Changes
- ClosureParameter isVariadic Support by @art-divin in ([#1268](https://github.com/krzysztofzablocki/Sourcery/pull/1268))
- Update Usage.md to include --parseDocumentation option by @MarcoEidinger in ([#1272](https://github.com/krzysztofzablocki/Sourcery/pull/1272))
- Format processing time log message by @MontakOleg in ([#1274](https://github.com/krzysztofzablocki/Sourcery/pull/1274))
- Fixed swift-package-manager version by @art-divin in ([#1280](https://github.com/krzysztofzablocki/Sourcery/pull/1280))
- Added isSet to TypeName by @art-divin in ([#1281](https://github.com/krzysztofzablocki/Sourcery/pull/1281))
- chore(deps): bump nokogiri from 1.15.4 to 1.16.2 by @dependabot in ([#1273](https://github.com/krzysztofzablocki/Sourcery/pull/1273))
- Implement GenericRequirement support for member type disambiguation by @art-divin in ([#1283](https://github.com/krzysztofzablocki/Sourcery/pull/1283))
- Add generic requirements to Method by @art-divin in ([#1284](https://github.com/krzysztofzablocki/Sourcery/pull/1284))
- Recognize subclasses with generics by @art-divin in ([#1287](https://github.com/krzysztofzablocki/Sourcery/pull/1287))
- Implemented typealias unboxing during type resolution by @art-divin in ([#1288](https://github.com/krzysztofzablocki/Sourcery/pull/1288))
- Added documentation to typealias by @art-divin in ([#1289](https://github.com/krzysztofzablocki/Sourcery/pull/1289))
- Fix: Function with completion as parameter that contains itself an optional any parameter produces wrong mock by @paul1893 in ([#1290](https://github.com/krzysztofzablocki/Sourcery/pull/1290))
- Fix: Function with inout parameter when function has more than one parameter produces wrong mock by @paul1893 in ([#1291](https://github.com/krzysztofzablocki/Sourcery/pull/1291))
- Substitute underlying type from typealias by @art-divin in ([#1292](https://github.com/krzysztofzablocki/Sourcery/pull/1292))
- Added support for multiline documentation comments by @art-divin in ([#1293](https://github.com/krzysztofzablocki/Sourcery/pull/1293))
- Update SwiftSyntax dependency to 510.0.0 by @calda in ([#1294](https://github.com/krzysztofzablocki/Sourcery/pull/1294))
- Resolved all SwiftSyntax Warnings by @art-divin in ([#1295](https://github.com/krzysztofzablocki/Sourcery/pull/1295))
- Trailing Annotation Parsing by @art-divin in ([#1296](https://github.com/krzysztofzablocki/Sourcery/pull/1296))
- Fixed Crash in AnnotationParser by @art-divin in ([#1297](https://github.com/krzysztofzablocki/Sourcery/pull/1297))
- Disabled Optimization During Generated Code Verification by @art-divin in ([#1300](https://github.com/krzysztofzablocki/Sourcery/pull/1300))
- Adjusted file structure to accommodate two generated files by @art-divin in ([#1299](https://github.com/krzysztofzablocki/Sourcery/pull/1299))
- Expand --serialParse flag to also apply to Composer.uniqueTypesAndFunctions by @calda in ([#1301](https://github.com/krzysztofzablocki/Sourcery/pull/1301))
- Make AutoMockable Generate Compilable Swift Code by @art-divin in ([#1304](https://github.com/krzysztofzablocki/Sourcery/pull/1304))
- Fix Closure Parameter CVarArg with Existential by @art-divin in ([#1305](https://github.com/krzysztofzablocki/Sourcery/pull/1305))

## 2.1.7
## Changes
- Podspec updates - set correct filepath for Sourcery
- Fixed generated AutoMockable compilation issue due to generated variable names containing & character. Added support for existential any for throwable errors. ([#1263](https://github.com/krzysztofzablocki/Sourcery/pull/1263))

## 2.1.6
## Changes
- Podspec updates - set specific version per supported platform

## 2.1.5
## Changes
- Podspec updates
- Add support for inout parameter for AutoMockable protocols ([#1261](https://github.com/krzysztofzablocki/Sourcery/pull/1261))

## 2.1.4
## Changes
- Added generic requirements and generic parameters to Subscript ([#1242](https://github.com/krzysztofzablocki/Sourcery/issues/1242))
- Added isAsync and throws to Subscript ([#1249](https://github.com/krzysztofzablocki/Sourcery/issues/1249))
- Initialise Subscript's returnTypeName with TypeSyntax, not String ([#1250](https://github.com/krzysztofzablocki/Sourcery/issues/1250))
- Swifty generated variable names + fixed generated mocks compilation issues due to method generic parameters ([#1252](https://github.com/krzysztofzablocki/Sourcery/issues/1252))

## 2.1.3
## Changes
- Add support for `typealias`es in EJS templates. ([#1208](https://github.com/krzysztofzablocki/Sourcery/pull/1208))
- Add support for existential to Automockable Protocol with generic types. ([#1220](https://github.com/krzysztofzablocki/Sourcery/pull/1220))
- Add support for generic parameters and requirements in subscripts.
    ([#1242](https://github.com/krzysztofzablocki/Sourcery/pull/1242))
- Throw throwable error after updating mocks's calls counts and received parameters/invocations.
    ([#1224](https://github.com/krzysztofzablocki/Sourcery/pull/1224))
- Fix unit tests on Linux ([#1225](https://github.com/krzysztofzablocki/Sourcery/pull/1225))
- Updated XcodeProj to 8.16.0 ([#1228](https://github.com/krzysztofzablocki/Sourcery/pull/1228))
- Fixed Unable to mock a protocol with methods that differ in parameter type - Error: "Invalid redeclaration" ([#1238](https://github.com/krzysztofzablocki/Sourcery/issues/1238))
- Support for variadic arguments as method parameters ([#1222](https://github.com/krzysztofzablocki/Sourcery/issues/1222))

## 2.1.2
## Changes
- Bump SPM version to support Swift 5.9 ([#1213](https://github.com/krzysztofzablocki/Sourcery/pull/1213))
- Add Dockerfile ([#1211](https://github.com/krzysztofzablocki/Sourcery/pull/1211))

## 2.1.1
## Changes
- Separate EJSTemplate.swift for swift test and for swift build -c release ([#1203](https://github.com/krzysztofzablocki/Sourcery/pull/1203))

## 2.1.0
## Changes
- Added support for Swift Package Manager config ([#1184](https://github.com/krzysztofzablocki/Sourcery/pull/1184))
- Add support to any keyword for function parameter type to AutoMockable.stencil ([#1169](https://github.com/krzysztofzablocki/Sourcery/pull/1169))
- Add support to any keyword for function return type to AutoMockable.stencil([#1186](https://github.com/krzysztofzablocki/Sourcery/pull/1186))
- Add support for protocol compositions in EJS templates. ([#1192](https://github.com/krzysztofzablocki/Sourcery/pull/1192))
- Linux Support (experimental) ([#1188](https://github.com/krzysztofzablocki/Sourcery/pull/1188))
- Add support for opaque type (some keyword) to function parameter type in AutoMockable.stencil ([#1197](https://github.com/krzysztofzablocki/Sourcery/pull/1197))

## 2.0.3
## Internal Changes
- Modifications to included files of Swift Templates are now detected by hashing instead of using the modification date when invalidating the cache ([#1161](https://github.com/krzysztofzablocki/Sourcery/pull/1161))
- Fixes incorrectly parsed /r/n newline sequences ([#1165](https://github.com/krzysztofzablocki/Sourcery/issues/1165) and [#1138](https://github.com/krzysztofzablocki/Sourcery/issues/1138))
- Fixes incorrect parsing of annotations if there are attributes on lines preceeding declaration ([#1141](https://github.com/krzysztofzablocki/Sourcery/issues/1141))
- Fixes incorrect parsing of trailing inline comments following enum case' rawValue ([#1154](https://github.com/krzysztofzablocki/Sourcery/issues/1154))
- Fixes incorrect parsing of multibyte enum case identifiers with associated values
- Improves type inference when using contained types for variables ([#1091](https://github.com/krzysztofzablocki/Sourcery/issues/1091))

## 2.0.2
- Fixes incorrectly parsed variable names that include property wrapper and comments, closes #1140

## 2.0.1
## Internal Changes
- Fixed non-ASCII characters handling in source code parsing [#1130](https://github.com/krzysztofzablocki/Sourcery/pull/1130)
- Improved performance by about 20%

## Changes
- sourcery:auto inline fragments will appear on the body definition level
    - added baseIndentation/base-indentation option that will be taken into as default adjustment when using those fragments
- add support for type methods to AutoMockable

## 1.9.2
## Internal Changes
- Reverts part of [#1113](https://github.com/krzysztofzablocki/Sourcery/pull/1113) due to incomplete implementation breaking type complex resolution
- Files that had to be parsed will be logged if their count is less than 50 (or always in verbose mode)

## 1.9.1
## New Features
- Adds support for public protocols in AutoMockable template [#1100](https://github.com/krzysztofzablocki/Sourcery/pull/1100)
- Adds support for async and throwing properties to AutoMockable template [#1101](https://github.com/krzysztofzablocki/Sourcery/pull/1101)
- Adds support for actors and nonisolated methods [#1112](https://github.com/krzysztofzablocki/Sourcery/pull/1112)

## Internal Changes
- Fixed parsing of extensions and nested types in swiftinterface files [#1113](https://github.com/krzysztofzablocki/Sourcery/pull/1113)

## 1.9.0
- Update StencilSwiftKit to fix SPM resolving issue when building as a Command Plugin [#1023](https://github.com/krzysztofzablocki/Sourcery/issues/1023)
- Adds new `--cacheBasePath` option to `SourceryExecutable` to allow for plugins setting a default cache [#1093](https://github.com/krzysztofzablocki/Sourcery/pull/1093)
- Adds new `--dry` option to `SourceryExecutable` to check output without file system modifications [#1097](https://github.com/krzysztofzablocki/Sourcery/pull/1097)
- Changes parser to new [SwiftSyntax Parser](https://github.com/apple/swift-syntax/pull/767)
- Drops dylib dependency

## 1.8.2
## New Features
- Added `deletingLastComponent` filter to turn `/Path/Class.swift` into `/Path`
- Added `directory` computed property to `Type`

## 1.8.1
## New Features
- Added a new flag `--serialParse` to support parsing the sources in serial, rather than in parallel (the default), which can address stability issues in SwiftSyntax [#1063](https://github.com/krzysztofzablocki/Sourcery/pull/1063)

## Internal Changes
- Lower project requirements to allow compilation using Swift 5.5/Xcode 13.x [#1049](https://github.com/krzysztofzablocki/Sourcery/pull/1049)
- Update Stencil to 0.14.2
- Use `swift build` insead of `xcodebuild` when building binary [#1057](https://github.com/krzysztofzablocki/Sourcery/pull/1057)

## 1.8.0
## New Features
- Adds `xcframework` key to `target` object in configuration file to enable processing of `swiftinterface`

## Fixes
- Fixed issues generating Swift Templates when using Xcode 13.3 [#1040](https://github.com/krzysztofzablocki/Sourcery/issues/1040)
- Modifications to included files of Swift Templates now correctly invalidate the cache - [#889](https://github.com/krzysztofzablocki/Sourcery/issues/889)

## Internal Changes
- Swift 5.6 and Xcode 13.3 is now required to build the project
- `lib_internalSwiftSyntaxParser` is now statically linked enabling better support when installing through SPM and Mint [#1037](https://github.com/krzysztofzablocki/Sourcery/pull/1037)

## 1.7.0

## New Features
- Adds `fileName` to `Type` and exposes `path` as well
- Adds support for parsing async methods, closures and variables

## Fixes
- correct parsing of rawValue initializer in enum cases, fixes #1010
- Use name or path parameter to parse groups to avoid duplicated group creation, fixes #904, #906

---

## 1.6.1
## New Features
- Added `CLI-Only` subspec to `Sourcery.podspec` [#997](https://github.com/krzysztofzablocki/Sourcery/pull/997)
- Added documentation comment parsing for all declarations [#1002](https://github.com/krzysztofzablocki/Sourcery/pull/1002)
- Updates Yams to 4.0.6
- Enables universal binary

---

## 1.6.0
## Fixes
- Update dependencies to fix build on Xcode 13 and support Swift 5.5 [#989](https://github.com/krzysztofzablocki/Sourcery/issues/989)
- Improves performance
- Skips hidden files / directories and doesn't step into packages
- added `after-auto:` generation mode to inline codegen
- Fixes unstable ordering of `TypeName.attributes` 
- Fixing `Type.uniqueMethodFilter(_:_:)` so it compares return types of methods as well.

## 1.5.0
## Features
- Adds support for variadic parameters in functions
- Adds support for parsing property wrappers
- Added `titleCase` filter that turns `somethingNamedLikeThis` into `Something Named Like This`

## Fixes
- correct passing `force-parse` argument to specific file parsers and renames it to `forceParse` to align with other naming
- corrects `isMutable` regression on protocol variables #964
- Added multiple targets to link
- Fix groups creation

---
## 1.4.2

## Fixes
- Fix a test failing on macOS 11.3
- Fix generation of inline:auto annotations in files with other inline annotations.
- Fixes modifier access for things like `isLazy`, `isOptional`, `isConvienceInitializer`, `isFinal`
- Fixes `isMutable` on subscripts
- Fixes `open` access parsing
- Removes symlinks in project, since these can confuse Xcode
- [Fixes `inout` being incorrectly parsed for closures](https://github.com/krzysztofzablocki/Sourcery/issues/956)

## New Feature
- Updated to Swift / SwiftSyntax 5.4
- Added ability to parse inline code generated by sourcery if annotation ends with argument provided in `--force-parse` option

---
## 1.4.1

## New Feature
- Extending AutoMockable template by adding handling of "autoMockableImports" and "autoMockableTestableImports" args.
- Sourcery now supports [sourcerytemplates generated by Sourcery Pro](https://merowing.info/sourcery-pro/)

## Fixes
- Adds trim option for Stencil template leading / trailing whitespace and replaces newline tag markers with normal newline after that
- Fixes broken output for files with inline annotations from multiple templates

---
## 1.4.0

## Features
- Added `allImports` property to `Type`, which returns all imports existed in all files containing this type and all its super classes/protocols.
- Added `basedTypes` property to `Type`, which contains all Types this type inherits from or implements, including unknown (not scanned) types with extensions defined.
- Added inference logic for basic generics from variable initialization block
- Added `newline` and `typed` stencil tags from [Sourcery Pro](https://merowing.info/sourcery-pro/)

## Fixes
- Fixed inferring raw value type from inherited types for enums with no cases or with associated values
- Fixed access level of protocol members
- Fixes parsing indirect enum cases correctly even when inline documentation is used
- Fixes TypeName.isClosure to handle composed types correctly
- Fixes issue where Annotations for Protocol Composition types are empty
- Fixes `sourcery:inline:auto` position calculation when the file contains UTF16 characters
- Fixes `sourcery:inline:auto` position calculation when the file already contains code generated by Sourcery

## Internal changes
- Removes manual parsing of `TypeName`, only explicit parser / configuration is now used
- Add support for testing via `SPM`
- Updted SwiftLint, Quick and Nible to latest versions

## 1.3.4
## Fixes
- `isClosure` / `isArray` / `isTuple` / `isDictionary` should now consistently report correct values, this code broke in few cases in 1.3.2
- Trivia (comments etc) will be ignored when parsing attribute description

## 1.3.3
## Fixes
- Fixes information being lost when extending unknown type more than once
- Multiple configuration files can be now passed through command line arguments

## Templates
- AutoEquatable will use type.accessLevel for it's function, closes #675
## Internal changes
- If you are using `.swifttemplate` in your configuration you might notice performance degradation, this is due to new composer added in `1.3.2` that can create memory graph cycles between AST with which our current persistence doesn't deal properly, to workaround this we need to perform additional work for storing copy of parsed AST and compose it later on when running SwiftTemplates. This will be fixed in future release when AST changes are brought in, if you notice too much of a performance drop you can just switch to `1.3.1`.  

## 1.3.2
## New Features
- Configuration file now supports multiple configurations at once

## Fixes
- When resolving extensions inherit their access level for methods/subscripts/variables and sub-types fixes #910
- When resolving Parent.ChildGenericType<Type> properly parses generic information

## Internal changes
- Faster composing phase

## 1.3.1
## Internal changes
- SwiftSyntax dylib is now bundled with the binary

## 1.3.0
## Internal changes
- Sourcery is now using SwiftSyntax not SourceKit
- Performance is significantly improved
- Memory usage for common case (cached) is drastically lowered
- If you want to use Sourcery as framework you'll need to use SPM integration since SwiftSyntax doesn't have Podspec

## Configuration changes
- added `logAST` that will cause AST warnings and errors to be logged, default `false`
- added `logBenchmarks` that will cause benchmark informations to be logged, default `false`

## AST Data Changes
- initializers are now considered as static method not instance
- typealiases and protocol compositions now provide proper `accessLevel`
- if a tuple arguments are unnamed their `name` will be automatically set to index
- default `accessLevel` when not provided in code is internal everywhere
- Added `modifiers` to everything that had `attributes` and split them across, in sync with Swift naming
- block annotations will be applied to associated values that are inside them
- extensions of unknown types will not have the definition module name added in their `globalName` property. (You can still access it via `module`)
- if you had some weird formatting around syntax declarations (newlines in-between etc) the AST data should be cleaned up rather than trying to reproduce that style
- Imports are now proper types, with additional information
- Protocol now has `genericRequirements`, it will also inherit `associatedType` from it's parent if it's not present
- Single value tuples will be automatically unwrapped when parsing

### Attributes
- Attributes are now of stored in dictionary of arrays `[String: [Attribute]]` since you can have multiple attributes of the same name e.g. `@available`
- Name when not named will be using index same as associated value do e.g. objc(name) will have `0: name` as argument 
- spaces will no longer be replaced with `_`

## 1.2.1

## Internal Changes
Tweaks some warnings into info logs to not generate Xcode warnings

## 1.2.0

### New Features
- `Self` reference is resolved to correct type. [Enchancement Request](https://github.com/krzysztofzablocki/Sourcery/issues/900)
- Sourcery will now attempt to resolve local type names across modules when it can be done without ambiguity. Previously we only supported fully qualified names. [Enchancement Request](https://github.com/krzysztofzablocki/Sourcery/issues/899)

## Internal Changes
- Sourcery is now always distributed via SPM, this creates much nicer diffs when using CocoaPods distribution.

## 1.1.1

- Updates StencilSwiftKit to 2.8.0

## 1.1.0

### New Features
- [PR](https://github.com/krzysztofzablocki/Sourcery/pull/897) Methods, Variables and Subscripts are now uniqued in all accessors:
  - `methods` and `allMethods` 
  - `variables` and `allVariables`
  - `subscripts` and `allSubscripts`
  - New accessor is introduced that doesn't get rid of duplicates `rawMethods`, `rawVariables`, `rawSubscripts`s. 
  - The deduping process works by priority order (highest to lowest):
    - base declaration
    - inheritance
    - protocol conformance
    - extensions

## 1.0.3

### Internal Changes
- updated xcodeproj, Stencil and StencilSwiftKit to newest versions

### Bug fixes
- [Fixes type resolution when using xcode project integration](https://github.com/krzysztofzablocki/Sourcery/issues/887)
- Matches the behaviour of `allMethods` to `allVariables` by only listing the same method once, even if defined in both base protocol and extended class. You could still walk the inheritance tree if you need to (to get all original methods), but for purpose of majority of codegen this is unneccessary.

## 1.0.2

### Bug fixes
- Fixes an issue when a very complicated variable initialization that contained `.init` call to unrelated case would cause the parser to assume the whole codeblock was a type and that could lead to mistakes in processing and even stack overflows

## 1.0.1

### Internal Changes

- Updated project and CI to Xcode 12.1
- Updated SourceKitten, Commander.

### Bug fixes

- Fix multiline method declarations parsing
- Fix an issue, where "types.implementing.<protocolName>" did not work due to an additional module name.
- Using tuple for associated values in enum case is deprecated since Swift 5.2. Fix AutoEquatable and AutoHashable templates to avoid the warning (#842)

## 1.0.0

### New Features

- Added support for associated types (#539)

### Bug fixes

- Disallow protocol compositions from being considered as the `rawType` of an `enum` (#830)
- Add missing documentation for the `ProtocolComposition` type.
- Fix incorrectly taking closure optional return value as sign that whole variable is optional (#823) 
- Fix incorrectly taking return values with closure as generic type as sign that whole variable is a closure (#845)
- Fix empty error at build time when using SwiftTemplate on Xcode 11.4 and higher (#817)

## 0.18.0

### New Features

- Added `optional` filter for variables
- Added `json` filter to output raw JSON objects
- Added `.defaultValue` to `AssociatedValue`
- Added support for parsing [Protocol Compositions](https://docs.swift.org/swift-book/ReferenceManual/Types.html#ID454)
- Added support for parsing free functions
- Added support for indirect enum cases
- Added support for accessing all typealiases via `typealiases` and `typesaliasesByName`
- Added support for parsing global typealiases

### Internal Changes

- Improved error logging when running with `--watch` option
- Updated CI to Xcode 11.4.1

### Bug fixes

- Fixed expansion of undefined environment variables (now consistent with command line behaviour, where such args are empty strings)
- Fixed a bug in inferring extensions of Dictionary and Array types
- Fixed a bug that was including default values as part of AssociatedValues type names
- Fixed an issue with AutoMockable.stencil template when mocked function's return type was closure
- Fixed missing SourceryRuntime dependency of SourceryFramework (SPM)

## 0.17.0

### Internal Changes

- Parallelized combining phase that yields 5-10x speed improvement for New York Times codebase
- Switched cache logic to rely on file modification date instead of content Sha256
- Additional benchmark logs showing how long does each phase take
- update dependencies to fix cocoapods setup when using Swift 5.0 everywhere. Update Quick to 2.1.0, SourceKitten to 0.23.1 and Yams to 2.0.0

## 0.16.2

### New Features

- Support automatic linking of files generated by annotations to project target

### Bug fixes

- Fixes always broken sourcery cache
- Add missing SourceryFramework library product in Package.swift

## 0.16.1

### Bug fixes
- Fix ReceivedInvocations's type for the method which have only one parameter in AutoMockable.stencil
- Fix missing folder error that could happen when running a Swift template with existing cache
- Don't add indentation to empty line when using inline generated code.
- Fix issue where errors in Swift Template would not be reported correctly when using Xcode 10.2.
- Fix annotations for enum cases with associated values that wouldn't parses them correctly when commas were used

### Internal Changes

- Removed dependency on SwiftTryCatch pod in order to avoid Swift Package Manager errors.

## 0.16.0

- Replaces environment variables inside .yml configurations (like ${PROJECT_NAME}), if a value is set.
- Fixes warning in generated AutoMockable methods that have implicit optional return values
- Support for `optional` methods in ObjC protocols
- Support for parsing lazy vars into Variable's attributes.
- Updated Stencil to 0.13.1 and SwiftStencilKit to 2.7.0
- In Swift templates CLI arguments should now be accessed via `argument` instead of `arguments`, to be consistent with Stencil and JS templates.
- Now in swift templates you can define types, extensions and use other Swift features that require file scope, without using separate files. All templates code is now placed at the top level of the template executable code, instead of being placed inside an extension of `TemplateContext` type.
- Fixed missing generated code annotated with `inline` annotation when corresponding annotation in sources are missing. This generated code will be now present in `*.generated.swift` file.
- Updated AutoHashable template to use Swift 4.2's `hash(into:)` method from `Hashable`, and enable support for inheritance.
- Record all method invocations in the `AutoMockable` template.
- Replace `swiftc` with the Swift Package Manager to build Swift templates
- Swift templates can now be used when using a SPM build of Sourcery.

## 0.15.0

### New Features

- You can now pass a json string as a command line arg or annotation and have it parsed into a Dictionary or Array to be used in the template.
- Support for Xcode 10 and Swift 4.2

## 0.14.0

### New Features

- You can now include entire Swift files in Swift templates
- You can now use AutoEquatable with annotations
- Content from multiple file annotations will now be concatenated instead of writing only the latest generated content.

For example content generated by two following templates

```
// sourcery:file:Generated/Foo.swift
line one
// sourcery:end
```
and

```
// sourcery:file:Generated/Foo.swift
line two
// sourcery:end
```

will be written to one file:

```
line one

line two

```

### Internal Changes

- Use AnyObject for class-only protocols

### Bug fixes

- Fixed parsing associated enum cases in Xcode 10
- Fixed AutoEquatable access level for `==` func
- Fixed path of generated files when linked to Xcode project
- Fixed extraction of inline annotations in multi line comments with documentation style
- Fixed compile error when used AutoHashable in NSObject subclass.

## 0.13.1

### New Features

- Added support for enums in AutoCodable template
- You can now specify the base path for the Sourcery cache directory with a `cacheBasePath` key in the config file

## 0.13.0

### New Features

- Added AutoCodable template

### Bug fixes

- Fixed parsing protocol method return type followed by declaration with attribute
- Fixed inserting auto-inlined code on the last line of declaration body
- AutoEquatable and AutoHashable templates should not add protocol conformances in extensions

## 0.12.0

### Internal Changes

- Migrate to Swift 4.1 and Xcode 9.3

## 0.11.2

### Bug fixes

- Autocases template not respecting type access level
- Ensure SPM and CocoaPods dependencies match
- Improve AutoMockable template to handle methods with optional return values
- Fixed crash while compiling swift templates

## 0.11.1

### Internal changes

- Do not fail the build if slather fails
- Updated SourceKitten to 0.20.0

### Bug fixes

- Fixed parsing protocol methods return type (#579)

## 0.11.0

### New Features

- Supports adding new templates files while in watcher mode
- Supports adding new source files while in watcher mode
- Added support for subscripts
- Added `isGeneric` property for `Method`
- You can now pass additional arguments one by one, i.e. `--args arg1=value1 --args arg2 --args arg3=value3`
- Improved support for generic types. Now you can access basic generic type information with `TypeName.generic` property
- added `@objcMembers` attribute
- Moved EJS and Swift templates to separate framework targets
- EJS templates now can be used when building Sourcery with SPM
- Added Closures to AutoMockable
- You can now link generated files to projects using config file
- You can now use AutoMockable with annotations
- Updated to latest version of Stencil (commit 9184720)
- Added support for annotation namespaces
- Added `--exclude-sources` and `--exclude-templates` CLI options

** Breaking **

- @objc attribute now has a `name` argument that contains Objective-C name of attributed declaration
- Type collections `types.based`, `types.implementing` and `types.inheriting` now return non-optional array. If no types found, empty array will be returned.
This is a breaking change for template code like this:

 ```swift
<% for type in (types.implementing["SomeProtocol"] ?? []) { %>
```

 The new correct syntax would be:

 ```swift
<% for type in types.implementing["SomeProtocol"] { %>
```

### Internal changes

- Migrate to Swift 4, SwiftPM 4 and Xcode 9.2
- `selectorName` for methods without parameters now will not contain `()`
- `returnTypeName` for initializers will be the type name of defining type, with `?` for failable initializers
- Improved compile time of AutoHashable template
- Updated StencilSwiftKit and Stencil to 0.10.1

### Bug fixes

- Fixes FSEvents errors reported in #465 that happen on Sierra
- JS exceptions no more override syntax errors in JS templates
- Accessing unknown property on `types` now results in a better error than `undefined is not an object` in JS templates
- Fixed issue in AutoMockable, where generated non-optional variables wouldn't meet protocol's requirements. For this purpose, underlying variable was introduced
- Fixed `inline:auto` not inserting code if Sourcery is run with cache enabled #467
- Fixed parsing @objc attributes on types
- Fixed parsing void return type in methods without spaces between method name and body open curly brace and in protocols
- Fixed AutoMockable template generating throwing method with void return type
- Fixed parsing throwing initializers
- Fixed trying to process files which do not exist
- Automockable will not generate mocks for methods defined in protocol extensions
- Fixed parsing typealiases of generic types
- AutoLenses template will create lenses only for stored properties
- Fixed resolving actual type name for generics with inner types
- Fixed parsing nested types from extensions
- Fixed removing back ticks in types names
- Fixed creating output folder if it does not exist
- Fixed inferring variable types with closures and improved inferring types of enum default values
- Fixed enum cases with empty parentheses not having () associated value

## 0.10.1

* When installing Sourcery via CocoaPods, the unneeded `file.zip` is not kept in `Pods/Sourcery/` anymore _(freeing ~12MB on each install of Sourcery made via CocoaPods!)_.

## 0.10.0

### New Features

- Added test for count Stencil filter
- Added new reversed Stencil filter
- Added new isEmpty Stencil filter
- Added new sorted and sortedDescending Stencil filters. This can sort arrays by calling e.g. `protocol.allVariables|sorted:"name"`
- Added new toArray Stencil filter
- Added a console warning when a yaml is available but any parameter between 'sources', templates', 'forceParse', 'output' are provided

### Internal changes

- Add release to Homebrew rake task
- Fixed Swiftlint warnings
- Fixed per file generation if there is long (approx. 150KB) output inside `sourcery:file` annotation
- Do not generate default.profraw
- Remove filters in favor of same filters from StencilSwiftKit

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
