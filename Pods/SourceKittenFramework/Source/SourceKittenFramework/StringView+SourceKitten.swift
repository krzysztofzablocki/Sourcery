import Foundation

public extension StringView {
    /**
     Returns whether or not the `token` can be documented. Either because it is a
     `SyntaxKind.Identifier` or because it is a function treated as a `SyntaxKind.Keyword`:

     - `subscript`
     - `init`
     - `deinit`

     - parameter token: Token to process.
     */
    func isTokenDocumentable(token: SyntaxToken) -> Bool {
        if token.type == SyntaxKind.keyword.rawValue {
            let keywordFunctions = ["subscript", "init", "deinit"]
            return substringWithByteRange(token.range)
                .map(keywordFunctions.contains) ?? false
        }
        return token.type == SyntaxKind.identifier.rawValue
    }

#if !os(Linux)
    /// Returns the `#pragma mark`s in the string.
    /// Just the content; no leading dashes or leading `#pragma mark`.
    func pragmaMarks(filename: String, excludeRanges: [NSRange], limit: NSRange?) -> [SourceDeclaration] {
        let regex = try! NSRegularExpression(pattern: "(#pragma\\smark|@name)[ -]*([^\\n]+)", options: []) // Safe to force try
        let range: NSRange
        if let limit = limit {
            range = NSRange(location: limit.location, length: min(utf16View.count - limit.location, limit.length))
        } else {
            range = NSRange(location: 0, length: utf16View.count)
        }
        let matches = regex.matches(in: string, options: [], range: range)

        return matches.compactMap { match in
            let markRange = match.range(at: 2)
            for excludedRange in excludeRanges {
                if NSIntersectionRange(excludedRange, markRange).length > 0 {
                    return nil
                }
            }
            let markString = nsString.substring(with: markRange).trimmingCharacters(in: .whitespaces)
            if markString.isEmpty {
                return nil
            }
            guard let markByteRange = self.NSRangeToByteRange(start: markRange.location, length: markRange.length) else {
                return nil
            }
            let location = SourceLocation(file: filename,
                                          line: UInt32(lineRangeWithByteRange(ByteRange(location: markByteRange.location, length: 0))!.start),
                                          column: 1, offset: UInt32(markByteRange.location.value))
            return SourceDeclaration(type: .mark, location: location, extent: (location, location), name: markString,
                                     usr: nil, declaration: nil, documentation: nil, commentBody: nil, children: [],
                                     annotations: nil, swiftDeclaration: nil, swiftName: nil, availability: nil)
        }
    }
#endif

    /**
     Find integer offsets of documented Swift tokens in self.

     - parameter syntaxMap: Syntax Map returned from SourceKit editor.open request.

     - returns: Array of documented token offsets.
     */
    func documentedTokenOffsets(syntaxMap: SyntaxMap) -> [ByteCount] {
        let documentableOffsets = syntaxMap.tokens.filter(isTokenDocumentable).map {
            $0.offset
        }

        let regex = try! NSRegularExpression(pattern: "(///.*\\n|\\*/\\n)", options: []) // Safe to force try
        let range = NSRange(location: 0, length: string.utf16.count)
        let matches = regex.matches(in: string, options: [], range: range)

        return matches.compactMap { match in
            return NSRangeToByteRange(match.range)
        }
        .compactMap { byteRange in
            documentableOffsets.first { $0 >= byteRange.location }
        }
    }
}
