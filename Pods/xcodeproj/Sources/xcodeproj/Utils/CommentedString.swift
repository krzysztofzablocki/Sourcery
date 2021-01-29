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

    /// Set of characters that are invalid.
    private static var invalidCharacters: CharacterSet = {
        var invalidSet = CharacterSet(charactersIn: "_$")
        invalidSet.insert(charactersIn: UnicodeScalar(".") ... UnicodeScalar("9"))
        invalidSet.insert(charactersIn: UnicodeScalar("A") ... UnicodeScalar("Z"))
        invalidSet.insert(charactersIn: UnicodeScalar("a") ... UnicodeScalar("z"))
        invalidSet.invert()
        return invalidSet
    }()

    /// Substrings that cause Xcode to quote the string content.
    ///
    /// Matches the strings `___` and `//`.
    private let invalidStrings: Trie = [
        "_": ["_": "_"],
        "/": "/"
    ]

    /// A tree of characters to efficiently match string prefixes.
    private enum Trie: ExpressibleByDictionaryLiteral, ExpressibleByUnicodeScalarLiteral {
        case match
        case next([(UnicodeScalar, Trie)])

        init(dictionaryLiteral elements: (UnicodeScalar, Trie)...) {
            self = .next(elements)
        }

        init(unicodeScalarLiteral value: UnicodeScalar) {
            self = .next([(value, .match)])
        }

        /// Accepts a character and mutates to the subtree of strings which match that character. If the character does
        /// not match, resets to `default`.
        mutating func match(_ character: UnicodeScalar, orResetTo default: Trie) {
            switch self {
            case .match:
                return
            case .next(let options):
                for (key, subtrie) in options where key == character {
                    self = subtrie
                    return
                }
                self = `default`
            }
        }

        var accepted: Bool {
            switch self {
            case .match: return true
            case .next: return false
            }
        }
    }

    /// Returns a valid string for Xcode projects.
    var validString: String {
        switch string {
        case "": return "\"\""
        case "false": return "NO"
        case "true": return "YES"
        default: break
        }

        var needsQuoting = false
        var matchingInvalidPrefix: Trie = self.invalidStrings

        let escaped = string.reduce(into: "") { escaped, character in
            quote: if !needsQuoting {
                for scalar in character.unicodeScalars {
                    matchingInvalidPrefix.match(scalar, orResetTo: self.invalidStrings)
                    if matchingInvalidPrefix.accepted || CommentedString.invalidCharacters.contains(scalar) {
                        needsQuoting = true
                        break quote
                    }
                }
            }
            // As an optimization, only look at the first scalar. This means we're doing a numeric comparison instead
            // of comparing arbitrary-length characters. This is safe because all our cases are a single scalar.
            switch character.unicodeScalars.first {
            case "\\":
                escaped.append("\\\\")
            case "\"":
                escaped.append("\\\"")
            case "\t":
                escaped.append("\\t")
            case "\n":
                escaped.append("\\n")
            default:
                escaped.append(character)
            }
        }
        if needsQuoting {
            return "\"\(escaped)\""
        }
        return escaped
    }
}

// MARK: - Hashable

extension CommentedString: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(string)
    }

    static func == (lhs: CommentedString, rhs: CommentedString) -> Bool {
        lhs.string == rhs.string && lhs.comment == rhs.comment
    }
}

// MARK: - ExpressibleByStringLiteral

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
