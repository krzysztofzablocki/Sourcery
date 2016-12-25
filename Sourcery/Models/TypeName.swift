//
// Created by Krzysztof Zabłocki on 25/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

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

    override var description: String {
        return name
    }
}
