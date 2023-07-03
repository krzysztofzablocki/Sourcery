import Foundation
import SwiftSyntax

// Represents the number of bytes in a string. Could be used to model offsets into a string, or the distance between
/// two locations in a string.
public struct ByteCount: ExpressibleByIntegerLiteral, Hashable {
    /// The byte value as an integer.
    public var value: Int

    /// Create a byte count by its integer value.
    ///
    /// - parameter value: Integer value.
    public init(integerLiteral value: Int) {
        self.value = value
    }

    /// Create a byte count by its integer value.
    ///
    /// - parameter value: Integer value.
    public init(_ value: Int) {
        self.value = value
    }

    /// Create a byte count by its integer value.
    ///
    /// - parameter value: Integer value.
    public init(_ value: Int64) {
        self.value = Int(value)
    }
}

extension ByteCount: CustomStringConvertible {
    public var description: String {
        return value.description
    }
}

extension ByteCount: Comparable {
    public static func < (lhs: ByteCount, rhs: ByteCount) -> Bool {
        return lhs.value < rhs.value
    }
}

extension ByteCount: AdditiveArithmetic {
    public static func - (lhs: ByteCount, rhs: ByteCount) -> ByteCount {
        return ByteCount(lhs.value - rhs.value)
    }

    public static func -= (lhs: inout ByteCount, rhs: ByteCount) {
        lhs.value -= rhs.value
    }

    public static func + (lhs: ByteCount, rhs: ByteCount) -> ByteCount {
        return ByteCount(lhs.value + rhs.value)
    }

    public static func += (lhs: inout ByteCount, rhs: ByteCount) {
        lhs.value += rhs.value
    }
}

/// Structure that represents a string range in bytes.
public struct ByteRange: Equatable {
    /// The starting location of the range.
    public let location: ByteCount

    /// The length of the range.
    public let length: ByteCount

    /// Creates a byte range from a location and a length.
    ///
    /// - parameter location: The starting location of the range.
    /// - parameter length:   The length of the range.
    public init(location: ByteCount, length: ByteCount) {
        self.location = location
        self.length = length
    }

    /// The range's upper bound.
    public var upperBound: ByteCount {
        return location + length
    }

    /// The range's lower bound.
    public var lowerBound: ByteCount {
        return location
    }

    public func contains(_ value: ByteCount) -> Bool {
        return location <= value && upperBound > value
    }

    public func intersects(_ otherRange: ByteRange) -> Bool {
        return contains(otherRange.lowerBound) ||
            contains(otherRange.upperBound - 1) ||
            otherRange.contains(lowerBound) ||
            otherRange.contains(upperBound - 1)
    }

    public func intersects(_ ranges: [ByteRange]) -> Bool {
        return ranges.contains { intersects($0) }
    }

    public func union(with otherRange: ByteRange) -> ByteRange {
        let maxUpperBound = max(upperBound, otherRange.upperBound)
        let minLocation = min(location, otherRange.location)
        return ByteRange(location: minLocation, length: maxUpperBound - minLocation)
    }

    /*
     Returns a new range which is the receiver after inserting or removing some content
     before, within or after the receiver.
     change.length is amount of content inserted or removed.
    */
    public func editingContent(_ change: ByteRange) -> ByteRange {
        // bytes inserted after type definition
        if change.location > upperBound {
            return self
        }
        // bytes inserted within type definition
        if change.location >= location {
            return ByteRange(location: location, length: length + change.length)
        }
        // bytes inserted before type definition
        return ByteRange(location: location + change.length, length: length)
    }
}

/// Representation of a single line in a larger String.
public struct Line {
    /// origin = 0.
    public let index: Int
    /// Content.
    public let content: String
    /// UTF16 based range in entire String. Equivalent to `Range<UTF16Index>`.
    public let range: NSRange
    /// Byte based range in entire String. Equivalent to `Range<UTF8Index>`.
    public let byteRange: ByteRange
}

