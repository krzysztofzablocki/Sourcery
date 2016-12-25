//
// Created by Krzysztof Zablocki on 13/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

class Enum: Type {
    class Case: NSObject, AutoDiffable {
        class AssociatedValue: NSObject, AutoDiffable {
            let name: String?
            let typeName: String

            /// sourcery: skipDescription
            var type: Type?

            /// Is the variable optional?
            var isOptional: Bool {
                if typeName.hasSuffix("?") || typeName.hasPrefix("Optional<") {
                    return true
                }
                return false
            }

            /// sourcery: skipDescription
            var unwrappedTypeName: String {
                guard isOptional else { return typeName }
                if typeName.hasSuffix("?") {
                    return String(typeName.characters.dropLast())
                } else {
                    return String(typeName.characters.dropFirst("Optional<".characters.count).dropLast())
                }
            }

            init(name: String?, typeName: String) {
                self.name = name
                self.typeName = typeName
            }
        }

        let name: String
        let rawValue: String?
        let associatedValues: [AssociatedValue]

        /// Annotations, that were created with // sourcery: annotation1, other = "annotation value", alterantive = 2
        var annotations: [String: NSObject] = [:]

        var hasAssociatedValue: Bool {
            return !associatedValues.isEmpty
        }

        init(name: String, rawValue: String? = nil, associatedValues: [AssociatedValue] = [], annotations: [String: NSObject] = [:]) {
            self.name = name
            self.rawValue = rawValue
            self.associatedValues = associatedValues
            self.annotations = annotations
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

    /// sourcery: skipEquality
    /// sourcery: skipDescription
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

    init(name: String, accessLevel: AccessLevel = .internal, isExtension: Bool = false, inheritedTypes: [String] = [], rawType: String? = nil, cases: [Case] = [], variables: [Variable] = [], containedTypes: [Type] = [], typealiases: [Typealias] = []) {
        self.cases = cases
        self.rawType = rawType
        super.init(name: name, accessLevel: accessLevel, isExtension: isExtension, variables: variables, inheritedTypes: inheritedTypes, containedTypes: containedTypes, typealiases: typealiases)

        if let rawType = rawType, let index = self.inheritedTypes.index(of: rawType) {
            self.inheritedTypes.remove(at: index)
        }
    }
}
