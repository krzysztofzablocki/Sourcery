//
// Created by Krzysztof Zablocki on 31/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import SwiftSyntax
import SourceryRuntime

/// Parser for annotations, and also documentation
public struct AnnotationsParser {

    private enum AnnotationType {
        case begin(Annotations)
        case annotations(Annotations)
        case end
        case inlineStart
        case file(Annotations)
    }

    private struct Line {
        enum LineType {
            case comment
            case documentationComment
            case blockStart
            case blockEnd
            case other
            case inlineStart
            case inlineEnd
            case file
        }
        let content: String
        let type: LineType
        let annotations: Annotations
        let blockAnnotations: Annotations
    }

    private let lines: [Line]
    private let contents: String
    private var parseDocumentation: Bool
    internal var sourceLocationConverter: SourceLocationConverter?

    /// Initializes parser
    ///
    /// - Parameter contents: Contents to parse
    init(contents: String, parseDocumentation: Bool = false, sourceLocationConverter: SourceLocationConverter? = nil) {
        self.parseDocumentation = parseDocumentation
        self.lines = AnnotationsParser.parse(contents: contents)
        self.sourceLocationConverter = sourceLocationConverter
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

    func annotations(from node: IdentifierSyntax) -> Annotations {
        from(
          location: findLocation(syntax: node.identifier),
          precedingComments: node.leadingTrivia?.compactMap({ $0.comment }) ?? []
        )
    }

    func annotations(fromToken token: SyntaxProtocol) -> Annotations {
        from(
          location: findLocation(syntax: token),
          precedingComments: token.leadingTrivia?.compactMap({ $0.comment }) ?? []
        )
    }

    func documentation(from node: IdentifierSyntax) -> Documentation {
        guard parseDocumentation else {
            return  []
        }
        return documentationFrom(
          location: findLocation(syntax: node.identifier),
          precedingComments: node.leadingTrivia?.compactMap({ $0.comment }) ?? []
        )
    }

    func documentation(fromToken token: SyntaxProtocol) -> Documentation {
        guard parseDocumentation else {
            return  []
        }
        return documentationFrom(
          location: findLocation(syntax: token),
          precedingComments: token.leadingTrivia?.compactMap({ $0.comment }) ?? []
        )
    }

    // TODO: once removing SourceKitten just kill this optionality
    private func findLocation(syntax: SyntaxProtocol) -> SwiftSyntax.SourceLocation {
        return sourceLocationConverter!.location(for: syntax.positionAfterSkippingLeadingTrivia)
    }

    private func from(location: SwiftSyntax.SourceLocation, precedingComments: [String]) -> Annotations {
        guard let lineNumber = location.line, let column = location.column else {
            return [:]
        }

        var stop = false
        var annotations = inlineFrom(line: (lineNumber, column), stop: &stop)
        guard !stop else { return annotations }

        for line in lines[0..<lineNumber-1].reversed() {
            line.annotations.forEach { annotation in
                AnnotationsParser.append(key: annotation.key, value: annotation.value, to: &annotations)
            }
            if line.type != .comment && line.type != .documentationComment {
                break
            }
        }

        lines[lineNumber-1].annotations.forEach { annotation in
            AnnotationsParser.append(key: annotation.key, value: annotation.value, to: &annotations)
        }

        return annotations
    }

    private func documentationFrom(location: SwiftSyntax.SourceLocation, precedingComments: [String]) -> Documentation {
        guard parseDocumentation,
            let lineNumber = location.line, let column = location.column else {
            return []
        }

        // Inline documentation not currently supported
        _ = column

        // var stop = false
        // var documentation = inlineDocumentationFrom(line: (lineNumber, column), stop: &stop)
        // guard !stop else { return annotations }

        var documentation: Documentation = []

        for line in lines[0..<lineNumber-1].reversed() {
            if line.type == .documentationComment {
                documentation.append(line.content.trimmingCharacters(in: .whitespaces).trimmingPrefix("///").trimmingPrefix("/**").trimmingPrefix(" "))
            }
            if line.type != .comment && line.type != .documentationComment {
                break
            }
        }

        return documentation.reversed()
    }


    func inlineFrom(line lineInfo: (line: Int, character: Int), stop: inout Bool) -> Annotations {
        let sourceLine = lines[lineInfo.line - 1]
        var prefix = sourceLine.content.bridge()
            .substring(to: max(0, lineInfo.character - 1))
            .trimmingCharacters(in: .whitespaces)

        guard !prefix.isEmpty else { return [:] }
        var annotations = sourceLine.blockAnnotations // get block annotations for this line
        sourceLine.annotations.forEach { annotation in  // TODO: verify
            AnnotationsParser.append(key: annotation.key, value: annotation.value, to: &annotations)
        }

        // `case` is not included in the key of enum case definition, so we strip it manually
        let isInsideCaseDefinition = prefix.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("case")
        prefix = prefix.trimmingPrefix("case").trimmingCharacters(in: .whitespaces)
        var inlineCommentFound = false

        while !prefix.isEmpty {
            guard prefix.hasSuffix("*/"), let commentStart = prefix.range(of: "/*", options: [.backwards]) else {
                break
            }

            inlineCommentFound = true

            let comment = String(prefix[commentStart.lowerBound...])
            for annotation in AnnotationsParser.parse(contents: comment)[0].annotations {
                AnnotationsParser.append(key: annotation.key, value: annotation.value, to: &annotations)
            }
            prefix = prefix[..<commentStart.lowerBound].trimmingCharacters(in: .whitespaces)
        }

        if (inlineCommentFound || isInsideCaseDefinition) && !prefix.isEmpty {
            stop = true
            return annotations
        }

        // if previous line is not comment or has some trailing non-comment blocks
        // we return currently aggregated annotations
        // as annotations on previous line belong to previous declaration
        if lineInfo.line - 2 > 0 {
            let previousLine = lines[lineInfo.line - 2]
            let content = previousLine.content.trimmingCharacters(in: .whitespaces)

            guard previousLine.type == .comment || previousLine.type == .documentationComment, content.hasPrefix("//") || content.hasSuffix("*/") else {
                stop = true
                return annotations
            }
        }

        return annotations
    }

    private static func parse(contents: String) -> [Line] {
        var annotationsBlock: Annotations?
        var fileAnnotationsBlock = Annotations()
        return StringView(contents).lines
                .map { line in
                    let content = line.content.trimmingCharacters(in: .whitespaces)
                    var annotations = Annotations()
                    let isComment = content.hasPrefix("//") || content.hasPrefix("/*") || content.hasPrefix("*")
                    let isDocumentationComment = content.hasPrefix("///") || content.hasPrefix("/**")
                    var type = Line.LineType.other
                    if isDocumentationComment {
                        type = .documentationComment
                    } else if isComment {
                        type = .comment
                    }
                    if isComment {
                        switch searchForAnnotations(commentLine: content) {
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
                        case let .file(items):
                            type = .file
                            items.forEach {
                                fileAnnotationsBlock[$0.key] = $0.value
                            }
                        }
                    } else {
                        searchForTrailingAnnotations(codeLine: content)
                            .forEach { annotations[$0.key] = $0.value }
                    }

                    annotationsBlock?.forEach { annotation in
                        annotations[annotation.key] = annotation.value
                    }

                    fileAnnotationsBlock.forEach { annotation in
                        annotations[annotation.key] = annotation.value
                    }

                    return Line(content: line.content,
                                type: type,
                                annotations: annotations,
                                blockAnnotations: annotationsBlock ?? [:])
                }
    }

    private static func searchForTrailingAnnotations(codeLine: String) -> Annotations {
        let blockComponents = codeLine.components(separatedBy: "/*", excludingDelimiterBetween: ("", ""))
        if blockComponents.count > 1,
           let lastBlockComponent = blockComponents.last,
           let endBlockRange = lastBlockComponent.range(of: "*/"),
           let lowerBound = lastBlockComponent.range(of: "sourcery:")?.upperBound {
            let trailingStart = endBlockRange.upperBound
            let trailing = String(lastBlockComponent[trailingStart...])
            if trailing.components(separatedBy: "//", excludingDelimiterBetween: ("", "")).first?.trimmed.count == 0 {
                let upperBound = endBlockRange.lowerBound
                return AnnotationsParser.parse(line: String(lastBlockComponent[lowerBound..<upperBound]))
            }
        }

        let components = codeLine.components(separatedBy: "//", excludingDelimiterBetween: ("", ""))
        if components.count > 1,
           let trailingComment = components.last?.stripped(),
           let lowerBound = trailingComment.range(of: "sourcery:")?.upperBound {
            return AnnotationsParser.parse(line: String(trailingComment[lowerBound...]))
        }

        return [:]
    }

    private static func searchForAnnotations(commentLine: String) -> AnnotationType {
        let comment = commentLine.trimmingPrefix("///").trimmingPrefix("//").trimmingPrefix("/**").trimmingPrefix("/*").trimmingPrefix("*").stripped()

        guard comment.hasPrefix("sourcery:") else { return .annotations([:]) }

        if comment.hasPrefix("sourcery:inline:") {
            return .inlineStart
        }

        let lowerBound: String.Index?
        let upperBound: String.Index?
        var insideBlock: Bool = false
        var insideFileBlock: Bool = false

        if comment.hasPrefix("sourcery:begin:") {
            lowerBound = commentLine.range(of: "sourcery:begin:")?.upperBound
            upperBound = commentLine.indices.endIndex
            insideBlock = true
        } else if comment.hasPrefix("sourcery:end") {
            return .end
        } else if comment.hasPrefix("sourcery:file") {
            lowerBound = commentLine.range(of: "sourcery:file:")?.upperBound
            upperBound = commentLine.indices.endIndex
            insideFileBlock = true
        } else {
            lowerBound = commentLine.range(of: "sourcery:")?.upperBound
            if commentLine.hasPrefix("//") || commentLine.hasPrefix("*") {
                upperBound = commentLine.indices.endIndex
            } else {
                upperBound = commentLine.range(of: "*/")?.lowerBound
            }
        }

        if let lowerBound = lowerBound, let upperBound = upperBound {
            let annotations = AnnotationsParser.parse(line: String(commentLine[lowerBound..<upperBound]))
            if insideBlock {
                return .begin(annotations)
            } else if insideFileBlock {
                return .file(annotations)
            } else {
                return .annotations(annotations)
            }
        } else {
            return .annotations([:])
        }
    }

    /// Parses annotations from the given line
    ///
    /// - Parameter line: Line to parse.
    /// - Returns: Dictionary containing all annotations.
    public static func parse(line: String) -> Annotations {
        var annotationDefinitions = line.trimmingCharacters(in: .whitespaces)
            .commaSeparated()
            .map { $0.trimmingCharacters(in: .whitespaces) }

        var namespaces = annotationDefinitions[0].components(separatedBy: ":", excludingDelimiterBetween: (open: "\"'", close: "\"'"))
        annotationDefinitions[0] = namespaces.removeLast()

        var annotations = Annotations()
        annotationDefinitions.forEach { annotation in
            let parts = annotation
                .components(separatedBy: "=", excludingDelimiterBetween: ("", ""))
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
                        value = String(value[value.index(after: value.startIndex) ..< value.index(before: value.endIndex)])
                        value = value.trimmingCharacters(in: .whitespaces)
                    }

                    guard let data = (value as String).data(using: .utf8),
                        let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
                            append(key: name, value: value as NSString, to: &annotations)
                            return
                    }
                    if let array = json as? [Any] {
                        append(key: name, value: array as NSArray, to: &annotations)
                    } else if let dict = json as? [String: Any] {
                        append(key: name, value: dict as NSDictionary, to: &annotations)
                    } else {
                        append(key: name, value: value as NSString, to: &annotations)
                    }
                }
            }
        }

        if namespaces.isEmpty {
            return annotations
        } else {
            var namespaced = Annotations()
            for namespace in namespaces.reversed() {
                namespaced[namespace] = annotations as NSObject
                annotations = namespaced
                namespaced = Annotations()
            }
            return annotations
        }
    }

    static func append(key: String, value: NSObject, to annotations: inout Annotations) {
        if let oldValue = annotations[key] {
            if var array = oldValue as? [NSObject] {
                if !array.contains(value) {
                    array.append(value)
                    annotations[key] = array as NSObject
                }
            } else if var oldDict = oldValue as? [String: NSObject], let newDict = value as? [String: NSObject] {
                newDict.forEach({ (key, value) in
                    append(key: key, value: value, to: &oldDict)
                })
                annotations[key] = oldDict as NSObject
            } else if oldValue != value {
                annotations[key] = [oldValue, value] as NSObject
            }
        } else {
            annotations[key] = value
        }
    }

}
