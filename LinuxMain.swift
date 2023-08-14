import XCTest

import CodableContextTests
import SourceryPackageTests
import TemplatesTests

var tests = [XCTestCaseEntry]()
tests += CodableContextTests.__allTests()
tests += SourceryPackageTests.__allTests()
tests += TemplatesTests.__allTests()

XCTMain(tests)
