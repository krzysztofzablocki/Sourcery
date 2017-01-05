extension String {

    /// Wraps brackets if needed to make a valid type name
    func bracketsBalancing() -> String {
        let wrapped = "(\(self))"
        return wrapped.isValidTupleName() || !bracketsBalanced() ? wrapped : self
    }

    /// Returns true if given string can represent a valid tuple type name
    func isValidTupleName() -> Bool {
        guard hasPrefix("(") && hasSuffix(")") else { return false }
        let trimmedBracketsName = String(characters.dropFirst().dropLast())
        return trimmedBracketsName.bracketsBalanced() && trimmedBracketsName.commaSeparated().count > 1
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
        return components(separatedBy: ",", excludingDelimiterBetween: ("<(", ")>"))
    }

    /// Returns components separated with colon respecting nested types
    func colonSeparated() -> [String] {
        return components(separatedBy: ":", excludingDelimiterBetween: ("<[(", ")]>"))
    }

    func components(separatedBy delimiter: Character, excludingDelimiterBetween between: (open: String, close: String)) -> [String] {
        var boundingCharactersCount: Int = 0
        var item = ""
        var items = [String]()
        for char in characters {
            if between.open.characters.contains(char) {
                boundingCharactersCount += 1
            } else if between.close.characters.contains(char) {
                boundingCharactersCount -= 1
            }
            if char == delimiter && boundingCharactersCount == 0 {
                items.append(item)
                item = ""
            } else {
                item.append(char)
            }
        }
        items.append(item)
        return items
    }

}
