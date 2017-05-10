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
    // Constants
    let firstName: String
    let lastName: String
    let age: Int
    
    // Arrays
    // sourcery: arrayEquality
    let parents: [Parent]
    
    // Variable
    var moneyInThePocket: Double
    
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
class AutoEquatableClass: AutoEquatable {
    // Constants
    let firstName: String
    let lastName: String
    let age: Int
    
    // Arrays
    // sourcery: arrayEquality
    let parents: [Parent]
    
    // Variable
    var moneyInThePocket: Double
    
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

/// Sourcery doesn't support inheritance for AutoEqualtable 
class AutoEquatableClassInheritedFromAutoEquatable: AutoEquatableClass, AutoEquatable {
    // Optional constants
    let middleName: String?
}
