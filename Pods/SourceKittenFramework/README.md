# SourceKitten

An adorable little framework and command line tool for interacting with [SourceKit][uncovering-sourcekit].

SourceKitten links and communicates with `sourcekitd.framework` to parse the Swift AST, extract comment docs for Swift or Objective-C projects, get syntax data for a Swift file and lots more!

[![Test Status](https://travis-ci.org/jpsim/SourceKitten.svg?branch=master)](https://travis-ci.org/jpsim/SourceKitten)

## Installation

Building SourceKitten on macOS requires Xcode 8.3 or later or a Swift 3.1
toolchain or later with the Swift Package Manager.

Building SourceKitten on Linux requires:

* A Swift 3.1 or later compiler and Swift Package Manager to be installed.
* `libsourcekitdInProc.so` to be built and located in `/usr/lib`, or in another
  location specified by the `LINUX_SOURCEKIT_LIB_PATH` environment variable.

SourceKitten typically supports previous versions of SourceKit.

### Homebrew

Run `brew install sourcekitten`.

### Swift Package Manager

Run `swift build` in the root directory of this project.

### Xcode (via Make)

Run `make install` in the root directory of this project.

### Package

Download and open SourceKitten.pkg from the [releases tab](https://github.com/jpsim/SourceKitten/releases).

## Command Line Usage

Once SourceKitten is installed, you may use it from the command line.

```
$ sourcekitten help
Available commands:

   complete    Generate code completion options.
   doc         Print Swift docs as JSON or Objective-C docs as XML
   help        Display general or command-specific help
   structure   Print Swift structure information as JSON
   syntax      Print Swift syntax information as JSON
   version     Display the current version of SourceKitten
```

## How is SourceKit resolved?

SourceKitten searches for SourceKit in the following order:

* `$XCODE_DEFAULT_TOOLCHAIN_OVERRIDE`
* `$TOOLCHAIN_DIR`
* `xcrun -find swift`
* `/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain`
* `/Applications/Xcode-beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain`
* `~/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain`
* `~/Applications/Xcode-beta.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain`

On Linux, SourceKit is expected to be located in
`/usr/lib/libsourcekitdInProc.so` or specified by the `LINUX_SOURCEKIT_LIB_PATH`
environment variable.

## Complete

Running `sourcekitten complete --file file.swift --offset 123` or
`sourcekitten complete --text "0." --offset 2` will print out code completion
options for the offset in the file/text provided:

```json
[{
  "descriptionKey" : "advancedBy(n: Distance)",
  "associatedUSRs" : "s:FSi10advancedByFSiFSiSi s:FPSs21RandomAccessIndexType10advancedByuRq_S__Fq_Fqq_Ss16ForwardIndexType8Distanceq_ s:FPSs16ForwardIndexType10advancedByuRq_S__Fq_Fqq_S_8Distanceq_ s:FPSs10Strideable10advancedByuRq_S__Fq_Fqq_S_6Strideq_ s:FPSs11_Strideable10advancedByuRq_S__Fq_Fqq_S_6Strideq_",
  "kind" : "source.lang.swift.decl.function.method.instance",
  "sourcetext" : "advancedBy(<#T##n: Distance##Distance#>)",
  "context" : "source.codecompletion.context.thisclass",
  "typeName" : "Int",
  "moduleName" : "Swift",
  "name" : "advancedBy(n: Distance)"
},
{
  "descriptionKey" : "advancedBy(n: Self.Distance, limit: Self)",
  "associatedUSRs" : "s:FeRq_Ss21RandomAccessIndexType_SsS_10advancedByuRq_S__Fq_FTqq_Ss16ForwardIndexType8Distance5limitq__q_",
  "kind" : "source.lang.swift.decl.function.method.instance",
  "sourcetext" : "advancedBy(<#T##n: Self.Distance##Self.Distance#>, limit: <#T##Self#>)",
  "context" : "source.codecompletion.context.superclass",
  "typeName" : "Self",
  "moduleName" : "Swift",
  "name" : "advancedBy(n: Self.Distance, limit: Self)"
},
...
]
```

To use the iOS SDK, pass `-sdk` and `-target` arguments preceded by `--`:
```
sourcekitten complete --text "import UIKit ; UIColor." --offset 22 -- -target arm64-apple-ios9.0 -sdk /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS9.0.sdk
```

## Doc

Running `sourcekitten doc` will pass all arguments after what is parsed to
`xcodebuild` (or directly to the compiler, SourceKit/clang, in the
`--single-file` mode).

### Example usage

1. `sourcekitten doc -- -workspace SourceKitten.xcworkspace -scheme SourceKittenFramework`
2. `sourcekitten doc --single-file file.swift -- -j4 file.swift`
3. `sourcekitten doc --module-name Alamofire -- -project Alamofire.xcodeproj`
4. `sourcekitten doc -- -workspace Haneke.xcworkspace -scheme Haneke`
5. `sourcekitten doc --objc Realm/Realm.h -- -x objective-c -isysroot $(xcrun --show-sdk-path) -I $(pwd)`

## Structure

Running `sourcekitten structure --file file.swift` or `sourcekitten structure --text "struct A { func b() {} }"` will return a JSON array of structure information:

```json
{
  "key.substructure" : [
    {
      "key.kind" : "source.lang.swift.decl.struct",
      "key.offset" : 0,
      "key.nameoffset" : 7,
      "key.namelength" : 1,
      "key.bodyoffset" : 10,
      "key.bodylength" : 13,
      "key.length" : 24,
      "key.substructure" : [
        {
          "key.kind" : "source.lang.swift.decl.function.method.instance",
          "key.offset" : 11,
          "key.nameoffset" : 16,
          "key.namelength" : 3,
          "key.bodyoffset" : 21,
          "key.bodylength" : 0,
          "key.length" : 11,
          "key.substructure" : [

          ],
          "key.name" : "b()"
        }
      ],
      "key.name" : "A"
    }
  ],
  "key.offset" : 0,
  "key.diagnostic_stage" : "source.diagnostic.stage.swift.parse",
  "key.length" : 24
}
```

## Syntax

Running `sourcekitten syntax --file file.swift` or `sourcekitten syntax --text "import Foundation // Hello World"` will return a JSON array of syntax highlighting information:

```json
[
  {
    "offset" : 0,
    "length" : 6,
    "type" : "source.lang.swift.syntaxtype.keyword"
  },
  {
    "offset" : 7,
    "length" : 10,
    "type" : "source.lang.swift.syntaxtype.identifier"
  },
  {
    "offset" : 18,
    "length" : 14,
    "type" : "source.lang.swift.syntaxtype.comment"
  }
]
```

## Request

Running `sourcekitten request --yaml [FILE|TEXT]` will execute a sourcekit request with the given yaml. For example:

```yaml
key.request: source.request.cursorinfo
key.sourcefile: "/tmp/foo.swift"
key.offset: 8
key.compilerargs:
  - "/tmp/foo.swift"
```

## SourceKittenFramework

Most of the functionality of the `sourcekitten` command line tool is actually encapsulated in a framework named SourceKittenFramework.

If you’re interested in using SourceKitten as part of another tool, or perhaps extending its functionality, take a look at the SourceKittenFramework source code to see if the API fits your needs.

*Note: SourceKitten is written entirely in Swift, and the SourceKittenFramework API is not designed to interface with Objective-C.*

## License

MIT licensed.

[uncovering-sourcekit]: http://jpsim.com/uncovering-sourcekit
