import Foundation

public extension String {

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
        return components(separatedBy: "->", excludingDelimiterBetween: ("(", ")")).count > 1
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
        return components(separatedBy: ",", excludingDelimiterBetween: ("<[(", ")]>"))
    }

    /// :nodoc:
    /// Returns components separated with colon respecting nested types
    func colonSeparated() -> [String] {
        return components(separatedBy: ":", excludingDelimiterBetween: ("<[(", ")]>"))
    }

    /// :nodoc:
    /// Returns components separated with semicolon respecting nested contexts
    func semicolonSeparated() -> [String] {
        return components(separatedBy: ";", excludingDelimiterBetween: ("{", "}"))
    }

    /// :nodoc:
    func components(separatedBy delimiter: String, excludingDelimiterBetween between: (open: String, close: String)) -> [String] {
        var boundingCharactersCount: Int = 0
        var quotesCount: Int = 0
        var item = ""
        var items = [String]()
        var matchedDelimiter = (alreadyMatched: "", leftToMatch: delimiter)

        for char in self {
            if between.open.contains(char) {
                if !(boundingCharactersCount == 0 && String(char) == delimiter) {
                    boundingCharactersCount += 1
                }
            } else if between.close.contains(char) {
                // do not count `->`
                if !(char == ">" && item.last == "-") {
                    boundingCharactersCount = max(0, boundingCharactersCount - 1)
                }
            }
            if char == "\"" {
                quotesCount += 1
            }

            guard boundingCharactersCount == 0 && quotesCount % 2 == 0 else {
                item.append(char)
                continue
            }

            if char == matchedDelimiter.leftToMatch.first {
                matchedDelimiter.alreadyMatched.append(char)
                matchedDelimiter.leftToMatch = String(matchedDelimiter.leftToMatch.dropFirst())
                if matchedDelimiter.leftToMatch.isEmpty {
                    items.append(item)
                    item = ""
                    matchedDelimiter = (alreadyMatched: "", leftToMatch: delimiter)
                }
            } else {
                if matchedDelimiter.alreadyMatched.isEmpty {
                    item.append(char)
                } else {
                    item.append(matchedDelimiter.alreadyMatched)
                    matchedDelimiter = (alreadyMatched: "", leftToMatch: delimiter)
                }
            }
        }
        items.append(item)
        return items
    }
}

public extension NSString {
    var entireRange: NSRange {
        return NSRange(location: 0, length: self.length)
    }
}