private extension RandomAccessCollection {
    /// Binary search assuming the collection is already sorted.
    ///
    /// - parameter comparing: Comparison function.
    ///
    /// - returns: The index in the collection of the element matching the `comparing` function.
    func indexAssumingSorted(comparing: (Element) throws -> ComparisonResult) rethrows -> Index? {
        guard !isEmpty else {
            return nil
        }

        var lowerBound = startIndex
        var upperBound = index(before: endIndex)
        var midIndex: Index

        while lowerBound <= upperBound {
            let boundDistance = distance(from: lowerBound, to: upperBound)
            midIndex = index(lowerBound, offsetBy: boundDistance / 2)
            let midElem = self[midIndex]

            switch try comparing(midElem) {
            case .orderedDescending: lowerBound = index(midIndex, offsetBy: 1)
            case .orderedAscending: upperBound = index(midIndex, offsetBy: -1)
            case .orderedSame: return midIndex
            }
        }

        return nil
    }
}

// swiftlint:disable:next line_length
// According to https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/LexicalStructure.html#//apple_ref/swift/grammar/line-break
// there are 3 types of line breaks:
// line-break → U+000A
// line-break → U+000D
// line-break → U+000D followed by U+000A
private let carriageReturnCharacter = "\u{000D}"
private let lineFeedCharacter = "\u{000A}"
private let newlinesCharacters = carriageReturnCharacter + lineFeedCharacter

/// Structure that precalculates lines for the specified string and then uses this information for
/// ByteRange to NSRange and NSRange to ByteRange operations
public struct StringView {

    /// Reference to the NSString of represented string
    public let nsString: NSString

    /// Full range of nsString
    public let range: NSRange

    /// Reference to the String of the represented string
    public let string: String

    /// All lines of the original string
    public let lines: [Line]

    let utf8View: String.UTF8View
    let utf16View: String.UTF16View

    public init(_ string: String) {
        self.init(string, string as NSString)
    }

    public init(_ nsstring: NSString) {
        self.init(nsstring as String, nsstring)
    }

    // parses the given string into lines. Lines are split using
    //
    /*
     //sourcery: Annotation\n
     @MainActor\r\n
     protocol Something {\r\n
       var variable: Bool { get }\r\n
     }\n

     First iteration:

     [
      "//sourcery: Annotation\n",
      "@MainActor",
      "protocol Something {",
      "  var variable: Bool { get }",
      "}\n"
     ]

     Second iteration:

     [
      "//sourcery: Annotation",
      "",
      "@MainActor",
      "protocol Something {",
      "  var variable: Bool { get }",
      "}",
      ""
     ]
     */
    private init(_ string: String, _ nsString: NSString) {
        self.string = string
        self.nsString = nsString
        self.range = NSRange(location: 0, length: nsString.length)

        utf8View = string.utf8
        utf16View = string.utf16

        var utf16CountSoFar = 0
        var bytesSoFar: ByteCount = 0
        var lines = [Line]()

        let lineContents = string.components(separatedBy: newlinesCharacters)
            .expandComponents(splitBy: lineFeedCharacter)

        // Be compatible with `NSString.getLineStart(_:end:contentsEnd:forRange:)`
        let endsWithNewLineCharacter: Bool
        if let lastChar = utf16View.last,
            let lastCharScalar = UnicodeScalar(lastChar) {
            endsWithNewLineCharacter = newlinesCharacters.contains(Character(lastCharScalar))
        } else {
            endsWithNewLineCharacter = false
        }
        // if string ends with new line character, no empty line is generated after that.
        let enumerator = endsWithNewLineCharacter
            ? AnySequence(lineContents.dropLast().enumerated())
            : AnySequence(lineContents.enumerated())
        for (index, content) in enumerator {
            let index = index + 1
            let rangeStart = utf16CountSoFar
            let utf16Count = content.utf16.count
            utf16CountSoFar += utf16Count

            let byteRangeStart = bytesSoFar
            let byteCount = ByteCount(content.lengthOfBytes(using: .utf8))
            bytesSoFar += byteCount

            let newlineLength = index != lineContents.count ? 1 : 0 // FIXME: assumes \n

            let line = Line(
                index: index,
                content: content,
                range: NSRange(location: rangeStart, length: utf16Count + newlineLength),
                byteRange: ByteRange(location: byteRangeStart, length: byteCount + ByteCount(newlineLength))
            )
            lines.append(line)

            utf16CountSoFar += newlineLength
            bytesSoFar += ByteCount(newlineLength)
        }
        self.lines = lines
    }

