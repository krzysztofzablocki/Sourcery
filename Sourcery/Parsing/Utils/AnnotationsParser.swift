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
    }

    private struct Line {
        enum LineType {
            case comment
            case blockStart
            case blockEnd
            case other
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

    /// Extracts annotations from given source
    ///
    /// - Parameter source: Source to extract annotations for.
    /// - Returns: All annotations associated with given source.
    func from(_ source: [String: SourceKitRepresentable]) -> Annotations {
        guard let range = Substring.key.range(for: source), let lineInfo = location(fromByteOffset: Int(range.offset)).flatMap({ contents.lineAndCharacter(forCharacterOffset: $0) }) else { return [:] }

        var annotations = Annotations()
        for line in lines[0..<lineInfo.line-1].reversed() {
            line.annotations.forEach { annotation in
                annotations[annotation.key] = annotation.value
            }

            if line.type != .comment {
                break
            }
        }

        return annotations
    }

    private static func parse(contents: String) -> [Line] {
        var annotationsBlock = Annotations()
        return contents.lines()
                .map { $0.content.trimmingCharacters(in: .whitespaces) }
                .map { line in
                    var annotations = Annotations()
                    let isComment = line.hasPrefix("//")
                    var type: Line.LineType = isComment ? .comment : .other
                    if isComment {
                        switch searchForAnnotations(commentLine: line) {
                        case let .begin(items):
                            type = .blockStart
                            items.forEach { annotationsBlock[$0.key] = $0.value }
                            break
                        case let .annotations(items):
                            items.forEach { annotations[$0.key] = $0.value }
                            break
                        case .end:
                            type = .blockEnd
                            annotationsBlock.removeAll()
                            break
                        }
                    }

                    annotationsBlock.forEach { annotation in
                        annotations[annotation.key] = annotation.value
                    }

                    return Line(content: line,
                                type: type,
                                annotations: annotations)
                }
    }

    private static func searchForAnnotations(commentLine: String) -> AnnotationType {
        guard commentLine.contains("sourcery:") else { return .annotations([:]) }

        let substringRange: Range<String.CharacterView.Index>?
        let insideBlock: Bool
        if commentLine.contains("sourcery:begin:") {
            substringRange = commentLine
                    .range(of: "sourcery:begin:")
            insideBlock = true
        } else if commentLine.contains("sourcery:end") {
            return .end
        } else {
            substringRange = commentLine
                    .range(of: "sourcery:")
            insideBlock = false
        }

        guard let range = substringRange else { return .annotations([:]) }

        let annotations = AnnotationsParser.parse(line: commentLine.substring(from: range.upperBound))

        return insideBlock ? .begin(annotations) : .annotations(annotations)
    }

    /// Parses annotations from the given line
    ///
    /// - Parameter line: Line to parse.
    /// - Returns: Dictionary containing all annotations.
    static func parse(line: String) -> Annotations {
        let annotationDefinitions = line.trimmingCharacters(in: .whitespaces)
                .components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }

        var annotations = Annotations()
        annotationDefinitions.forEach { annotation in
            let parts = annotation.components(separatedBy: "=").map { $0.trimmingCharacters(in: .whitespaces) }
            if let name = parts.first, !name.isEmpty {

                guard parts.count > 1, var value = parts.last, value.isEmpty == false else {
                    annotations[name] = NSNumber(value: true)
                    return
                }

                if let number = Float(value) {
                    annotations[name] = NSNumber(value: number)
                } else {
                    if (value.hasPrefix("'") && value.hasSuffix("'")) || (value.hasPrefix("\"") && value.hasSuffix("\"")) {
                        value = value[value.characters.index(after: value.startIndex) ..< value.characters.index(before: value.endIndex)]
                    }
                    annotations[name] = value as NSString
                }
            }
        }

        return annotations
    }

    //! this isn't exposed in SourceKitten so we create our own variant
    private func location(fromByteOffset byteOffset: Int) -> Int? {
        let lines = contents.lines()
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
