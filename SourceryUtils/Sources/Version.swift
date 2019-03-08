//
//  Version.swift
//  Sourcery
//
//  Created by Anton Domashnev on 15.06.17.
//  Copyright © 2017 Pixle. All rights reserved.
//

import Foundation

public struct Version {
    public let value: String
    public static let current = Version(value: inUnitTests ? "Major.Minor.Patch" : "0.16.0")
}

public var inUnitTests = NSClassFromString("XCTest") != nil
