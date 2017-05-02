//
// Created by Eugene Egorov on 01 May 2017.
// Copyright (c) 2017 Pixle. All rights reserved.
//

import Foundation
import SourceKittenFramework

/// Helper for parsing enums
internal enum EnumParser {
    private static let trimmingCharacterSet: CharacterSet = CharacterSet(charactersIn: "-=.,:;").union(.whitespacesAndNewlines)
    private static let caseKeywordLength = Int64("case".characters.count)

    static func annotationsBodyStructured(content: String, source: [String: SourceKitRepresentable], containingInSource: [String: SourceKitRepresentable]?) -> String? {
        guard
            let containingInSource = containingInSource,
            SwiftDocKey.getKind(containingInSource) == SwiftDeclarationKind.enum.rawValue,
            let enumRange = Substring.body.range(for: containingInSource),
            let sourceOffset = SwiftDocKey.getOffset(source),
            let sourceLength = SwiftDocKey.getLength(source),
            let enumCases = SwiftDocKey.getSubstructure(containingInSource)
        else {
            return nil
        }

        let sourceEnd = sourceOffset + sourceLength
        var start = enumRange.offset
        var lastComment = ""

        // enumerating cases
        for enumCase in enumCases {
            guard
                let enumCase = enumCase as? [String: SourceKitRepresentable],
                let offset = SwiftDocKey.getOffset(enumCase),
                let length = SwiftDocKey.getLength(enumCase)
            else {
                continue
            }

            let oldStart = start
            start = offset + length

            guard
                SwiftDocKey.getKind(enumCase) == SwiftDeclarationKind.enumcase.rawValue,
                offset < sourceEnd,
                let elements = SwiftDocKey.getSubstructure(enumCase)
            else {
                continue
            }

            var elementStart = elements.count == 1 ? oldStart : offset + caseKeywordLength

            // enumerating elements in cases
            for element in elements {
                guard
                    let element = element as? [String: SourceKitRepresentable],
                    let elementOffset = SwiftDocKey.getOffset(element),
                    let elementLength = SwiftDocKey.getLength(element)
                else {
                    continue
                }

                let oldElementStart = elementStart
                elementStart = elementOffset + elementLength
                start = elementStart

                guard
                    SwiftDocKey.getKind(element) == SwiftDeclarationKind.enumelement.rawValue,
                    elementOffset < sourceEnd
                else {
                    continue
                }

                // extracting content between code nodes
                if oldElementStart < elementOffset, let comment = content.extract(range: (offset: oldElementStart, length: elementOffset - oldElementStart)) {
                    lastComment = comment.trimmingCharacters(in: trimmingCharacterSet)
                }
            }
        }

        return !lastComment.isEmpty ? lastComment : nil
    }

    static func annotationsBody(content: String, source: [String: SourceKitRepresentable], containingInSource: [String: SourceKitRepresentable]?) -> String {
        let enumRange = containingInSource.flatMap(Substring.body.range)
        let enumCaseRange = Substring.keyPrefix.range(for: source)

        var searchRange: (offset: Int64, length: Int64)? = nil
        if let enumCaseRange = enumCaseRange {
            if let enumRange = enumRange, enumRange.offset > enumCaseRange.offset {
                let range = (offset: enumRange.offset, length: enumCaseRange.length - (enumRange.offset - enumCaseRange.offset))
                searchRange = range.length > 0 ? range : enumCaseRange
            } else {
                searchRange = enumCaseRange
            }
        }

        guard
            let range = searchRange,
            var body = content.extract(range: range)?.trimmingCharacters(in: .whitespacesAndNewlines).trimmingSuffix("case")
        else {
            return ""
        }

        // search backwards for possible enum cases separators

        let ranges = [
            body.range(of: ";", options: [.backwards])?.upperBound,
            body.range(of: ",", options: [.backwards])?.upperBound,
            body.range(of: ")", options: [.backwards])?.upperBound,
            body.range(of: "case", options: [.backwards])?.upperBound,
            body.range(of: "{", options: [.backwards])?.upperBound
        ].flatMap { $0 }

        if let maxRange = ranges.max(by: <) {
            print(maxRange)
            body = body.substring(from: maxRange)
        }

        return body
    }

}

/// SwiftDocKey private functions from SourceKitten framework.
fileprivate extension SwiftDocKey {

    fileprivate static func get<T>(_ key: SwiftDocKey, _ dictionary: [String: SourceKitRepresentable]) -> T? {
        return dictionary[key.rawValue] as? T
    }

    fileprivate static func getKind(_ dictionary: [String: SourceKitRepresentable]) -> String? {
        return get(.kind, dictionary)
    }

    fileprivate static func getOffset(_ dictionary: [String: SourceKitRepresentable]) -> Int64? {
        return get(.offset, dictionary)
    }

    fileprivate static func getLength(_ dictionary: [String: SourceKitRepresentable]) -> Int64? {
        return get(.length, dictionary)
    }

    fileprivate static func getSubstructure(_ dictionary: [String: SourceKitRepresentable]) -> [SourceKitRepresentable]? {
        return get(.substructure, dictionary)
    }

}

fileprivate extension String {

    fileprivate func range(offset: SwiftDocKey, length: SwiftDocKey, source: [String: SourceKitRepresentable]) -> (offset: Int64, length: Int64)? {
        if let offset = source[offset.rawValue] as? Int64, let length = source[length.rawValue] as? Int64 {
            return (offset, length)
        }
        return nil
    }

    fileprivate func extract(range: (offset: Int64, length: Int64)) -> String? {
        let substring = self.substringWithByteRange(start: Int(range.offset), length: Int(range.length))
        return substring?.isEmpty == true ? nil : substring
    }

}
