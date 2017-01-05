//
// Created by Krzysztof Zabłocki on 25/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

protocol Typed {
    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var type: Type? { get set }

    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var typeName: TypeName { get }

    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var isOptional: Bool { get }

    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var isImplicitlyUnwrappedOptional: Bool { get }

    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var unwrappedTypeName: String { get }
}

// sourcery: skipDescription
final class TypeName: NSObject, AutoDiffable {
    let name: String

    /// Actual type name if given type name is type alias
    // sourcery: skipEquality
    var actualTypeName: TypeName?

    init(_ name: String, attributes: [String: Attribute] = [:]) {
        self.name = name
        self.attributes = attributes

        var name = name
        attributes.forEach {
            let trim = CharacterSet(charactersIn: "@\($0.key)")
            name = name.trimmingCharacters(in: trim.union(.whitespaces))
        }

		let isImplicitlyUnwrappedOptional = name.hasSuffix("!") || name.hasPrefix("ImplicitlyUnwrappedOptional<")
        let isOptional = name.hasSuffix("?") || name.hasPrefix("Optional<") || isImplicitlyUnwrappedOptional
		self.isImplicitlyUnwrappedOptional = isImplicitlyUnwrappedOptional
        self.isOptional = isOptional

        if isOptional {
            if name.hasSuffix("?") || name.hasSuffix("!") {
                self.unwrappedTypeName = String(name.characters.dropLast())
            } else if name.hasPrefix("Optional<") {
                self.unwrappedTypeName = String(name.characters.dropFirst("Optional<".characters.count).dropLast())
            } else {
                self.unwrappedTypeName = String(name.characters.dropFirst("ImplicitlyUnwrappedOptional<".characters.count).dropLast())
            }
        } else {
            self.unwrappedTypeName = name
        }
    }

    let attributes: [String: Attribute]

    // sourcery: skipEquality
    let isOptional: Bool

    // sourcery: skipEquality
    let isImplicitlyUnwrappedOptional: Bool

    // sourcery: skipEquality
    let unwrappedTypeName: String

    // sourcery: skipEquality
    var isVoid: Bool {
        return name == "Void" || name == "()"
    }

    var isTuple: Bool {
        if let actualTypeName = actualTypeName?.name {
            return actualTypeName.isValidTupleName()
        } else {
            return name.isValidTupleName()
        }
    }

    var tuple: TupleType?

    override var description: String {
        return name
    }

}

final class TupleType: NSObject, AutoDiffable {
    let name: String

    final class Element: NSObject, AutoDiffable, Typed {
        let name: String
        let typeName: TypeName

        // sourcery: skipEquality, skipDescription
        var type: Type?

        init(name: String = "", typeName: TypeName, type: Type? = nil) {
            self.name = name
            self.typeName = typeName
            self.type = type
        }
    }

    let elements: [Element]

    init(name: String, elements: [Element]) {
        self.name = name
        self.elements = elements
    }

}
