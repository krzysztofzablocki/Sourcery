//
//  SourceLocation.swift
//  SourceKitten
//
//  Created by JP Simard on 10/27/15.
//  Copyright © 2015 SourceKitten. All rights reserved.
//

#if !os(Linux)

#if SWIFT_PACKAGE
import Clang_C
#endif
import Foundation

public struct SourceLocation: Comparable {
    public let file: String
    public let line: UInt32
    public let column: UInt32
    public let offset: UInt32

    public func range(toEnd end: SourceLocation) -> ByteRange {
      guard end.offset > offset else {
        return ByteRange(location: 0, length: 0)
      }
        return ByteRange(location: ByteCount(Int(offset)), length: ByteCount(Int(end.offset - offset)))
    }

    /// A [strict total order](http://en.wikipedia.org/wiki/Total_order#Strict_total_order)
    /// over instances of `Self`.
    public static func < (lhs: SourceLocation, rhs: SourceLocation) -> Bool {
        // Sort by file path.
        switch lhs.file.compare(rhs.file) {
        case .orderedDescending:
            return false
        case .orderedAscending:
            return true
        case .orderedSame:
            break
        }

        // Then offset.
        return lhs.offset < rhs.offset
    }
}

extension SourceLocation {
    init(clangLocation: CXSourceLocation) {
        var cxfile: CXFile?
        var line: UInt32 = 0
        var column: UInt32 = 0
        var offset: UInt32 = 0
        clang_getSpellingLocation(clangLocation, &cxfile, &line, &column, &offset)
        self.init(file: clang_getFileName(cxfile).str() ?? "<none>",
            line: line, column: column, offset: offset)
    }
}
#endif
