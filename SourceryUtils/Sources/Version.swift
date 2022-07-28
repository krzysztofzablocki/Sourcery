//
//  Version.swift
//  Sourcery
//
//  Created by Anton Domashnev on 15.06.17.
//  Copyright © 2017 Pixle. All rights reserved.
//

import Foundation

public struct SourceryVersion {
    public let value: String
    public static let current = SourceryVersion(value: inUnitTests ? "Major.Minor.Patch" : "1.8.2")
}

public var inUnitTests = NSClassFromString("XCTest") != nil
