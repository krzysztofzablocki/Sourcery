//
// Created by Krzysztof Zablocki on 16/01/2017.
// Copyright (c) 2017 Pixle. All rights reserved.
//

import Foundation

internal enum InlineParser {
    static func parse(_ contents: String, removeFromSource: Bool = true) -> (contents: String, inlineRanges: [String: NSRange]) {
        var bridged = contents.bridge()
        let commentPattern = NSRegularExpression.escapedPattern(for: "//")
        let regex = try? NSRegularExpression(
                pattern: "(?:^\\s*?\(commentPattern).*sourcery:inline:)(\\S*)\\s*?(^(?:.|\\s)*?)(^\\s*?\(commentPattern).*sourcery:end)",
                options: [.allowCommentsAndWhitespace, .anchorsMatchLines]
        )

        var rangesToReplace = [NSRange]()
        var inlineRanges = [String: NSRange]()

        regex?.enumerateMatches(in: contents, options: [], range: bridged.entireRange) { result, _, _ in
            guard let result = result, result.numberOfRanges == 4 else {
                return
            }

            let nameRange = result.rangeAt(1)
            let startLineRange = result.rangeAt(2)
            let endLineRange = result.rangeAt(3)

            let name = bridged.substring(with: nameRange)

            let rangeToReplace: NSRange = {
                let start = startLineRange.location
                let length = endLineRange.location - start
                return NSRange(location: start, length: length)
            }()

            inlineRanges[name] = rangeToReplace
            rangesToReplace.append(rangeToReplace)
        }

        if removeFromSource {
            rangesToReplace
                    .reversed()
                    .forEach {
                        bridged = bridged.replacingCharacters(in: $0, with: "") as NSString
                    }
        }

        return (bridged as String, inlineRanges)
    }
}
