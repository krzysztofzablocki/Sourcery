//
//  SyntaxMap.swift
//  SourceKitten
//
//  Created by JP Simard on 2015-01-03.
//  Copyright (c) 2015 SourceKitten. All rights reserved.
//

import Foundation

/// Represents a Swift file's syntax information.
public struct SyntaxMap {
    /// Array of SyntaxToken's.
    public let tokens: [SyntaxToken]

    /**
    Create a SyntaxMap by passing in tokens directly.

    - parameter tokens: Array of SyntaxToken's.
    */
    public init(tokens: [SyntaxToken]) {
        self.tokens = tokens
    }

    /**
    Create a SyntaxMap by passing in NSData from a SourceKit `editor.open` response to be parsed.

    - parameter data: NSData from a SourceKit `editor.open` response
    */
    public init(data: [SourceKitRepresentable]) {
        tokens = data.map { item in
            let dict = item as! [String: SourceKitRepresentable]
            return SyntaxToken(type: dict["key.kind"] as! String, offset: Int(dict["key.offset"] as! Int64), length: Int(dict["key.length"] as! Int64))
        }
    }

    /**
    Create a SyntaxMap from a SourceKit `editor.open` response.

    - parameter sourceKitResponse: SourceKit `editor.open` response.
    */
    public init(sourceKitResponse: [String: SourceKitRepresentable]) {
        self.init(data: SwiftDocKey.getSyntaxMap(sourceKitResponse)!)
    }

    /**
    Create a SyntaxMap from a File to be parsed.

    - parameter file: File to be parsed.
    - throws: Request.Error
    */
    public init(file: File) throws {
        self.init(sourceKitResponse: try Request.editorOpen(file: file).send())
    }
}

// MARK: Support for enumerating doc-comment blocks

extension SyntaxToken {
    /// Is this a doc comment?
    internal var isDocComment: Bool {
        return SyntaxKind.docComments().contains { $0.rawValue == type }
    }
}

extension SyntaxMap {
    /// The ranges of documentation comments described by the map, in the order
    /// that they occur in the file.
    internal var docCommentRanges: [Range<Int>] {
        let docCommentBlocks = tokens.split { !$0.isDocComment }
        return docCommentBlocks.flatMap { ranges in
            ranges.first.flatMap { first in
                ranges.last.flatMap { last -> Range<Int>? in
                    first.offset..<last.offset + last.length
                }
            }
        }
    }

    /**
    A tool to distribute doc comments between declarations.
    A new instance covers a single complete pass of the file.
    The `getRangeForDeclaration(atOffset:)` method should be called with the file's
    declaration offsets in order to retrieve the most appropriate doc comment for each.
    */
    internal final class DocCommentFinder {
        /// Remaining doc comments that have not been assigned or skipped
        private var ranges: [Range<Int>]
        /// The most recent file offset requested
        private var previousOffset: Int

        /// Create a new doc comment finder from a `SyntaxMap`.
        internal init(syntaxMap: SyntaxMap) {
            self.ranges = syntaxMap.docCommentRanges
            self.previousOffset = -1
        }

        /// Get the byte range of the declaration's doc comment, or nil if none.
        internal func getRangeForDeclaration(atOffset offset: Int) -> Range<Int>? {
            guard offset > previousOffset else { return nil }

            let commentsBeforeDecl = ranges.prefix { $0.upperBound < offset }
            ranges.replaceSubrange(0..<commentsBeforeDecl.count, with: [])
            previousOffset = offset
            return commentsBeforeDecl.last
        }
    }

    /// Create a new doc comment finder for this map
    internal func createDocCommentFinder() -> DocCommentFinder {
        return DocCommentFinder(syntaxMap: self)
    }
}

// MARK: CustomStringConvertible

extension SyntaxMap: CustomStringConvertible {
    /// A textual JSON representation of `SyntaxMap`.
    public var description: String {
        return toJSON(tokens.map { $0.dictionaryValue })
    }
}

// MARK: Equatable

extension SyntaxMap: Equatable {}

/**
Returns true if `lhs` SyntaxMap is equal to `rhs` SyntaxMap.

- parameter lhs: SyntaxMap to compare to `rhs`.
- parameter rhs: SyntaxMap to compare to `lhs`.

- returns: True if `lhs` SyntaxMap is equal to `rhs` SyntaxMap.
*/
public func == (lhs: SyntaxMap, rhs: SyntaxMap) -> Bool {
    if lhs.tokens.count != rhs.tokens.count {
        return false
    }
    for (index, value) in lhs.tokens.enumerated() where rhs.tokens[index] != value {
        return false
    }
    return true
}
