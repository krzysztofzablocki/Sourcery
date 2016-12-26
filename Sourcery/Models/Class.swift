import Foundation

// sourcery: skipDescription, skipEquatable
class Class: Type {
    override var kind: String { return "class" }

    /// contains all types inheriting from known BaseClass
    // sourcery: skipEquality
    var inherits = [String: String]()

    /// Superclass definition if any
    // sourcery: skipEquality
    var supertype: Class?

}
