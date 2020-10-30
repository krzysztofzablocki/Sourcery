import Foundation

public extension Bool {
    /// Returns a XML string value that represents the boolean.
    var xmlString: String {
        return self ? "YES" : "NO"
    }

    /// Returns a 1 for true and 0 for false
    var int: UInt {
        return self ? 1 : 0
    }
}
