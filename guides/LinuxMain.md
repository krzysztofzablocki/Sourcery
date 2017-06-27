## I want to generate `LinuxMain.swift` for all my tests

For all test cases generates `allTests` static variable and passes all of them as `XCTestCaseEntry` to `XCTMain`. Run with `--args testimports='import MyTests'` parameter to import test modules.

### [Stencil template](https://github.com/krzysztofzablocki/Sourcery/blob/master/Templates/Templates/LinuxMain.stencil)

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
