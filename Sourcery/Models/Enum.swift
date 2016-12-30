//
// Created by Krzysztof Zablocki on 13/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

final class Enum: Type {
    final class Case: NSObject, AutoDiffable, NSCoding {
        final class AssociatedValue: NSObject, AutoDiffable, Typed, NSCoding {
            let name: String?
            let typeName: TypeName

            /// sourcery: skipEquality
            /// sourcery: skipDescription
            var type: Type?

            init(name: String?, typeName: String, type: Type? = nil) {
                self.name = name
                self.typeName = TypeName(typeName)
                self.type = type
            }

            // 

            //
            required init?(coder aDecoder: NSCoder) {

                self.name = aDecoder.decode(forKey: "name")
                self.typeName = aDecoder.decode(forKey: "typeName")
                self.type = aDecoder.decode(forKey: "type")

            }

            func encode(with aCoder: NSCoder) {

                aCoder.encode(self.name, forKey: "name")
                aCoder.encode(self.typeName, forKey: "typeName")
                aCoder.encode(self.type, forKey: "type")

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

        //
        required init?(coder aDecoder: NSCoder) {

            self.name = aDecoder.decode(forKey: "name")
            self.rawValue = aDecoder.decode(forKey: "rawValue")
            self.associatedValues = aDecoder.decode(forKey: "associatedValues")
            self.annotations = aDecoder.decode(forKey: "annotations")

        }

        func encode(with aCoder: NSCoder) {

            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.rawValue, forKey: "rawValue")
            aCoder.encode(self.associatedValues, forKey: "associatedValues")
            aCoder.encode(self.annotations, forKey: "annotations")

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
                hasRawType = true
                if let index = inheritedTypes.index(of: rawType) {
                    inheritedTypes.remove(at: index)
                }
                if based[rawType] != nil {
                    based[rawType] = nil
                }
            }
        }
    }

    private(set) var hasRawType: Bool

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

    init(name: String,
         accessLevel: AccessLevel = .internal,
         isExtension: Bool = false,
         inheritedTypes: [String] = [],
         rawType: String? = nil,
         cases: [Case] = [],
         variables: [Variable] = [],
         methods: [Method] = [],
         containedTypes: [Type] = [],
         typealiases: [Typealias] = []) {

        self.cases = cases
        self.rawType = rawType
        self.hasRawType = rawType != nil || !inheritedTypes.isEmpty

        super.init(name: name, accessLevel: accessLevel, isExtension: isExtension, variables: variables, methods: methods, inheritedTypes: inheritedTypes, containedTypes: containedTypes, typealiases: typealiases)

        if let rawType = rawType, let index = self.inheritedTypes.index(of: rawType) {
            self.inheritedTypes.remove(at: index)
        }
    }

    //
    required init?(coder aDecoder: NSCoder) {

        self.cases = aDecoder.decode(forKey: "cases")
        self.rawType = aDecoder.decode(forKey: "rawType")
        self.hasRawType = aDecoder.decodeBool(forKey: "hasRawType")

        super.init(coder: aDecoder)
    }

    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.cases, forKey: "cases")
        aCoder.encode(self.rawType, forKey: "rawType")
        aCoder.encode(self.hasRawType, forKey: "hasRawType")
    }
}
