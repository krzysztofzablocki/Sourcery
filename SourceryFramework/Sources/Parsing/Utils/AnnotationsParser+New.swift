import SwiftSyntax
import SourceryRuntime

extension AnnotationsParser {
    func inlineFrom(line lineInfo: (line: Int, character: Int), stop: inout Bool) -> Annotations {
        let sourceLine = lines[lineInfo.line - 1]
        let utf8View = sourceLine.content.utf8
        let startIndex = utf8View.startIndex
        let endIndex = utf8View.index(startIndex, offsetBy: (lineInfo.character - 1))
        let utf8Slice = utf8View[startIndex ..< endIndex]
        let relevantContent = String(decoding: utf8Slice, as: UTF8.self)
        var prefix = relevantContent.trimmingCharacters(in: .whitespaces)

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

            guard previousLine.type == .comment || previousLine.type == .documentationComment || previousLine.type == .propertyWrapper || previousLine.type == .macros, content.hasPrefix("//") || content.hasSuffix("*/") || content.hasPrefix("@") || content.hasPrefix("#") else {
                stop = true
                return annotations
            }
        }

        return annotations
    }
}
