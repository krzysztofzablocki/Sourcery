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

/// Sourcery should generate correct code for struct
struct AutoHashableStruct: AutoHashable {
    // Private Constants
    private let laptopModel: String

    // Fileprivate Constants
    fileprivate let phoneModel: String

    // Static constant
    static let structName: String = "AutoHashableStruct"

    // Internal Constants
    let firstName: String

    // Public Constans
    public let lastName: String

    init(firstName: String, lastName: String, parents: [Parent], laptopModel: String, phoneModel: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.parents = parents
        self.laptopModel = laptopModel
        self.phoneModel = phoneModel
        self.universityGrades = ["Math": 5, "Geometry": 3]
    }

    // Arrays
    let parents: [Parent]

    // Dictionary
    let universityGrades: [String: Int]

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
        return "Hi \(name)"
    }

    // Method with optional return value
    func books(sharedWith name: String) -> String? {
        return nil
    }
}

/// It should generate correct code for general class
class AutoHashableClass: AutoHashable {
    // Private Constants
    private let laptopModel: String

    // Fileprivate Constants
    fileprivate let phoneModel: String

    // Static constant
    static let className: String = "AutoHashableClass"

    // Internal Constants
    let firstName: String

    // Public Constans
    public let lastName: String

    init(firstName: String, lastName: String, parents: [Parent], laptopModel: String, phoneModel: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.parents = parents
        self.laptopModel = laptopModel
        self.phoneModel = phoneModel
        self.universityGrades = ["Math": 5, "Geometry": 3]
    }

    // Arrays
    let parents: [Parent]

    // Dictionary
    let universityGrades: [String: Int]

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
        return "Hi \(name)"
    }

    // Method with optional return value
    func books(sharedWith name: String) -> String? {
        return nil
    }
}

class AutoHashableClassInherited: AutoHashableClass {
    // Optional constants
    let middleName: String?

    init(middleName: String?) {
        self.middleName = middleName
        super.init(firstName: "", lastName: "", parents: [], laptopModel: "", phoneModel: "")
    }
}

class AutoHashableClassInheritedInherited: AutoHashableClassInherited {
    // Optional constants
    let prefix: String?

    init(prefix: String?) {
        self.prefix = prefix
        super.init(middleName: "")
    }
}

class NonHashableClass {
    let firstName: String

    init(firstName: String) {
        self.firstName = firstName
    }
}

// Should not add super call
class AutoHashableClassFromNonHashableInherited: NonHashableClass, AutoHashable {
    let lastName: String?

    init(lastName: String?) {
        self.lastName = lastName
        super.init(firstName: "")
    }
}

// Should add super call
class AutoHashableClassFromNonHashableInheritedInherited: AutoHashableClassFromNonHashableInherited {
    let prefix: String?

    init(prefix: String?) {
        self.prefix = prefix
        super.init(lastName: "")
    }
}

class HashableClass: Hashable {
    let firstName: String

    init(firstName: String) {
        self.firstName = firstName
    }

    static func == (lhs: HashableClass, rhs: HashableClass) -> Bool {
        return lhs.firstName == rhs.firstName
    }

    func hash(into hasher: inout Hasher) {
        self.firstName.hash(into: &hasher)
    }
}

// Should add super
class AutoHashableFromHashableInherited: HashableClass, AutoHashable {
    let lastName: String?

    init(lastName: String?) {
        self.lastName = lastName
        super.init(firstName: "")
    }
}

/// Should not add Hashable conformance
class AutoHashableNSObject: NSObject, AutoHashable {
    let firstName: String

    init(firstName: String) {
        self.firstName = firstName
    }
}

// Should add super call
class AutoHashableNSObjectInherited: AutoHashableNSObject {
    let lastName: String

    init(lastName: String) {
        self.lastName = lastName
        super.init(firstName: "")
    }
}
