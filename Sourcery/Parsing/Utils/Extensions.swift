import Foundation

extension String {

    @discardableResult
    mutating func trimPrefix(_ prefix: String) -> Bool {
        guard hasPrefix(prefix) else { return false }
        self = String(characters.suffix(characters.count - prefix.characters.count))
        return true
    }

    func trimmingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(characters.suffix(characters.count - prefix.characters.count))
    }

    func trimmingSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }
        return String(characters.prefix(characters.count - suffix.characters.count))
    }

    func dropFirst(_ n: Int = 1) -> String {
        return String(characters.dropFirst(n))
    }

    func dropLast(_ n: Int = 1) -> String {
        return String(characters.dropLast(n))
    }

    func dropFirstAndLast(_ n: Int = 1) -> String {
        return drop(first: n, last: n)
    }

    func drop(first: Int, last: Int) -> String {
        return String(characters.dropFirst(first).dropLast(last))
    }

    /// Wraps brackets if needed to make a valid type name
    func bracketsBalancing() -> String {
        if hasPrefix("(") && hasSuffix(")") {
            let unwrapped = dropFirstAndLast()
            return unwrapped.commaSeparated().count == 1 ? unwrapped.bracketsBalancing() : self
        } else {
            let wrapped = "(\(self))"
            return wrapped.isValidTupleName() || !bracketsBalanced() ? wrapped : self
        }
    }

    /// Returns true if given string can represent a valid tuple type name
    func isValidTupleName() -> Bool {
        guard hasPrefix("(") && hasSuffix(")") else { return false }
        let trimmedBracketsName = dropFirstAndLast()
        return trimmedBracketsName.bracketsBalanced() && trimmedBracketsName.commaSeparated().count > 1
    }

    func isValidArrayName() -> Bool {
        if hasPrefix("Array<") { return true }
        if hasPrefix("[") && hasSuffix("]") {
            return dropFirstAndLast().colonSeparated().count == 1
        }
        return false
    }

    func isValidClosureName() -> Bool {
        return components(separatedBy: "->", excludingDelimiterBetween: ("(", ")")).count > 1
    }

    /// Returns true if all opening brackets are balanced with closed brackets.
    func bracketsBalanced() -> Bool {
        var bracketsCount: Int = 0
        for char in characters {
            if char == "(" { bracketsCount += 1 } else if char == ")" { bracketsCount -= 1 }
            if bracketsCount < 0 { return false }
        }
        return bracketsCount == 0
    }

    /// Returns components separated with a comma respecting nested types
    func commaSeparated() -> [String] {
        return components(separatedBy: ",", excludingDelimiterBetween: ("<[(", ")]>"))
    }

    /// Returns components separated with colon respecting nested types
    func colonSeparated() -> [String] {
        return components(separatedBy: ":", excludingDelimiterBetween: ("<[(", ")]>"))
    }

    /// Returns components separated with semicolon respecting nested contexts
    func semicolonSeparated() -> [String] {
        return components(separatedBy: ";", excludingDelimiterBetween: ("{", "}"))
    }

    func components(separatedBy delimiter: String, excludingDelimiterBetween between: (open: String, close: String)) -> [String] {
        var boundingCharactersCount: Int = 0
        var quotesCount: Int = 0
        var item = ""
        var items = [String]()
        var matchedDelimiter = (alreadyMatched: "", leftToMatch: delimiter)

        for char in characters {
            if between.open.characters.contains(char) {
                boundingCharactersCount += 1
            } else if between.close.characters.contains(char) {
                boundingCharactersCount = max(0, boundingCharactersCount - 1)
            }
            if char == "\"" {
                quotesCount += 1
            }

            guard boundingCharactersCount == 0 && quotesCount % 2 == 0 else {
                item.append(char)
                continue
            }

            if char == matchedDelimiter.leftToMatch.characters.first {
                matchedDelimiter.alreadyMatched.append(char)
                matchedDelimiter.leftToMatch = matchedDelimiter.leftToMatch.dropFirst()
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

extension NSString {
    var entireRange: NSRange {
        return NSRange(location: 0, length: self.length)
    }
}
