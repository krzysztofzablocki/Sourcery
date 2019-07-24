//
//  Structure.swift
//  SourceKitten
//
//  Created by JP Simard on 2015-01-06.
//  Copyright (c) 2015 SourceKitten. All rights reserved.
//

/// Represents the structural information in a Swift source file.
public struct Structure {
    /// Structural information as an [String: SourceKitRepresentable].
    public let dictionary: [String: SourceKitRepresentable]

    /**
    Create a Structure from a SourceKit `editor.open` response.
     
    - parameter sourceKitResponse: SourceKit `editor.open` response.
    */
    public init(sourceKitResponse: [String: SourceKitRepresentable]) {
        var sourceKitResponse = sourceKitResponse
        _ = sourceKitResponse.removeValue(forKey: SwiftDocKey.syntaxMap.rawValue)
        dictionary = sourceKitResponse
    }

    /**
    Initialize a Structure by passing in a File.

    - parameter file: File to parse for structural information.
    - throws: Request.Error
    */
    public init(file: File) throws {
        self.init(sourceKitResponse: try Request.editorOpen(file: file).send())
    }
}

// MARK: CustomStringConvertible

extension Structure: CustomStringConvertible {
    /// A textual JSON representation of `Structure`.
    public var description: String { return toJSON(toNSDictionary(dictionary)) }
}

// MARK: Equatable

extension Structure: Equatable {}

/**
Returns true if `lhs` Structure is equal to `rhs` Structure.

- parameter lhs: Structure to compare to `rhs`.
- parameter rhs: Structure to compare to `lhs`.

- returns: True if `lhs` Structure is equal to `rhs` Structure.
*/
public func == (lhs: Structure, rhs: Structure) -> Bool {
    return lhs.dictionary.isEqualTo(rhs.dictionary)
}
