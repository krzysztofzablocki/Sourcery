//
// Created by Krzysztof Zablocki on 13/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

class Enum: Type {
    class Case: NSObject {
        class AssociatedValue: NSObject {
            let name: String?
            let typeName: String

            init(name: String?, typeName: String) {
                self.name = name
                self.typeName = typeName
            }
        }

        let name: String
        let rawValue: String?
        let associatedValues: [AssociatedValue]

        var hasAssociatedValue: Bool {
            return !associatedValues.isEmpty
        }

        init(name: String, rawValue: String? = nil, associatedValues: [AssociatedValue] = []) {
            self.name = name
            self.rawValue = rawValue
            self.associatedValues = associatedValues
        }
    }

    /// sourcery: skipDescription
    override var kind: String { return "enum" }

    /// Enum cases
    internal(set) var cases: [Case]

    /// Raw type of the enum
    internal(set) var rawType: String? {
        didSet {
            if let rawType = rawType {
                if let index = inheritedTypes.index(of: rawType) {
                    inheritedTypes.remove(at: index)
                }
                if based[rawType] != nil {
                    based[rawType] = nil
                }
            }
        }
    }

    override var based: [String : String] {
        didSet {
            if let rawType = rawType, based[rawType] != nil {
                based[rawType] = nil
            }
        }
    }

    /// Checks whether enum contains any associated values
    var hasAssociatedValues: Bool {
        for entry in cases {
            if entry.hasAssociatedValue { return true }
        }

        return false
    }

    init(name: String, accessLevel: AccessLevel = .internal, isExtension: Bool = false, inheritedTypes: [String] = [], rawType: String? = nil, cases: [Case] = [], variables: [Variable] = [], containedTypes: [Type] = []) {
        self.cases = cases
        self.rawType = rawType
        super.init(name: name, accessLevel: accessLevel, isExtension: isExtension, variables: variables, inheritedTypes: inheritedTypes, containedTypes: containedTypes)

        if let rawType = rawType, let index = self.inheritedTypes.index(of: rawType) {
            self.inheritedTypes.remove(at: index)
        }
    }
}
