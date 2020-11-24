//
//  String+SourceKitten.swift
//  SourceKitten
//
//  Created by JP Simard on 2015-01-05.
//  Copyright (c) 2015 SourceKitten. All rights reserved.
//

import Foundation

/**
 * For "wall of asterisk" comment blocks, such as this one.
 */
private let commentLinePrefixCharacterSet: CharacterSet = {
    var characterSet = CharacterSet.whitespacesAndNewlines
    characterSet.insert(charactersIn: "*")
    return characterSet
}()

// swiftlint:disable:next line_length
// https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/LexicalStructure.html#//apple_ref/swift/grammar/line-break
private let newlinesCharacterSet = CharacterSet(charactersIn: "\u{000A}\u{000D}")

extension String {
    internal var isFile: Bool {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: self, isDirectory: &isDirectory)
        return exists && !isDirectory.boolValue
    }

    /**
     Returns true if self is an Objective-C header file.
     */
    public func isObjectiveCHeaderFile() -> Bool {
        return ["h", "hpp", "hh"].contains(bridge().pathExtension)
    }

    /// A version of the string with backslash escapes removed.
    public var unescaped: String {
        struct UnescapingSequence: Sequence, IteratorProtocol {
            var iterator: String.Iterator

            mutating func next() -> Character? {
                guard let char = iterator.next() else { return nil }
                guard char == "\\" else { return char }
                return iterator.next()
            }
        }
        return String(UnescapingSequence(iterator: makeIterator()))
    }

    /**
     Returns true if self is a Swift file.
     */
    public func isSwiftFile() -> Bool {
        return bridge().pathExtension == "swift"
    }

    /**
     Returns the body of the comment if the string is a comment.

     - parameter range: Range to restrict the search for a comment body.
     */
    public func commentBody(range: NSRange? = nil) -> String? {
        let nsString = bridge()
        let patterns: [(pattern: String, options: NSRegularExpression.Options)] = [
            ("^\\s*\\/\\*\\*\\s*(.*?)\\*\\/", [.anchorsMatchLines, .dotMatchesLineSeparators]), // multi: ^\s*\/\*\*\s*(.*?)\*\/
            ("^\\s*\\/\\/\\/(.+)?",           .anchorsMatchLines)                               // single: ^\s*\/\/\/(.+)?
            // swiftlint:disable:previous comma
        ]
        let range = range ?? NSRange(location: 0, length: nsString.length)
        for pattern in patterns {
            let regex = try! NSRegularExpression(pattern: pattern.pattern, options: pattern.options) // Safe to force try
            let matches = regex.matches(in: self, options: [], range: range)
            let bodyParts = matches.flatMap { match -> [String] in
                let numberOfRanges = match.numberOfRanges
                if numberOfRanges < 1 {
                    return []
                }
                return (1..<numberOfRanges).map { rangeIndex in
                    let range = match.range(at: rangeIndex)
                    if range.location == NSNotFound {
                        return "" // empty capture group, return empty string
                    }
                    var lineStart = 0
                    var lineEnd = nsString.length
                    let indexRange = NSRange(location: range.location, length: 0)
                    nsString.getLineStart(&lineStart, end: &lineEnd, contentsEnd: nil, for: indexRange)
                    let leadingWhitespaceCountToAdd = nsString.substring(with: NSRange(location: lineStart, length: lineEnd - lineStart))
                        .countOfLeadingCharacters(in: .whitespacesAndNewlines)
                    let leadingWhitespaceToAdd = String(repeating: " ", count: leadingWhitespaceCountToAdd)

                    let bodySubstring = nsString.substring(with: range)
                    if bodySubstring.contains("@name") {
                        return "" // appledoc directive, return empty string
                    }
                    return leadingWhitespaceToAdd + bodySubstring
                }
            }
            if !bodyParts.isEmpty {
                return bodyParts.joined(separator: "\n").bridge()
                    .trimmingTrailingCharacters(in: .whitespacesAndNewlines)
                    .removingCommonLeadingWhitespaceFromLines()
            }
        }
        return nil
    }

    /**
     Returns the number of contiguous characters at the start of `self` belonging to `characterSet`.

     - parameter characterSet: Character set to check for membership.
     */
    public func countOfLeadingCharacters(in characterSet: CharacterSet) -> Int {
        let characterSet = characterSet.bridge()
        var count = 0
        for char in utf16 {
            if !characterSet.characterIsMember(char) {
                break
            }
            count += 1
        }
        return count
    }

    /**
     Returns a copy of `self` with the trailing contiguous characters belonging to `characterSet`
     removed.

     - parameter characterSet: Character set to check for membership.
     */
    public func trimmingTrailingCharacters(in characterSet: CharacterSet) -> String {
        guard !isEmpty else {
            return ""
        }
        var unicodeScalars = self.bridge().unicodeScalars
        while let scalar = unicodeScalars.last {
            if !characterSet.contains(scalar) {
                return String(unicodeScalars)
            }
            unicodeScalars.removeLast()
        }
        return ""
    }

    /// Returns a copy of `self` with the leading whitespace common in each line removed.
    public func removingCommonLeadingWhitespaceFromLines() -> String {
        var minLeadingCharacters = Int.max

        let lineComponents = components(separatedBy: newlinesCharacterSet)

        for line in lineComponents {
            let lineLeadingWhitespace = line.countOfLeadingCharacters(in: .whitespacesAndNewlines)
            let lineLeadingCharacters = line.countOfLeadingCharacters(in: commentLinePrefixCharacterSet)
            // Is this prefix smaller than our last and not entirely whitespace?
            if lineLeadingCharacters < minLeadingCharacters && lineLeadingWhitespace != line.count {
                minLeadingCharacters = lineLeadingCharacters
            }
        }

        return lineComponents.map { line in
            if line.count >= minLeadingCharacters {
                return String(line[line.index(line.startIndex, offsetBy: minLeadingCharacters)...])
            }
            return line
        }.joined(separator: "\n")
    }

    internal func capitalizingFirstLetter() -> String {
        return String(prefix(1)).capitalized + String(dropFirst())
    }

}

