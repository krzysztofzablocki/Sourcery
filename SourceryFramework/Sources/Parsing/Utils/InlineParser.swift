//
// Created by Krzysztof Zablocki on 16/01/2017.
// Copyright (c) 2017 Pixle. All rights reserved.
//

import Foundation

public enum TemplateAnnotationsParser {

    public typealias AnnotatedRanges = [String: [(range: NSRange, indentation: String)]]

    private static func regex(annotation: String) throws -> NSRegularExpression {
        let commentPattern = NSRegularExpression.escapedPattern(for: "//")
        let regex = try NSRegularExpression(
            pattern: "(^(?:\\s*?\\n)?(\\s*)\(commentPattern)\\s*?sourcery:\(annotation):)(\\S*)\\s*?(^.*?)(^\\s*?\(commentPattern)\\s*?sourcery:end)",
            options: [.allowCommentsAndWhitespace, .anchorsMatchLines, .dotMatchesLineSeparators]
        )
        return regex
    }

    public static func parseAnnotations(_ annotation: String, contents: String, aggregate: Bool = false, forceParse: [String]) -> (contents: String, annotatedRanges: AnnotatedRanges) {
        let (annotatedRanges, rangesToReplace) = annotationRanges(annotation, contents: contents, aggregate: aggregate, forceParse: forceParse)

        let strigView = StringView(contents)
        var bridged = contents.bridge()
        rangesToReplace
            .sorted(by: { $0.location > $1.location })
            .forEach {
                bridged = bridged.replacingCharacters(in: $0, with: String(repeating: " ", count: strigView.NSRangeToByteRange($0)!.length.value)) as NSString
        }
        return (bridged as String, annotatedRanges)
    }

    public static func annotationRanges(_ annotation: String, contents: String, aggregate: Bool = false, forceParse: [String]) -> (annotatedRanges: AnnotatedRanges, rangesToReplace: Set<NSRange>) {
        let bridged = contents.bridge()
        let regex = try? self.regex(annotation: annotation)

        var rangesToReplace = Set<NSRange>()
        var annotatedRanges = AnnotatedRanges()

        regex?.enumerateMatches(in: contents, options: [], range: bridged.entireRange) { result, _, _ in
            guard let result = result, result.numberOfRanges == 6 else {
                return
            }

            let indentationRange = result.range(at: 2)
            let nameRange = result.range(at: 3)
            let startLineRange = result.range(at: 4)
            let endLineRange = result.range(at: 5)

            let indentation = bridged.substring(with: indentationRange)
            let name = bridged.substring(with: nameRange)
            let range = NSRange(
                location: startLineRange.location,
                length: endLineRange.location - startLineRange.location
            )
            if aggregate {
                var ranges = annotatedRanges[name] ?? []
                ranges.append((range: range, indentation: indentation))
                annotatedRanges[name] = ranges
            } else {
                annotatedRanges[name] = [(range: range, indentation: indentation)]
            }
            let rangeToBeRemoved = !forceParse.contains(where: { name.hasSuffix("." + $0) || name == $0 })
            if rangeToBeRemoved {
                rangesToReplace.insert(range)
            }
        }
        return (annotatedRanges, rangesToReplace)
    }

    public static func removingEmptyAnnotations(from content: String) -> String {
        var bridged = content.bridge()
        let regex = try? self.regex(annotation: "\\S*")

        var rangesToReplace = [NSRange]()

        regex?.enumerateMatches(in: content, options: [], range: bridged.entireRange) { result, _, _ in
            guard let result = result, result.numberOfRanges == 6 else {
                return
            }

            let annotationStartRange = result.range(at: 1)
            let startLineRange = result.range(at: 4)
            let endLineRange = result.range(at: 5)
            if startLineRange.length == 0 {
                rangesToReplace.append(NSRange(
                    location: annotationStartRange.location,
                    length: NSMaxRange(endLineRange) - annotationStartRange.location
                ))
            }
        }

        rangesToReplace
            .reversed()
            .forEach {
                bridged = bridged.replacingCharacters(in: $0, with: "") as NSString
        }

        return bridged as String
    }

}