    /// Returns substring in with UTF-16 range specified.
    ///
    /// - parameter range: UTF16 range.
    public func substring(with range: NSRange) -> String {
        return nsString.substring(with: range)
    }

    /**
     Returns a substring from a start and end SourceLocation.
     */
    public func substringWithSourceRange(start: SourceLocation, end: SourceLocation) -> String? {
        guard start.offset < end.offset else {
            return nil
        }
        let byteRange = ByteRange(location: ByteCount(Int(start.offset)),
                                  length: ByteCount(Int(end.offset - start.offset)))
        return substringWithByteRange(byteRange)
    }


    /**
     Returns a substring with the provided byte range.

     - parameter start: Starting byte offset.
     - parameter length: Length of bytes to include in range.
     */
    public func substringWithByteRange(_ byteRange: ByteRange) -> String? {
        return byteRangeToNSRange(byteRange).map(nsString.substring)
    }

    /// Returns a substictg, started at UTF-16 location.
    ///
    /// - parameter location: UTF-16 location.
    func substring(from location: Int) -> String {
        return nsString.substring(from: location)
    }

    /**
     Converts a range of byte offsets in `self` to an `NSRange` suitable for filtering `self` as an
     `NSString`.

     - parameter start: Starting byte offset.
     - parameter length: Length of bytes to include in range.

     - returns: An equivalent `NSRange`.
     */
    public func byteRangeToNSRange(_ byteRange: ByteRange) -> NSRange? {
        guard !string.isEmpty else { return nil }
        let utf16Start = location(fromByteOffset: byteRange.location)
        if byteRange.length == 0 {
            return NSRange(location: utf16Start, length: 0)
        }
        let utf16End = location(fromByteOffset: byteRange.upperBound)
        return NSRange(location: utf16Start, length: utf16End - utf16Start)
    }

    /**
     Returns UTF8 offset from UTF16 offset.

     - parameter location: UTF16-based offset of string.

     - returns: UTF8 based offset of string.
     */
    public func byteOffset(fromLocation location: Int) -> ByteCount {
        if lines.isEmpty {
            return 0
        }
        let index = lines.indexAssumingSorted { line in
            if location < line.range.location {
                return .orderedAscending
            } else if location >= line.range.location + line.range.length {
                return .orderedDescending
            }
            return .orderedSame
        }
        // location may be out of bounds when NSRegularExpression points end of string.
        guard let line = (index.map { lines[$0] } ?? lines.last) else {
            fatalError()
        }
        let diff = location - line.range.location
        if diff == 0 {
            return line.byteRange.location
        } else if line.range.length == diff {
            return line.byteRange.upperBound
        }
        let utf16View = line.content.utf16
        let endUTF8index = utf16View.index(utf16View.startIndex, offsetBy: diff, limitedBy: utf16View.endIndex)!
            .samePosition(in: line.content.utf8)!
        let byteDiff = line.content.utf8.distance(from: line.content.utf8.startIndex, to: endUTF8index)
        return ByteCount(line.byteRange.location.value + byteDiff)
    }

    /**
    Converts an `NSRange` suitable for filtering `self` as an
    `NSString` to a range of byte offsets in `self`.

    - parameter start: Starting character index in the string.
    - parameter length: Number of characters to include in range.

    - returns: An equivalent `NSRange`.
    */
    public func NSRangeToByteRange(start: Int, length: Int) -> ByteRange? {
        let startUTF16Index = utf16View.index(utf16View.startIndex, offsetBy: start)
        let endUTF16Index = utf16View.index(startUTF16Index, offsetBy: length)

        guard let startUTF8Index = startUTF16Index.samePosition(in: utf8View),
            let endUTF8Index = endUTF16Index.samePosition(in: utf8View) else {
                return nil
        }

        let length = utf8View.distance(from: startUTF8Index, to: endUTF8Index)
        return ByteRange(location: byteOffset(fromLocation: start), length: ByteCount(length))
    }

    public func NSRangeToByteRange(_ range: NSRange) -> ByteRange? {
        return NSRangeToByteRange(start: range.location, length: range.length)
    }

