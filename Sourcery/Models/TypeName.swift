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
    var unwrappedTypeName: String { get }
}

extension Typed {
    var isOptional: Bool { return typeName.isOptional }
    var unwrappedTypeName: String { return typeName.unwrappedTypeName }
    var actualTypeName: TypeName? { return typeName.actualTypeName }
    var isTuple: Bool { return typeName.isTuple }
}

// sourcery: skipDescription
final class TypeName: NSObject, AutoDiffable {
    let name: String

    /// Actual type name if given type name is type alias
    // sourcery: skipEquality
    var actualTypeName: TypeName?

    init(_ name: String) {
        self.name = name
    }

    // sourcery: skipEquality
    var isOptional: Bool {
        if name.hasSuffix("?") || name.hasPrefix("Optional<") {
            return true
        }
        return false
    }

    // sourcery: skipEquality
    var unwrappedTypeName: String {
        guard isOptional else {
            return name
        }

        if name.hasSuffix("?") {
            return String(name.characters.dropLast())
        } else {
            return String(name.characters.dropFirst("Optional<".characters.count).dropLast())
        }
    }

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
        if let actualTypeName = actualTypeName {
            return "\(name) aka \(actualTypeName.name)"
        } else {
            return name
        }
    }
}

final class TupleType: NSObject, AutoDiffable {
    let name: String

    final class Element: NSObject, AutoDiffable, Typed {
        let name: String
        let typeName: TypeName

        // sourcery: skipEquality, skipDescription
        var type: Type?

        init(name: String, typeName: String, type: Type? = nil) {
            self.name = name
            self.typeName = TypeName(typeName)
            self.type = type
        }
    }

    let elements: [Element]

    init(name: String, elements: [Element]) {
        self.name = name
        self.elements = elements
    }

}
