//
// Created by Krzysztof Zablocki on 13/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

class Enum: Type {
    class Case: NSObject {
        class AssociatedValue: NSObject {
            var name: String?
            var type: String

            init(name: String?, type: String) {
                self.name = name
                self.type = type
            }
        }

        var name: String
        var rawValue: String?
        var associatedValues: [AssociatedValue]

        var hasAssociatedValue: Bool {
            return !associatedValues.isEmpty
        }

        init(name: String, rawValue: String? = nil, associatedValues: [AssociatedValue] = []) {
            self.name = name
            self.rawValue = rawValue
            self.associatedValues = associatedValues
        }
    }

    /// Enum cases
    internal(set) var cases: [Case]

    /// Raw type of the enum
    let rawType: String?

    /// Checks whether enum contains any associated values
    var hasAssociatedValues: Bool {
        for entry in cases {
            if entry.hasAssociatedValue { return true }
        }

        return false
    }

    init(name: String, accessLevel: AccessLevel = .internal, isExtension: Bool = false, inheritedTypes: [String] = [], cases: [Case] = [], variables: [Variable] = []) {
        self.cases = cases
        self.rawType = inheritedTypes.first
        super.init(name: name, accessLevel: accessLevel, isExtension: isExtension, variables: variables, inheritedTypes: inheritedTypes)
    }
}
