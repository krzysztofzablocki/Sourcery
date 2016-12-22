//
// Created by Krzysztof Zablocki on 13/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

/// Defines a variable

class Variable: NSObject, AutoDiffable {
    /// Variable name
    let name: String

    /// Variable type
    var typeName: String

    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var type: Type?

    /// Is the variable optional?
    var isOptional: Bool {
        if typeName.hasSuffix("?") || typeName.hasPrefix("Optional<") {
            return true
        }
        return false
    }

    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var unwrappedTypeName: String {
        guard isOptional else { return typeName }
        if typeName.hasSuffix("?") {
            return String(typeName.characters.dropLast())
        } else {
            return String(typeName.characters.dropFirst("Optional<".characters.count).dropLast())
        }
    }

    /// Whether is computed
    let isComputed: Bool

    /// Whether this is static variable
    let isStatic: Bool

    /// Read access
    let readAccess: String

    /// Write access
    let writeAccess: String

    /// Annotations, that were created with // sourcery: annotation1, other = "annotation value", alterantive = 2
    var annotations: [String: NSObject] = [:]

    /// Underlying parser data, never to be used by anything else
    /// sourcery: skipEquality, skipDescription
    internal var __parserData: Any?

    init(name: String = "",
         typeName: String = "",
         accessLevel: (read: AccessLevel, write: AccessLevel) = (.internal, .internal),
         isComputed: Bool = false,
         isStatic: Bool = false,
         annotations: [String: NSObject] = [:]) {

        self.name = name
        self.typeName = typeName
        self.isComputed = isComputed
        self.isStatic = isStatic
        self.readAccess = accessLevel.read.rawValue
        self.writeAccess = accessLevel.write.rawValue
        self.annotations = annotations
    }
}
