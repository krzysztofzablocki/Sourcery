//
// Created by Krzysztof Zablocki on 31/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import SourceKittenFramework

internal typealias Annotations = [String: NSObject]

/// Parser for annotations
internal struct AnnotationsParser {

    private enum AnnotationType {
        case begin(Annotations)
        case annotations(Annotations)
        case end
        case inlineStart
    }

    private struct Line {
        enum LineType {
            case comment
            case blockStart
            case blockEnd
            case other
            case inlineStart
            case inlineEnd
        }
        let content: String
        let type: LineType
        let annotations: Annotations
    }

    private let lines: [Line]
    private let contents: String

    /// Initializes parser
    ///
    /// - Parameter contents: Contents to parse
    init(contents: String) {
        self.lines = AnnotationsParser.parse(contents: contents)
        self.contents = contents
    }

    /// returns all annotations in the contents
    var all: Annotations {
        var all = Annotations()
        lines.forEach {
            $0.annotations.forEach {
                AnnotationsParser.append(key: $0.key, value: $0.value, to: &all)
            }
        }
        return all
    }

    /// Extracts annotations from given source
    ///
    /// - Parameter source: Source to extract annotations for.
    /// - Returns: All annotations associated with given source.
    func from(_ source: [String: SourceKitRepresentable]) -> Annotations {
        guard let range = Substring.key.range(for: source),
            let location = contents.location(fromByteOffset: Int(range.offset)),
            let lineInfo = contents.lineAndCharacter(forCharacterOffset: location)
            else { return [:] }

        var annotations = Annotations()
        for line in lines[0..<lineInfo.line-1].reversed() {
            line.annotations.forEach { annotation in
                AnnotationsParser.append(key: annotation.key, value: annotation.value, to: &annotations)
            }
            if line.type != .comment {
                break
            }
        }

        return annotations
    }

    private static func parse(contents: String) -> [Line] {
        var annotationsBlock: Annotations?
        return contents.lines()
                .map { $0.content.trimmingCharacters(in: .whitespaces) }
                .map { line in
                    var annotations = Annotations()
                    let isComment = line.hasPrefix("//") || line.hasPrefix("/*")
                    var type: Line.LineType = isComment ? .comment : .other
                    if isComment {
                        switch searchForAnnotations(commentLine: line) {
                        case let .begin(items):
                            type = .blockStart
                            annotationsBlock = Annotations()
                            items.forEach { annotationsBlock?[$0.key] = $0.value }
                        case let .annotations(items):
                            items.forEach { annotations[$0.key] = $0.value }
                        case .end:
                            if annotationsBlock != nil {
                                type = .blockEnd
                                annotationsBlock?.removeAll()
                            } else {
                                type = .inlineEnd
                            }
                        case .inlineStart:
                            type = .inlineStart
                        }
                    }

                    annotationsBlock?.forEach { annotation in
                        annotations[annotation.key] = annotation.value
                    }

                    return Line(content: line,
                                type: type,
                                annotations: annotations)
                }
    }

    private static func searchForAnnotations(commentLine: String) -> AnnotationType {
        guard commentLine.contains("sourcery:") else { return .annotations([:]) }

        if commentLine.contains("sourcery:inline:") {
            return .inlineStart
        }

        let lowerBound: String.CharacterView.Index?
        let upperBound: String.CharacterView.Index?
        let insideBlock: Bool

        if commentLine.contains("sourcery:begin:") {
            lowerBound = commentLine.range(of: "sourcery:begin:")?.upperBound
            upperBound = commentLine.characters.indices.endIndex
            insideBlock = true
        } else if commentLine.contains("sourcery:end") {
            return .end
        } else {
            insideBlock = false
            lowerBound = commentLine.range(of: "sourcery:")?.upperBound
            if commentLine.hasPrefix("//") {
                upperBound = commentLine.characters.indices.endIndex
            } else {
                upperBound = commentLine.range(of: "*/")?.lowerBound
            }
        }

        if let lowerBound = lowerBound, let upperBound = upperBound {
            let annotations = AnnotationsParser.parse(line: commentLine.substring(with: lowerBound ..< upperBound))
            return insideBlock ? .begin(annotations) : .annotations(annotations)
        } else {
            return .annotations([:])
        }
    }

    /// Parses annotations from the given line
    ///
    /// - Parameter line: Line to parse.
    /// - Returns: Dictionary containing all annotations.
    static func parse(line: String) -> Annotations {
        let annotationDefinitions = line.trimmingCharacters(in: .whitespaces)
            .commaSeparated()
            .map { $0.trimmingCharacters(in: .whitespaces) }

        var annotations = Annotations()
        annotationDefinitions.forEach { annotation in
            let parts = annotation
                .components(separatedBy: "=", excludingDelimiterBetween:("", ""))
                .map({ $0.trimmingCharacters(in: .whitespaces) })

            if let name = parts.first, !name.isEmpty {

                guard parts.count > 1, var value = parts.last, value.isEmpty == false else {
                    append(key: name, value: NSNumber(value: true), to: &annotations)
                    return
                }

                if let number = Float(value) {
                    append(key: name, value: NSNumber(value: number), to: &annotations)
                } else {
                    if (value.hasPrefix("'") && value.hasSuffix("'")) || (value.hasPrefix("\"") && value.hasSuffix("\"")) {
                        value = value[value.characters.index(after: value.startIndex) ..< value.characters.index(before: value.endIndex)]
                        value = value.trimmingCharacters(in: .whitespaces)
                    }
                    append(key: name, value: value as NSString, to: &annotations)
                }
            }
        }

        return annotations
    }

    static func append(key: String, value: NSObject, to annotations: inout Annotations) {
        if let oldValue = annotations[key] {
            if var array = oldValue as? [NSObject] {
                if !array.contains(value) {
                    array.append(value)
                    annotations[key] = array as NSObject
                }
            } else if oldValue != value {
                annotations[key] = [oldValue, value] as NSObject
            }
        } else {
            annotations[key] = value
        }
    }

}

extension String {

    //! this isn't exposed in SourceKitten so we create our own variant
    func location(fromByteOffset byteOffset: Int) -> Int? {
        let lines = self.lines()
        if lines.isEmpty {
            return 0
        }
        let index = lines.index(where: { NSLocationInRange(byteOffset, $0.byteRange) })
        // byteOffset may be out of bounds when sourcekitd points end of string.
        guard let line = (index.map { lines[$0] } ?? lines.last) else {
            fatalError()
        }
        let diff = byteOffset - line.byteRange.location
        if diff == 0 {
            return line.range.location
        } else if line.byteRange.length == diff {
            return NSMaxRange(line.range)
        }
        let utf8View = line.content.utf8
        // swiftlint:disable:next force_unwrapping
        guard let endUTF16index = utf8View.index(utf8View.startIndex, offsetBy: diff, limitedBy: utf8View.endIndex)?.samePosition(in: line.content.utf16) else { return nil }
        let utf16Diff = line.content.utf16.distance(from: line.content.utf16.startIndex, to: endUTF16index)
        return line.range.location + utf16Diff
    }

}
