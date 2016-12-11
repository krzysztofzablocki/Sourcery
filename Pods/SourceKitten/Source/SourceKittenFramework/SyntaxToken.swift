//
//  SyntaxToken.swift
//  SourceKitten
//
//  Created by JP Simard on 2015-01-03.
//  Copyright (c) 2015 SourceKitten. All rights reserved.
//

/// Represents a single Swift syntax token.
public struct SyntaxToken {
    /// Token type. See SyntaxKind.
    public let type: String
    /// Token offset.
    public let offset: Int
    /// Token length.
    public let length: Int

    /// Dictionary representation of SyntaxToken. Useful for NSJSONSerialization.
    public var dictionaryValue: [String: Any] {
        return ["type": type, "offset": offset, "length": length]
    }

    /**
    Create a SyntaxToken by directly passing in its property values.

    - parameter type:   Token type. See SyntaxKind.
    - parameter offset: Token offset.
    - parameter length: Token length.
    */
    public init(type: String, offset: Int, length: Int) {
        self.type = SyntaxKind(rawValue: type)?.rawValue ?? type
        self.offset = offset
        self.length = length
    }
}

// MARK: Equatable

extension SyntaxToken: Equatable {}

/**
Returns true if `lhs` SyntaxToken is equal to `rhs` SyntaxToken.

- parameter lhs: SyntaxToken to compare to `rhs`.
- parameter rhs: SyntaxToken to compare to `lhs`.

- returns: True if `lhs` SyntaxToken is equal to `rhs` SyntaxToken.
*/
public func == (lhs: SyntaxToken, rhs: SyntaxToken) -> Bool {
    return (lhs.type == rhs.type) && (lhs.offset == rhs.offset) && (lhs.length == rhs.length)
}

// MARK: CustomStringConvertible

extension SyntaxToken: CustomStringConvertible {
    /// A textual JSON representation of `SyntaxToken`.
    public var description: String { return toJSON(dictionaryValue.bridge()) }
}
