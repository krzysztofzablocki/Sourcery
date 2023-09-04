//
//  AutoCases.swift
//  Templates
//
//  Created by Anton Domashnev on 03.05.17.
//  Copyright © 2017 Pixle. All rights reserved.
//

import Foundation

protocol AutoEquatable {}

protocol Parent {
    var name: String { get }
}

/// General protocol
protocol AutoEquatableProtocol: AutoEquatable {
    var width: Double { get }
    var height: Double { get}
    static var name: String { get }
}

/// General enum
enum AutoEquatableEnum: AutoEquatable {
    case one
    case two(first: String, second: String)
    case three(bar: Int)

    func allValue() -> [AutoEquatableEnum] {
        return [.one, .two(first: "a", second: "b"), .three(bar: 42)]
    }
}

/// Sourcery should not generate a default case for enum with only one case
enum AutoEquatableEnumWithOneCase: AutoEquatable {
    case one
}

/// Sourcery should generate correct code for struct
struct AutoEquatableStruct: AutoEquatable {
    // Private Constants
    private let laptopModel: String

    // Fileprivate Constants
    fileprivate let phoneModel: String

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
    }

    // Arrays
    // sourcery: arrayEquality
    let parents: [Parent]

    // Variable
    var moneyInThePocket: Double = 0

    // Optional variable
    var friends: [String]?

    /// Forced unwrapped variable
    var age: Int!

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
class AutoEquatableClass: AutoEquatable {
    // Private Constants
    private let laptopModel: String

    // Fileprivate Constants
    fileprivate let phoneModel: String

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
    }

    // Arrays
    // sourcery: arrayEquality
    let parents: [Parent]

    /// Forced unwrapped variable
    var age: Int!

    // Variable
    var moneyInThePocket: Double = 0

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

/// Sourcery doesn't support inheritance for AutoEqualtable 
class AutoEquatableClassInherited: AutoEquatableClass {
    // Optional constants
    let middleName: String?

    init(middleName: String?) {
        self.middleName = middleName
        super.init(firstName: "", lastName: "", parents: [], laptopModel: "", phoneModel: "")
    }
}

/// Should not add Equatable conformance
class AutoEquatableNSObject: NSObject, AutoEquatable {
    let firstName: String

    init(firstName: String) {
        self.firstName = firstName
    }
}

/// It should generate correct code for general class
/// sourcery: AutoEquatable
class AutoEquatableAnnotatedClass {

    // Variable
    var moneyInThePocket: Double = 0

}

// It won't be generated
class AutoEquatableAnnotatedClassInherited: AutoEquatableAnnotatedClass {

    // Variable
    var middleName: String = "Poor"

}

// Sourcery doesn't support inheritance for AutoEqualtable so it won't be generated
/// sourcery: AutoEquatable
class AutoEquatableAnnotatedClassAnnotatedInherited: AutoEquatableAnnotatedClass {

    // Variable
    var middleName: String = "Poor"

}
