//
//  LinuxMain.swift
//  Templates
//
//  Created by Anton Domashnev on 17.05.17.
//  Copyright © 2017 Pixle. All rights reserved.
//

import Foundation
import XCTest

class AutoInjectionTests: XCTestCase {
    func testThatItResolvesAutoInjectedDependencies() {
        XCTAssertTrue(true)
    }

    func testThatItDoesntResolveAutoInjectedDependencies() {
        XCTAssertTrue(true)
    }
}

class AutoWiringTests: XCTestCase {
    func testThatItCanResolveWithAutoWiring() {
        XCTAssertTrue(true)
    }

    func testThatItCanNotResolveWithAutoWiring() {
        XCTAssertTrue(true)
    }
}

// sourcery: disableTests
class DisabledTests: XCTestCase {
    func testThatItResolvesDisabledTestsAnnotation() {
        XCTAssertTrue(true)
    }
}
