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
    public static let current = SourceryVersion(value: inUnitTests ? "Major.Minor.Patch" : "2.1.8")
}

#if canImport(ObjectiveC)
public let inUnitTests: Bool = NSClassFromString("XCTest") != nil
#else
public let inUnitTests: Bool = ProcessInfo.processInfo.processName.hasSuffix("xctest")
#endif
