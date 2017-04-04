<img src="https://cloud.githubusercontent.com/assets/75655/24417155/91254d68-13e7-11e7-91eb-470380161633.png" width="154" alt="XcodeEdit">
<hr>

Reading _and writing_ the Xcode pbxproj file format, from Swift!

The main goal of this project is to generate `project.pbxproj` files in the legacy OpenStep format used by Xcode. Using this, a project file can be modified without changing it to XML format and causing a huge git diff.

Currently, this project is mostly used to support [R.swift](https://github.com/mac-cain13/R.swift).


Usage
-----

This reads a xcodeproj file (possibly in XML format), and writes it back out in OpenStep format:

```swift
let xcodeproj = URL(fileURLWithPath: "Test.xcodeproj")

let proj = try! XCProjectFile(xcodeprojURL: xcodeproj)

try! proj.write(to: xcodeproj, format: PropertyListSerialization.PropertyListFormat.openStep)
```


Releases
--------

 - **1.0.0** - 2017-03-28 - Rename from Xcode.swift to XcodeEdit
 - **0.3.0** - 2016-04-27 - Fixes to SourceTreeFolder
 - 0.2.1 - 2015-12-30 - Add missing PBXProxyReference class
 - **0.2.0** - 2015-10-29 - Adds serialization support
 - **0.1.0** - 2015-09-28 - Initial public release


Licence & Credits
-----------------

XcodeEdit is written by [Tom Lokhorst](https://twitter.com/tomlokhorst) and available under the [MIT license](https://github.com/tomlokhorst/XcodeEdit/blob/develop/LICENSE), so feel free to use it in commercial and non-commercial projects.

