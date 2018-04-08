//
//  OffsetMap.swift
//  SourceKitten
//
//  Created by JP Simard on 2015-01-05.
//  Copyright (c) 2015 SourceKitten. All rights reserved.
//

/// Type that maps potentially documented declaration offsets to its closest parent offset.
public typealias OffsetMap = [Int: Int]

/// File methods to generate and manipulate OffsetMap's.
extension File {
    /**
    Creates an OffsetMap containing offset locations at which there are declarations that likely
    have documentation comments, but haven't been documented by SourceKitten yet.

    - parameter documentedTokenOffsets: Offsets where there are declarations that likely
                                        have documentation comments.
    - parameter dictionary:             Docs dictionary to check for which offsets are already
                                        documented.

    - returns: OffsetMap containing offset locations at which there are declarations that likely
               have documentation comments, but haven't been documented by SourceKitten yet.
    */
    public func makeOffsetMap(documentedTokenOffsets: [Int], dictionary: [String: SourceKitRepresentable]) -> OffsetMap {
        var offsetMap = OffsetMap()
        for offset in documentedTokenOffsets {
            offsetMap[offset] = 0
        }
        offsetMap = mapOffsets(dictionary, offsetMap: offsetMap)
        let alreadyDocumentedOffsets = offsetMap.filter({ $0.0 == $0.1 }).map { $0.0 }
        for alreadyDocumentedOffset in alreadyDocumentedOffsets {
            offsetMap.removeValue(forKey: alreadyDocumentedOffset)
        }
        return offsetMap
    }

    /**
    Creates a new OffsetMap that matches all offsets in the offsetMap parameter's keys to its
    nearest, currently documented parent offset.

    - parameter dictionary: Already documented dictionary.
    - parameter offsetMap:  Dictionary mapping potentially documented offsets to its nearest parent
                            offset.

    - returns: OffsetMap of potentially documented declaration offsets to its nearest parent offset.
    */
    private func mapOffsets(_ dictionary: [String: SourceKitRepresentable], offsetMap: OffsetMap) -> OffsetMap {
        var offsetMap = offsetMap
        if let rangeStart = SwiftDocKey.getNameOffset(dictionary),
           let rangeLength = SwiftDocKey.getNameLength(dictionary) {
            let bodyLength = SwiftDocKey.getBodyLength(dictionary) ?? 0
            let rangeMax = Int(rangeStart + rangeLength + bodyLength)
            let rangeStart = Int(rangeStart)
            let offsetsInRange = offsetMap.keys.filter {
                $0 >= rangeStart && $0 <= rangeMax
            }
            for offset in offsetsInRange {
                offsetMap[offset] = rangeStart
            }
        }
        // Recurse!
        if let substructure = SwiftDocKey.getSubstructure(dictionary) {
            for subDict in substructure {
                offsetMap = mapOffsets(subDict, offsetMap: offsetMap)
            }
        }
        return offsetMap
    }
}
