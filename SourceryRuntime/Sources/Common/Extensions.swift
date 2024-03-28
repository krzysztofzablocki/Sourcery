import Foundation

public extension StringProtocol {
    /// Trimms leading and trailing whitespaces and newlines
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

public extension String {

    /// Returns nil if string is empty
    var nilIfEmpty: String? {
        if isEmpty {
            return nil
        }

        return self
    }

    /// Returns nil if string is empty or contains `_` character
    var nilIfNotValidParameterName: String? {
        if isEmpty {
            return nil
        }

        if self == "_" {
            return nil
        }

        return self
    }

    /// :nodoc:
    /// - Parameter substring: Instance of a substring
    /// - Returns: Returns number of times a substring appears in self
    func countInstances(of substring: String) -> Int {
        guard !substring.isEmpty else { return 0 }
        var count = 0
        var searchRange: Range<String.Index>?
        while let foundRange = range(of: substring, options: [], range: searchRange) {
            count += 1
            searchRange = Range(uncheckedBounds: (lower: foundRange.upperBound, upper: endIndex))
        }
        return count
    }

    /// :nodoc:
    /// Removes leading and trailing whitespace from str. Returns false if str was not altered.
    @discardableResult
    mutating func strip() -> Bool {
        let strippedString = stripped()
        guard strippedString != self else { return false }
        self = strippedString
        return true
    }

    /// :nodoc:
    /// Returns a copy of str with leading and trailing whitespace removed.
    func stripped() -> String {
        return String(self.trimmingCharacters(in: .whitespaces))
    }

    /// :nodoc:
    @discardableResult
    mutating func trimPrefix(_ prefix: String) -> Bool {
        guard hasPrefix(prefix) else { return false }
        self = String(self.suffix(self.count - prefix.count))
        return true
    }

    /// :nodoc:
    func trimmingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(self.suffix(self.count - prefix.count))
    }

    /// :nodoc:
    @discardableResult
    mutating func trimSuffix(_ suffix: String) -> Bool {
        guard hasSuffix(suffix) else { return false }
        self = String(self.prefix(self.count - suffix.count))
        return true
    }

    /// :nodoc:
    func trimmingSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }
        return String(self.prefix(self.count - suffix.count))
    }

    /// :nodoc:
    func dropFirstAndLast(_ n: Int = 1) -> String {
        return drop(first: n, last: n)
    }

    /// :nodoc:
    func drop(first: Int, last: Int) -> String {
        return String(self.dropFirst(first).dropLast(last))
    }

    /// :nodoc:
    /// Wraps brackets if needed to make a valid type name
    func bracketsBalancing() -> String {
        if hasPrefix("(") && hasSuffix(")") {
            let unwrapped = dropFirstAndLast()
            return unwrapped.commaSeparated().count == 1 ? unwrapped.bracketsBalancing() : self
        } else {
            let wrapped = "(\(self))"
            return wrapped.isValidTupleName() || !isBracketsBalanced() ? wrapped : self
        }
    }

    /// :nodoc:
    /// Returns true if given string can represent a valid tuple type name
    func isValidTupleName() -> Bool {
        guard hasPrefix("(") && hasSuffix(")") else { return false }
        let trimmedBracketsName = dropFirstAndLast()
        return trimmedBracketsName.isBracketsBalanced() && trimmedBracketsName.commaSeparated().count > 1
    }

    /// :nodoc:
    func isValidArrayName() -> Bool {
        if hasPrefix("Array<") { return true }
        if hasPrefix("[") && hasSuffix("]") {
            return dropFirstAndLast().colonSeparated().count == 1
        }
        return false
    }

    /// :nodoc:
    func isValidDictionaryName() -> Bool {
        if hasPrefix("Dictionary<") { return true }
        if hasPrefix("[") && contains(":") && hasSuffix("]") {
            return dropFirstAndLast().colonSeparated().count == 2
        }
        return false
    }

    /// :nodoc:
    func isValidClosureName() -> Bool {
        return components(separatedBy: "->", excludingDelimiterBetween: (["(", "<"], [")", ">"])).count > 1
    }

    /// :nodoc:
    /// Returns true if all opening brackets are balanced with closed brackets.
    func isBracketsBalanced() -> Bool {
        var bracketsCount: Int = 0
        for char in self {
            if char == "(" { bracketsCount += 1 } else if char == ")" { bracketsCount -= 1 }
            if bracketsCount < 0 { return false }
        }
        return bracketsCount == 0
    }

    /// :nodoc:
    /// Returns components separated with a comma respecting nested types
    func commaSeparated() -> [String] {
        return components(separatedBy: ",", excludingDelimiterBetween: ("<[({", "})]>"))
    }

    /// :nodoc:
    /// Returns components separated with colon respecting nested types
    func colonSeparated() -> [String] {
        return components(separatedBy: ":", excludingDelimiterBetween: ("<[({", "})]>"))
    }

    /// :nodoc:
    /// Returns components separated with semicolon respecting nested contexts
    func semicolonSeparated() -> [String] {
        return components(separatedBy: ";", excludingDelimiterBetween: ("{", "}"))
    }

    /// :nodoc:
    func components(separatedBy delimiter: String, excludingDelimiterBetween between: (open: String, close: String)) -> [String] {
        return self.components(separatedBy: delimiter, excludingDelimiterBetween: (between.open.map { String($0) }, between.close.map { String($0) }))
    }

    /// :nodoc:
    func components(separatedBy delimiter: String, excludingDelimiterBetween between: (open: [String], close: [String])) -> [String] {
        var boundingCharactersCount: Int = 0
        var quotesCount: Int = 0
        var item = ""
        var items = [String]()

        var i = self.startIndex
        while i < self.endIndex {
            var offset = 1
            defer {
                i = self.index(i, offsetBy: offset)
            }
            var currentlyScannedEnd: Index = self.endIndex
            if let endIndex = self.index(i, offsetBy: delimiter.count, limitedBy: self.endIndex) {
                currentlyScannedEnd = endIndex
            }
            let currentlyScanned: String = String(self[i..<currentlyScannedEnd])
            if let openString = between.open.first(where: { self[i...].starts(with: $0) }) {
                if !((boundingCharactersCount == 0) as Bool && (String(self[i]) == delimiter) as Bool) {
                    boundingCharactersCount += 1
                }
                offset = openString.count
            } else if let closeString = between.close.first(where: { self[i...].starts(with: $0) }) {
                // do not count `->`
                if !((self[i] == ">") as Bool && (item.last == "-") as Bool) {
                    boundingCharactersCount = max(0, boundingCharactersCount - 1)
                }
                offset = closeString.count
            }
            if (self[i] == "\"") as Bool {
                quotesCount += 1
            }

            let currentIsDelimiter = (currentlyScanned == delimiter) as Bool
            let boundingCountIsZero = (boundingCharactersCount == 0) as Bool
            let hasEvenQuotes = (quotesCount % 2 == 0) as Bool
            if currentIsDelimiter && boundingCountIsZero && hasEvenQuotes {
                items.append(item)
                item = ""
                i = self.index(i, offsetBy: delimiter.count - 1)
            } else {
                let endIndex: Index = self.index(i, offsetBy: offset)
                item += self[i..<endIndex]
            }
        }
        items.append(item)
        return items
    }
}

public extension NSString {
    /// :nodoc:
    var entireRange: NSRange {
        return NSRange(location: 0, length: self.length)
    }
}
