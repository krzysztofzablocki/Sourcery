//
//  ByteCount.swift
//  SourceKitten
//
//  Created by Paul Taykalo on 2019-11-02.
//  Copyright © 2019 SourceKitten. All rights reserved.
//

/// Represents the number of bytes in a string. Could be used to model offsets into a string, or the distance between
/// two locations in a string.
public struct ByteCount: ExpressibleByIntegerLiteral, Hashable {
    /// The byte value as an integer.
    public var value: Int

    /// Create a byte count by its integer value.
    ///
    /// - parameter value: Integer value.
    public init(integerLiteral value: Int) {
        self.value = value
    }

    /// Create a byte count by its integer value.
    ///
    /// - parameter value: Integer value.
    public init(_ value: Int) {
        self.value = value
    }

    /// Create a byte count by its integer value.
    ///
    /// - parameter value: Integer value.
    public init(_ value: Int64) {
        self.value = Int(value)
    }
}

extension ByteCount: CustomStringConvertible {
    public var description: String {
        return value.description
    }
}

extension ByteCount: Comparable {
    public static func < (lhs: ByteCount, rhs: ByteCount) -> Bool {
        return lhs.value < rhs.value
    }
}

extension ByteCount: AdditiveArithmetic {
    public static func - (lhs: ByteCount, rhs: ByteCount) -> ByteCount {
        return ByteCount(lhs.value - rhs.value)
    }

    public static func -= (lhs: inout ByteCount, rhs: ByteCount) {
        lhs.value -= rhs.value
    }

    public static func + (lhs: ByteCount, rhs: ByteCount) -> ByteCount {
        return ByteCount(lhs.value + rhs.value)
    }

    public static func += (lhs: inout ByteCount, rhs: ByteCount) {
        lhs.value += rhs.value
    }
}
