import Foundation

public extension Bool {
    /// Returns a XML string value that represents the boolean.
    var xmlString: String {
        self ? "YES" : "NO"
    }

    /// Returns a 1 for true and 0 for false
    var int: UInt {
        self ? 1 : 0
    }
}
