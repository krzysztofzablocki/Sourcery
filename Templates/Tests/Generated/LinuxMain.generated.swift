// Generated using Sourcery 0.6.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import XCTest

extension AutoInjectionTests {
  static var allTests: [(String, (AutoInjectionTests) -> () throws -> Void)] = [
    ("testThatItResolvesAutoInjectedDependencies", testThatItResolvesAutoInjectedDependencies),
    ("testThatItDoesntResolveAutoInjectedDependencies", testThatItDoesntResolveAutoInjectedDependencies),
  ]
}
extension AutoWiringTests {
  static var allTests: [(String, (AutoWiringTests) -> () throws -> Void)] = [
    ("testThatItCanResolveWithAutoWiring", testThatItCanResolveWithAutoWiring),
    ("testThatItCanNotResolveWithAutoWiring", testThatItCanNotResolveWithAutoWiring),
  ]
}

XCTMain([
  testCase(AutoInjectionTests.allTests),
  testCase(AutoWiringTests.allTests),
])
