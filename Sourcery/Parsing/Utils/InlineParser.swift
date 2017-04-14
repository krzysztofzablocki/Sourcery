//
// Created by Krzysztof Zablocki on 16/01/2017.
// Copyright (c) 2017 Pixle. All rights reserved.
//

import Foundation

internal enum TemplateAnnotationsParser {

    static func parseAnnotations(_ annotation: String, contents: String, removeFromSource: Bool = true) -> (contents: String, annotatedRanges: [String: NSRange]) {
        var bridged = contents.bridge()
        let commentPattern = NSRegularExpression.escapedPattern(for: "//")
        let regex = try? NSRegularExpression(
                pattern: "(^\\s*?\(commentPattern)\\s*?sourcery:\(annotation):)(\\S*)\\s*?(^(?:.|\\s)*?)(^\\s*?\(commentPattern)\\s*?sourcery:end)",
                options: [.allowCommentsAndWhitespace, .anchorsMatchLines]
        )

        var rangesToReplace = [NSRange]()
        var annotatedRanges = [String: NSRange]()

        regex?.enumerateMatches(in: contents, options: [], range: bridged.entireRange) { result, _, _ in
            guard let result = result, result.numberOfRanges == 5 else {
                return
            }

            let annotationStartRange = result.rangeAt(1)
            let nameRange = result.rangeAt(2)
            let startLineRange = result.rangeAt(3)
            let endLineRange = result.rangeAt(4)

            let name = bridged.substring(with: nameRange)

            annotatedRanges[name] = NSRange(
                location: startLineRange.location,
                length: endLineRange.location - startLineRange.location
            )

            rangesToReplace.append(NSRange(
                location: annotationStartRange.location,
                length: NSMaxRange(endLineRange) - annotationStartRange.location
            ))
        }

        if removeFromSource {
            rangesToReplace
                    .reversed()
                    .forEach {
                        bridged = bridged.replacingCharacters(in: $0, with: "") as NSString
                    }
        }

        return (bridged as String, annotatedRanges)
    }
}
