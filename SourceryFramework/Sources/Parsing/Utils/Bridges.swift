import Foundation

extension Array {
    public func bridge() -> NSArray {
        return self as NSArray
    }
}

extension CharacterSet {
    public func bridge() -> NSCharacterSet {
        return self as NSCharacterSet
    }
}

extension Dictionary {
    public func bridge() -> NSDictionary {
        return self as NSDictionary
    }
}

extension NSString {
    public func bridge() -> String {
        return self as String
    }
}

extension String {
    public func bridge() -> NSString {
        return self as NSString
    }
}
