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
}

// sourcery: skipDescription
class TypeName: NSObject, AutoDiffable {
    let name: String

    init(_ name: String) {
        self.name = name
    }

    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var isOptional: Bool {
        if name.hasSuffix("?") || name.hasPrefix("Optional<") {
            return true
        }
        return false
    }

    /// sourcery: skipEquality
    /// sourcery: skipDescription
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

    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var isVoid: Bool {
        return name == "Void" || name == "()"
    }

    override var description: String {
        return name
    }
}
