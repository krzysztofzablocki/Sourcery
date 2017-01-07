//
// Created by Krzysztof Zablocki on 13/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

final class Enum: Type {
    final class Case: NSObject, AutoDiffable {
        final class AssociatedValue: NSObject, AutoDiffable, Typed {
            let localName: String?
            let externalName: String?
            let typeName: TypeName

            /// sourcery: skipEquality
            /// sourcery: skipDescription
            var type: Type?

            init(localName: String?, externalName: String?, typeName: String, type: Type? = nil) {
                self.localName = localName
                self.externalName = externalName
                self.typeName = TypeName(typeName)
                self.type = type
            }

            convenience init(name: String? = nil, typeName: String, type: Type? = nil) {
                self.init(localName: name, externalName: name, typeName: typeName, type: type)
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
    internal(set) var rawTypeName: TypeName? {
        didSet {
            if let rawTypeName = rawTypeName {
                hasRawType = true
                if let index = inheritedTypes.index(of: rawTypeName.name) {
                    inheritedTypes.remove(at: index)
                }
                if based[rawTypeName.name] != nil {
                    based[rawTypeName.name] = nil
                }
            }
        }
    }

    // sourcery: skipDescription, skipEquality
    private(set) var hasRawType: Bool

    // sourcery: skipDescription, skipEquality
    var rawType: Type?

    /// sourcery: skipEquality
    /// sourcery: skipDescription
    override var based: [String : String] {
        didSet {
            if let rawTypeName = rawTypeName, based[rawTypeName.name] != nil {
                based[rawTypeName.name] = nil
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

    init(name: String,
         accessLevel: AccessLevel = .internal,
         isExtension: Bool = false,
         inheritedTypes: [String] = [],
         rawTypeName: String? = nil,
         cases: [Case] = [],
         variables: [Variable] = [],
         methods: [Method] = [],
         containedTypes: [Type] = [],
         typealiases: [Typealias] = []) {

        self.cases = cases
        self.rawTypeName = rawTypeName.map(TypeName.init)
        self.hasRawType = rawTypeName != nil || !inheritedTypes.isEmpty

        super.init(name: name, accessLevel: accessLevel, isExtension: isExtension, variables: variables, methods: methods, inheritedTypes: inheritedTypes, containedTypes: containedTypes, typealiases: typealiases)

        if let rawTypeName = rawTypeName, let index = self.inheritedTypes.index(of: rawTypeName) {
            self.inheritedTypes.remove(at: index)
        }
    }

}
