import Foundation

/// It represents a plist value.
///
/// - string: commented string.
/// - array: array of plist values.
/// - dictionary: dictionary where the keys are a commented strings and the values are a plist values.
enum PlistValue {
    case string(CommentedString)
    case array([PlistValue])
    case dictionary([CommentedString: PlistValue])
    
    var string: (CommentedString)? {
        switch self {
        case .string(let string): return string
        default: return nil
        }
    }
    var array: [PlistValue]? {
        switch self {
        case .array(let array): return array
        default: return nil
        }
    }
    var dictionary: [CommentedString: PlistValue]? {
        switch self {
        case .dictionary(let dictionary): return dictionary
        default: return nil
        }
    }
    
}

// MARK: - PlistValue Extension (ExpressibleByArrayLiteral)

extension PlistValue: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: PlistValue...) {
        self = .array(elements)
    }
    
}

// MARK: - PlistValue Extension (ExpressibleByDictionaryLiteral)

extension PlistValue: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (CommentedString, PlistValue)...) {
        var dictionary: [CommentedString: PlistValue] = [:]
        elements.forEach { dictionary[$0.0] = $0.1 }
        self = .dictionary(dictionary)
    }
    
}

// MARK: - PlistValue Extension (ExpressibleByStringLiteral)

extension PlistValue: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        self = .string(CommentedString(value))
    }
    public init(extendedGraphemeClusterLiteral value: String) {
        self = .string(CommentedString(value))
    }
    public init(unicodeScalarLiteral value: String) {
        self = .string(CommentedString(value))
    }
    
}

// MARK: PlistValue Extension (Equatable)

extension PlistValue: Equatable {
    
    static func == (lhs: PlistValue, rhs: PlistValue) -> Bool {
        switch (lhs, rhs) {
        case (.string(let lhsString), .string(let rhsString)):
            return lhsString == rhsString
        case (.array(let lhsArray), .array(let rhsArray)):
            return lhsArray == rhsArray
        case (.dictionary(let lhsDictionary), .dictionary(let rhsDictionary)):
            return lhsDictionary == rhsDictionary
        default:
            return false
        }
    }
    
}

// MARK: - Dictionary Extension (PlistValue)

extension Dictionary where Key == String {
    
    func plist() -> PlistValue {
        var dictionary: [CommentedString: PlistValue] = [:]
        self.forEach { (key, value) in
            if let array = value as? [Any] {
                dictionary[CommentedString(key)] = array.plist()
            } else if let subDictionary = value as? [String: Any] {
                dictionary[CommentedString(key)] = subDictionary.plist()
            } else if let string = value as? CustomStringConvertible {
                dictionary[CommentedString(key)] = .string(CommentedString(string.description))
            }
        }
        return .dictionary(dictionary)
    }
    
}

// MARK: - Array Extension (PlistValue)

extension Array {
    
    func plist() -> PlistValue {
        return .array(self.flatMap({ (element) -> PlistValue? in
            if let array = element as? [Any] {
                return array.plist()
            } else if let dictionary = element as? [String: Any] {
                return dictionary.plist()
            } else if let string = element as? CustomStringConvertible {
                return PlistValue.string(CommentedString(string.description))
            }
            return nil
        }))
    }
    
}
