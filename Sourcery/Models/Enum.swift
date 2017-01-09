//
// Created by Krzysztof Zablocki on 13/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

final class Enum: Type {
    final class Case: NSObject, AutoDiffable, Annotated, NSCoding {
        final class AssociatedValue: NSObject, AutoDiffable, Typed, NSCoding {
            let localName: String?
            let externalName: String?
            let typeName: TypeName

            /// sourcery: skipEquality
            /// sourcery: skipDescription
            var type: Type?

            init(localName: String?, externalName: String?, typeName: TypeName, type: Type? = nil) {
                self.localName = localName
                self.externalName = externalName
                self.typeName = typeName
                self.type = type
            }

            convenience init(name: String? = nil, typeName: TypeName, type: Type? = nil) {
                self.init(localName: name, externalName: name, typeName: typeName, type: type)
            }

        // Enum.Case.AssociatedValue.NSCoding {
        required init?(coder aDecoder: NSCoder) {
            self.localName = aDecoder.decode(forKey: "localName")
            self.externalName = aDecoder.decode(forKey: "externalName")
            guard let typeName: TypeName = aDecoder.decode(forKey: "typeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typeName"])); fatalError() }; self.typeName = typeName
            self.type = aDecoder.decode(forKey: "type")

        }

        func encode(with aCoder: NSCoder) {

            aCoder.encode(self.localName, forKey: "localName")
            aCoder.encode(self.externalName, forKey: "externalName")
            aCoder.encode(self.typeName, forKey: "typeName")
            aCoder.encode(self.type, forKey: "type")

        }
        // } Enum.Case.AssociatedValue.NSCoding

        }

        let name: String
        let rawValue: String?
        let associatedValues: [AssociatedValue]

        /// Annotations, that were created with // sourcery: annotation1, other = "annotation value", alterantive = 2
        var annotations: [String: NSObject] = [:]

        var hasAssociatedValue: Bool {
            return !associatedValues.isEmpty
        }

        /// Underlying parser data, never to be used by anything else
        // sourcery: skipEquality, skipDescription, skipCoding
        internal var __parserData: Any?

        init(name: String, rawValue: String? = nil, associatedValues: [AssociatedValue] = [], annotations: [String: NSObject] = [:]) {
            self.name = name
            self.rawValue = rawValue
            self.associatedValues = associatedValues
            self.annotations = annotations
        }

        // Enum.Case.NSCoding {
        required init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            self.rawValue = aDecoder.decode(forKey: "rawValue")
            guard let associatedValues: [AssociatedValue] = aDecoder.decode(forKey: "associatedValues") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["associatedValues"])); fatalError() }; self.associatedValues = associatedValues
            guard let annotations: [String: NSObject] = aDecoder.decode(forKey: "annotations") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["annotations"])); fatalError() }; self.annotations = annotations

        }

        func encode(with aCoder: NSCoder) {

            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.rawValue, forKey: "rawValue")
            aCoder.encode(self.associatedValues, forKey: "associatedValues")
            aCoder.encode(self.annotations, forKey: "annotations")

        }
        // } Enum.Case.NSCoding
    }

    /// sourcery: skipDescription, skipCoding
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

    // sourcery: skipDescription
    private(set) var hasRawType: Bool

    // sourcery: skipDescription, skipEquality
    var rawType: Type?

    /// sourcery: skipEquality, skipDescription, skipCoding
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

    init(name: String = "",
         parent: Type? = nil,
         accessLevel: AccessLevel = .internal,
         isExtension: Bool = false,
         inheritedTypes: [String] = [],
         rawTypeName: TypeName? = nil,
         cases: [Case] = [],
         variables: [Variable] = [],
         methods: [Method] = [],
         containedTypes: [Type] = [],
         typealiases: [Typealias] = [],
         attributes: [String: Attribute] = [:],
         annotations: [String: NSObject] = [:],
         isGeneric: Bool = false) {

        self.cases = cases
        self.rawTypeName = rawTypeName
        self.hasRawType = rawTypeName != nil || !inheritedTypes.isEmpty

        super.init(name: name, parent: parent, accessLevel: accessLevel, isExtension: isExtension, variables: variables, methods: methods, inheritedTypes: inheritedTypes, containedTypes: containedTypes, typealiases: typealiases, attributes: attributes, annotations: annotations, isGeneric: isGeneric)

        if let rawTypeName = rawTypeName?.name, let index = self.inheritedTypes.index(of: rawTypeName) {
            self.inheritedTypes.remove(at: index)
        }
    }

    // Enum.NSCoding {
        required init?(coder aDecoder: NSCoder) {
            guard let cases: [Case] = aDecoder.decode(forKey: "cases") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["cases"])); fatalError() }; self.cases = cases
            self.rawTypeName = aDecoder.decode(forKey: "rawTypeName")
            self.hasRawType = aDecoder.decode(forKey: "hasRawType")
            self.rawType = aDecoder.decode(forKey: "rawType")

            super.init(coder: aDecoder)
        }

        override func encode(with aCoder: NSCoder) {
            super.encode(with: aCoder)
            aCoder.encode(self.cases, forKey: "cases")
            aCoder.encode(self.rawTypeName, forKey: "rawTypeName")
            aCoder.encode(self.hasRawType, forKey: "hasRawType")
            aCoder.encode(self.rawType, forKey: "rawType")

        }
        // } Enum.NSCoding
}
