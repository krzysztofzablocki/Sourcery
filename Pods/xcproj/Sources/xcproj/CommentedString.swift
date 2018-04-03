import Foundation

/// String that includes a comment
struct CommentedString {
    
    /// Entity string value.
    let string: String
    
    /// String comment.
    let comment: String?
    
    /// Initializes the commented string with the value and the comment.
    ///
    /// - Parameters:
    ///   - string: string value.
    ///   - comment: comment.
    init(_ string: String, comment: String? = nil) {
        self.string = string
        self.comment = comment
    }

    private static var invalidCharacters: CharacterSet = {
        var invalidSet = CharacterSet(charactersIn: "_$")
        invalidSet.insert(charactersIn: UnicodeScalar(".")...UnicodeScalar("9"))
        invalidSet.insert(charactersIn: UnicodeScalar("A")...UnicodeScalar("Z"))
        invalidSet.insert(charactersIn: UnicodeScalar("a")...UnicodeScalar("z"))
        invalidSet.invert()
        return invalidSet
    }()

    /// Substrings that cause Xcode to quote the string content.
    private let invalidStrings = [
        "___",
        "//"
    ]

    var validString: String {
        switch string {
            case "": return "".quoted
            case "false": return "NO"
            case "true": return "YES"
            default: break
        }

        var escaped = string
        // escape escape
        if escaped.contains("\\" as Character) {
            escaped = escaped.replacingOccurrences(of: "\\", with: "\\\\")
        }
        // escape quotes
        if escaped.contains("\"" as Character) {
            escaped = escaped.replacingOccurrences(of: "\"", with: "\\\"")
        }
        // escape tab
        if escaped.contains("\t" as Character) {
            escaped = escaped.replacingOccurrences(of: "\t", with: "\\t")
        }
        // escape newlines
        if escaped.contains("\n" as Character) {
            escaped = escaped.replacingOccurrences(of: "\n", with: "\\n")
        }

        if !escaped.isQuoted &&
            (escaped.rangeOfCharacter(from: CommentedString.invalidCharacters) != nil ||
            invalidStrings.contains(where: { escaped.range(of: $0) != nil })) {

            escaped = escaped.quoted
        }

        return escaped
    }
    
}

// MARK: - CommentedString Extension (Hashable)

extension CommentedString: Hashable {
    
    var hashValue: Int { return string.hashValue }
    static func == (lhs: CommentedString, rhs: CommentedString) -> Bool {
        return lhs.string == rhs.string && lhs.comment == rhs.comment
    }
    
}

// MARK: - CommentedString Extension (ExpressibleByStringLiteral)

extension CommentedString: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        self.init(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }
    
    public init(unicodeScalarLiteral value: String) {
        self.init(value)
    }
    
}
