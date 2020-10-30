import Foundation

/// Static initializer that creates a Dictionary from a .plist file.
///
/// - Parameter path: the path of the .plist file.
/// - Returns: initialized dictionary.
public func loadPlist(path: String) -> [String: AnyObject]? {
    return NSDictionary(contentsOfFile: path) as? [String: AnyObject]
}
