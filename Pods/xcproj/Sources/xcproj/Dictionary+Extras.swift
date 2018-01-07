import Foundation

/// Static initializer that creates a Dictionary from a .plist file.
///
/// - Parameter path: the path of the .plist file.
/// - Returns: initialized dictionary.
public func loadPlist(path: String) -> [String: AnyObject]? {
    return NSDictionary(contentsOfFile: path) as? [String: AnyObject]
}

extension Dictionary {
    
    func mapValuesWithKeys<T>(_ map: (_ key: Key, _ value: Value) throws -> T) throws -> [Key: T] {
        var output = [Key: T]()
        try self.forEach { try output[$0.key] = map($0.key, $0.value) }
        return output
    }
    
}
