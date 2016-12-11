//
// Created by Krzysztof Zablocki on 13/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

/// Defines a variable
class Variable: NSObject {
    private var accessLevel: (read: AccessLevel, write: AccessLevel)

    /// Variable name
    var name: String

    /// Variable type
    var type: String

    /// Whether is computed
    var isComputed: Bool

    /// Whether this is static variable
    var isStatic: Bool

    /// Read access
    var readAccess: AccessLevel {
        return accessLevel.read
    }

    /// Write access
    var writeAccess: AccessLevel {
        return accessLevel.write
    }

    init(name: String, type: String, accessLevel: (read: AccessLevel, write: AccessLevel) = (.internal, .internal), isComputed: Bool = false, isStatic: Bool = false) {
        self.name = name
        self.type = type
        self.accessLevel = accessLevel
        self.isComputed = isComputed
        self.isStatic = isStatic
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Variable else {
            return false
        }

        let lhs = self
        return
            lhs.type == rhs.type &&
            lhs.accessLevel.read == rhs.accessLevel.read &&
            lhs.accessLevel.write == rhs.accessLevel.write &&
            lhs.name == rhs.name &&
            lhs.isComputed == rhs.isComputed &&
            lhs.isStatic == rhs.isStatic
    }
}