    /**
     Returns UTF16 offset from UTF8 offset.

     - parameter byteOffset: UTF8-based offset of string.

     - returns: UTF16 based offset of string.
     */
    public func location(fromByteOffset byteOffset: ByteCount) -> Int {
        if lines.isEmpty {
            return 0
        }
        let index = lines.indexAssumingSorted { line in
            if byteOffset < line.byteRange.location {
                return .orderedAscending
            } else if byteOffset >= line.byteRange.upperBound {
                return .orderedDescending
            }
            return .orderedSame
        }
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
        let endUTF8Index = utf8View.index(utf8View.startIndex, offsetBy: diff.value, limitedBy: utf8View.endIndex) ?? utf8View.endIndex
        let utf16Diff = line.content.utf16.distance(from: line.content.utf16.startIndex, to: endUTF8Index)
        return line.range.location + utf16Diff
    }

    public func substringStartingLinesWithByteRange(_ byteRange: ByteRange) -> String? {
        return byteRangeToNSRange(byteRange).map { range in
            var lineStart = 0, lineEnd = 0
            nsString.getLineStart(&lineStart, end: &lineEnd, contentsEnd: nil, for: range)
            return nsString.substring(with: NSRange(location: lineStart, length: NSMaxRange(range) - lineStart))
        }
    }

    /**
     Returns a substring starting at the beginning of `start`'s line and ending at the end of `end`'s
     line. Returns `start`'s entire line if `end` is nil.

     - parameter start: Starting byte offset.
     - parameter length: Length of bytes to include in range.
     */
    public func substringLinesWithByteRange(_ byteRange: ByteRange) -> String? {
        return byteRangeToNSRange(byteRange).map { range in
            var lineStart = 0, lineEnd = 0
            nsString.getLineStart(&lineStart, end: &lineEnd, contentsEnd: nil, for: range)
            return nsString.substring(with: NSRange(location: lineStart, length: lineEnd - lineStart))
        }
    }

    /**
     Returns line numbers containing starting and ending byte offsets.

     - parameter start: Starting byte offset.
     - parameter length: Length of bytes to include in range.
     */
    public func lineRangeWithByteRange(_ byteRange: ByteRange) -> (start: Int, end: Int)? {
        return byteRangeToNSRange(byteRange).flatMap { range in
            var numberOfLines = 0, index = 0, lineRangeStart = 0
            while index < nsString.length {
                numberOfLines += 1
                if index <= range.location {
                    lineRangeStart = numberOfLines
                }
                index = NSMaxRange(nsString.lineRange(for: NSRange(location: index, length: 1)))
                if index > NSMaxRange(range) {
                    return (lineRangeStart, numberOfLines)
                }
            }
            return nil
        }
    }

    public func lineAndCharacter(forByteOffset offset: ByteCount, expandingTabsToWidth tabWidth: Int = 1) -> (line: Int, character: Int)? {
        let characterOffset = location(fromByteOffset: offset)
        return lineAndCharacter(forCharacterOffset: characterOffset, expandingTabsToWidth: tabWidth)
    }

    public func lineAndCharacter(forCharacterOffset offset: Int, expandingTabsToWidth tabWidth: Int = 1) -> (line: Int, character: Int)? {
        assert(tabWidth > 0)

        let index = lines.indexAssumingSorted { line in
            if offset < line.range.location {
                return .orderedAscending
            } else if offset >= line.range.location + line.range.length {
                return .orderedDescending
            }
            return .orderedSame
        }
        return index.map {
            let line = lines[$0]

            let prefixLength = offset - line.range.location
            let character: Int

            if tabWidth == 1 {
                character = prefixLength
            } else {
                character = line.content.prefix(prefixLength).reduce(0) { sum, character in
                    if character == "\t" {
                        return sum - (sum % tabWidth) + tabWidth
                    } else {
                        return sum + 1
                    }
                }
            }

            return (line: line.index, character: character + 1)
        }
    }

}

private extension Array where Element == String {
    func expandComponents(splitBy separator: String) -> [String] {
        flatMap { $0.components(separatedBy: separator) }
    }
}
