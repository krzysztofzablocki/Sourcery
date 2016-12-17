//
// Created by Krzysztof Zablocki on 11/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

/// Defines Swift Type
class Type: NSObject {
    internal var isExtension: Bool

    var kind: String { return isExtension ? "extension" : "class" }
    var accessLevel: AccessLevel

    /// Name in global scope 
    var name: String {
        guard let parentName = parent?.name else { return localName }
        return "\(parentName).\(localName)"
    }

    /// Is this type generic?
    var isGeneric: Bool

    /// Name in parent scope
    var localName: String

    /// All instance variables
    var variables: [Variable]

    /// Annotations, that were created with // sourcery: annotation1, other = "annotation value", alterantive = 2
    var annotations: [String: NSObject] = [:]

    /// All type static variables
    var staticVariables: [Variable] {
        return variables.filter({ $0.isStatic })
    }

    /// Only computed instance variables
    var computedVariables: [Variable] {
        return variables.filter { $0.isComputed && !$0.isStatic }
    }

    /// Only stored instance variables
    var storedVariables: [Variable] {
        return variables.filter { !$0.isComputed && !$0.isStatic }
    }

    /// Types / Protocols names we inherit from, in order of definition
    var inheritedTypes: [String]

    /// contains all base types inheriting from given BaseClass or implementing given Protocol, even not known by Sourcery
    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var based = [String: String]()

    /// contains all types implementing known BaseProtocol
    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var inherits = [String: String]()

    /// contains all types implementing known BaseClass
    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var implements = [String: String]()

    /// Contained types
    var containedTypes: [Type] {
        didSet {
            containedTypes.forEach { $0.parent = self }
        }
    }

    /// Parent name
    var parentName: String?

    /// Parent type
    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var parent: Type? {
        didSet {
            parentName = parent?.name
        }
    }

    /// sourcery: skipEquality
    /// Underlying parser data, never to be used by anything else
    /// sourcery: skipDescription
    internal var __parserData: Any?

    init(name: String = "", parent: Type? = nil, accessLevel: AccessLevel = .internal, isExtension: Bool = false, variables: [Variable] = [], inheritedTypes: [String] = [], containedTypes: [Type] = [], annotations: [String: NSObject] = [:], isGeneric: Bool = false) {
        self.localName = name
        self.accessLevel = accessLevel
        self.isExtension = isExtension
        self.variables = variables
        self.inheritedTypes = inheritedTypes
        self.containedTypes = containedTypes
        self.parent = parent
        self.parentName = parent?.name
        self.annotations = annotations
        self.isGeneric = isGeneric

        super.init()
        containedTypes.forEach { $0.parent = self }
        inheritedTypes.forEach { name in
            self.based[name] = name
        }
    }

    /// Extends this type with an extension
    ///
    /// - Parameter type: Extension of this type
    func extend(_ type: Type) {
        self.variables += type.variables

        type.annotations.forEach { self.annotations[$0.key] = $0.value }
        type.based.keys.forEach { self.based[$0] = $0 }
        type.inherits.keys.forEach { self.inherits[$0] = $0 }
        type.implements.keys.forEach { self.implements[$0] = $0 }
        self.inheritedTypes = Array(Set(self.inheritedTypes + type.inheritedTypes))
    }
}
