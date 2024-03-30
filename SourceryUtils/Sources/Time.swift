//
//  Time.swift
//  SourceryFramework
//
//  Created by merowing on 03/09/2019.
//  Copyright © 2019 Pixle. All rights reserved.
//
import Foundation

/// Returns current timestamp interval
public func currentTimestamp() -> TimeInterval {
    return Date().timeIntervalSince1970
}
