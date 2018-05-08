// Generated using Sourcery 0.13.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import XCTest

extension AutoInjectionTests {
  static var allTests: [(String, (AutoInjectionTests) -> () throws -> Void)] = [
    ("testThatItResolvesAutoInjectedDependencies", testThatItResolvesAutoInjectedDependencies),
    ("testThatItDoesntResolveAutoInjectedDependencies", testThatItDoesntResolveAutoInjectedDependencies)
  ]
}
extension AutoWiringTests {
  static var allTests: [(String, (AutoWiringTests) -> () throws -> Void)] = [
    ("testThatItCanResolveWithAutoWiring", testThatItCanResolveWithAutoWiring),
    ("testThatItCanNotResolveWithAutoWiring", testThatItCanNotResolveWithAutoWiring)
  ]
}

// swiftlint:disable trailing_comma
XCTMain([
  testCase(AutoInjectionTests.allTests),
  testCase(AutoWiringTests.allTests),
])
// swiftlint:enable trailing_comma

