import Foundation

protocol AutoHashable {}

/// General protocol
protocol AutoHashableProtocol: AutoHashable {
    var width: Double { get }
    var height: Double { get}
    static var name: String { get }
}

/// General enum
enum AutoHashableEnum: AutoHashable {
    case one
    case two(first: String, second: String)
    case three(bar: Int)

    func allValue() -> [AutoHashableEnum] {
        return [.one, .two(first: "a", second: "b"), .three(bar: 42)]
    }
}

/// Sourcery should not generate a default case for enum with only one case
enum AutoHashableEnumWithOneCase: AutoHashable {
    case one
}

/// Sourcery should generate correct code for struct
struct AutoHashableStruct: AutoHashable {
    // Constants
    let firstName: String
    let lastName: String

    init(firstName: String, lastName: String, parents: [Parent]) {
        self.firstName = firstName
        self.lastName = lastName
        self.parents = parents
    }

    // Arrays
    // sourcery: arrayEquality
    let parents: [Parent]

    // Variable
    var moneyInThePocket: Double = 0

    // Forced unwrapped variable
    var age: Int!

    // Optional variable
    var friends: [String]?

    // Void method
    func walk() {
        print("I'm going")
    }

    // Method with return value
    func greeting(for name: String) -> String {
        return "Hi \(name)!"
    }

    // Method with optional return value
    func books(sharedWith name: String) -> String? {
        return nil
    }
}

/// It should generate correct code for general class
class AutoHashableClass: AutoHashable {
    // Constants
    let firstName: String
    let lastName: String

    init(firstName: String, lastName: String, parents: [Parent]) {
        self.firstName = firstName
        self.lastName = lastName
        self.parents = parents
    }

    // Arrays
    // sourcery: arrayEquality
    let parents: [Parent]

    // Variable
    var moneyInThePocket: Double = 0

    // Forced unwrapped variable
    var age: Int!

    // Optional variable
    var friends: [String]?

    // Void method
    func walk() {
        print("I'm going")
    }

    // Method with return value
    func greeting(for name: String) -> String {
        return "Hi \(name)!"
    }

    // Method with optional return value
    func books(sharedWith name: String) -> String? {
        return nil
    }
}

/// Sourcery doesn't support inheritance for AutoHashable
class AutoHashableClassInherited: AutoHashableClass {
    // Optional constants
    let middleName: String?

    init(middleName: String?) {
        self.middleName = middleName
        super.init(firstName: "", lastName: "", parents: [])
    }
}