extension NSString {

    /**
     Returns self represented as an absolute path.

     - parameter rootDirectory: Absolute parent path if not already an absolute path.
     */
    public func absolutePathRepresentation(rootDirectory: String = FileManager.default.currentDirectoryPath) -> String {
        if isAbsolutePath { return bridge() }
        #if os(Linux)
        return NSURL(fileURLWithPath: NSURL.fileURL(withPathComponents: [rootDirectory, bridge()])!.path).standardizingPath!.path
        #else
        return NSString.path(withComponents: [rootDirectory, bridge()]).bridge().standardizingPath
        #endif
    }

}

extension Array where Element == String {
    /// Return the full list of compiler arguments, replacing any response files with their contents.
    var expandingResponseFiles: [String] {
        return flatMap { arg -> [String] in
            guard arg.starts(with: "@") else {
                return [arg]
            }
            let responseFile = String(arg.dropFirst())
            return (try? String(contentsOf: URL(fileURLWithPath: responseFile))).flatMap {
                $0.trimmingCharacters(in: .newlines)
                    .components(separatedBy: "\n")
                    .map { $0.unescaped }
                    .expandingResponseFiles
            } ?? [arg]
        }
    }
}

extension String {
    /// Returns a copy of the string by trimming whitespace and the opening curly brace (`{`).
    internal func trimmingWhitespaceAndOpeningCurlyBrace() -> String? {
        var unwantedSet = CharacterSet.whitespacesAndNewlines
        unwantedSet.insert(charactersIn: "{")
        return trimmingCharacters(in: unwantedSet)
    }

    /// Returns the byte offset of the section of the string following the last dot ".", or 0 if no dots.
    internal func byteOffsetOfInnerTypeName() -> ByteCount {
        return range(of: ".", options: .backwards).map { range in
            return ByteCount(self[...range.lowerBound].lengthOfBytes(using: .utf8))
        } ?? 0
    }
}
