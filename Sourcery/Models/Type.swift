//
// Created by Krzysztof Zablocki on 11/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

/// Defines Swift Type
class Type: NSObject {
    internal var isExtension: Bool

    var kind: String { return "class" }
    var accessLevel: AccessLevel

    /// Name in global scope 
    var name: String {
        guard let parentName = parentName else { return localName }
        return "\(parentName).\(localName)"
    }

    /// Name in parent scope
    var localName: String

    /// All type static variables
    var staticVariables: [Variable]

    /// All instance variables
    var variables: [Variable]

    /// Only computed instance variables
    var computedVariables: [Variable] {
        return variables.filter { $0.isComputed }
    }

    /// Only stored instance variables
    var storedVariables: [Variable] {
        return variables.filter { !$0.isComputed }
    }

    /// Types / Protocols we inherit from
    var inheritedTypes: [String]

    /// Contained types
    var containedTypes: [Type] {
        didSet {
            containedTypes.forEach { $0.parentName = self.name }
        }
    }

    /// Parent type name in global scope
    var parentName: String?

    /// Underlying parser data, never to be used by anything else
    internal var __parserData: Any?

    init(name: String, parentName: String? = nil, accessLevel: AccessLevel = .internal, isExtension: Bool = false, variables: [Variable] = [], staticVariables: [Variable] = [], inheritedTypes: [String] = [], containedTypes: [Type] = []) {
        self.localName = name
        self.accessLevel = accessLevel
        self.isExtension = isExtension
        self.variables = variables
        self.staticVariables = staticVariables
        self.inheritedTypes = inheritedTypes
        self.containedTypes = containedTypes
        self.parentName = parentName

        super.init()
        containedTypes.forEach { $0.parentName = self.name }
    }

    /// Extends this type with an extension
    ///
    /// - Parameter type: Extension of this type
    func extend(_ type: Type) {
        self.variables += type.variables
        self.inheritedTypes = Array(Set(self.inheritedTypes + type.inheritedTypes))
    }
}
