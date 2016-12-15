//
// Created by Krzysztof Zablocki on 13/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

/// Defines a variable
class Variable: NSObject {
    /// Variable name
    var name: String

    /// Variable type
    var typeName: String
    var type: Type?

    /// Is the variable optional?
    var isOptional: Bool {
        if typeName.hasSuffix("?") { return true }
        if typeName.hasPrefix("Optional<") { return true }
        return false
    }

    /// Whether is computed
    var isComputed: Bool

    /// Whether this is static variable
    var isStatic: Bool

    /// Read access
    var readAccess: AccessLevel

    /// Write access
    var writeAccess: AccessLevel

    /// Underlying parser data, never to be used by anything else
    internal var __parserData: Any?

    init(name: String, type: String, accessLevel: (read: AccessLevel, write: AccessLevel) = (.internal, .internal), isComputed: Bool = false, isStatic: Bool = false) {
        self.name = name
        self.typeName = type
        self.isComputed = isComputed
        self.isStatic = isStatic
        self.readAccess = accessLevel.read
        self.writeAccess = accessLevel.write
    }
}
