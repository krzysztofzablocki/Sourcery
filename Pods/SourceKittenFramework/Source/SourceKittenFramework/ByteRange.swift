//
//  ByteRange.swift
//  SourceKittenFramework
//
//  Created by Paul Taykalo on 11.01.2020.
//  Copyright © 2020 SourceKitten. All rights reserved.
//

import Foundation

/// Structure that represents a string range in bytes.
public struct ByteRange: Equatable {
    /// The starting location of the range.
    public let location: ByteCount

    /// The length of the range.
    public let length: ByteCount

    /// Creates a byte range from a location and a length.
    ///
    /// - parameter location: The starting location of the range.
    /// - parameter length:   The length of the range.
    public init(location: ByteCount, length: ByteCount) {
        self.location = location
        self.length = length
    }

    /// The range's upper bound.
    public var upperBound: ByteCount {
        return location + length
    }

    /// The range's lower bound.
    public var lowerBound: ByteCount {
        return location
    }

    public func contains(_ value: ByteCount) -> Bool {
        return location <= value && upperBound > value
    }

    public func intersects(_ otherRange: ByteRange) -> Bool {
        return contains(otherRange.lowerBound) ||
            contains(otherRange.upperBound - 1) ||
            otherRange.contains(lowerBound) ||
            otherRange.contains(upperBound - 1)
    }

    public func intersects(_ ranges: [ByteRange]) -> Bool {
        return ranges.contains { intersects($0) }
    }

    public func union(with otherRange: ByteRange) -> ByteRange {
        let maxUpperBound = max(upperBound, otherRange.upperBound)
        let minLocation = min(location, otherRange.location)
        return ByteRange(location: minLocation, length: maxUpperBound - minLocation)
    }

}
