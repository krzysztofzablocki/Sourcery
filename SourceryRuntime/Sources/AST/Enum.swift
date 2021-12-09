//
// Created by Krzysztof Zablocki on 13/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

/// Defines enum case associated value
@objcMembers public final class AssociatedValue: NSObject, SourceryModel, AutoDescription, Typed, Annotated {

    /// Associated value local name.
    /// This is a name to be used to construct enum case value
    public let localName: String?

    /// Associated value external name.
    /// This is a name to be used to access value in value-bindig
    public let externalName: String?

    /// Associated value type name
    public let typeName: TypeName

    // sourcery: skipEquality, skipDescription
    /// Associated value type, if known
    public var type: Type?

    /// Associated value default value
    public let defaultValue: String?

    /// Annotations, that were created with // sourcery: annotation1, other = "annotation value", alterantive = 2
    public var annotations: Annotations = [:]

    /// :nodoc:
    public init(localName: String?, externalName: String?, typeName: TypeName, type: Type? = nil, defaultValue: String? = nil, annotations: [String: NSObject] = [:]) {
        self.localName = localName
        self.externalName = externalName
        self.typeName = typeName
        self.type = type
        self.defaultValue = defaultValue
        self.annotations = annotations
    }

    convenience init(name: String? = nil, typeName: TypeName, type: Type? = nil, defaultValue: String? = nil, annotations: [String: NSObject] = [:]) {
        self.init(localName: name, externalName: name, typeName: typeName, type: type, defaultValue: defaultValue, annotations: annotations)
    }

// sourcery:inline:AssociatedValue.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            self.localName = aDecoder.decode(forKey: "localName")
            self.externalName = aDecoder.decode(forKey: "externalName")
            guard let typeName: TypeName = aDecoder.decode(forKey: "typeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typeName"])); fatalError() }; self.typeName = typeName
            self.type = aDecoder.decode(forKey: "type")
            self.defaultValue = aDecoder.decode(forKey: "defaultValue")
            guard let annotations: Annotations = aDecoder.decode(forKey: "annotations") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["annotations"])); fatalError() }; self.annotations = annotations
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.localName, forKey: "localName")
            aCoder.encode(self.externalName, forKey: "externalName")
            aCoder.encode(self.typeName, forKey: "typeName")
            aCoder.encode(self.type, forKey: "type")
            aCoder.encode(self.defaultValue, forKey: "defaultValue")
            aCoder.encode(self.annotations, forKey: "annotations")
        }
// sourcery:end

}

/// Defines enum case
@objcMembers public final class EnumCase: NSObject, SourceryModel, AutoDescription, Annotated, Documented {

    /// Enum case name
    public let name: String

    /// Enum case raw value, if any
    public let rawValue: String?

    /// Enum case associated values
    public let associatedValues: [AssociatedValue]

    /// Enum case annotations
    public var annotations: Annotations = [:]

    public var documentation: Documentation = []

    /// Whether enum case is indirect
    public let indirect: Bool

    /// Whether enum case has associated value
    public var hasAssociatedValue: Bool {
        return !associatedValues.isEmpty
    }

    // Underlying parser data, never to be used by anything else
    // sourcery: skipEquality, skipDescription, skipCoding, skipJSExport
    /// :nodoc:
    public var __parserData: Any?

    /// :nodoc:
    public init(name: String, rawValue: String? = nil, associatedValues: [AssociatedValue] = [], annotations: [String: NSObject] = [:], documentation: [String] = [], indirect: Bool = false) {
        self.name = name
        self.rawValue = rawValue
        self.associatedValues = associatedValues
        self.annotations = annotations
        self.documentation = documentation
        self.indirect = indirect
    }

// sourcery:inline:EnumCase.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            self.rawValue = aDecoder.decode(forKey: "rawValue")
            guard let associatedValues: [AssociatedValue] = aDecoder.decode(forKey: "associatedValues") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["associatedValues"])); fatalError() }; self.associatedValues = associatedValues
            guard let annotations: Annotations = aDecoder.decode(forKey: "annotations") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["annotations"])); fatalError() }; self.annotations = annotations
            guard let documentation: Documentation = aDecoder.decode(forKey: "documentation") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["documentation"])); fatalError() }; self.documentation = documentation
            self.indirect = aDecoder.decode(forKey: "indirect")
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.rawValue, forKey: "rawValue")
            aCoder.encode(self.associatedValues, forKey: "associatedValues")
            aCoder.encode(self.annotations, forKey: "annotations")
            aCoder.encode(self.documentation, forKey: "documentation")
            aCoder.encode(self.indirect, forKey: "indirect")
        }
// sourcery:end
}

/// Defines Swift enum
@objcMembers public final class Enum: Type {

    // sourcery: skipDescription
    /// Returns "enum"
    public override var kind: String { return "enum" }

    /// Enum cases
    public var cases: [EnumCase]

    /**
     Enum raw value type name, if any. This type is removed from enum's `based` and `inherited` types collections.

        - important: Unless raw type is specified explicitly via type alias RawValue it will be set to the first type in the inheritance chain.
     So if your enum does not have raw value but implements protocols you'll have to specify conformance to these protocols via extension to get enum with nil raw value type and all based and inherited types.
     */
    public var rawTypeName: TypeName? {
        didSet {
            if let rawTypeName = rawTypeName {
                hasRawType = true
                if let index = inheritedTypes.firstIndex(of: rawTypeName.name) {
                    inheritedTypes.remove(at: index)
                }
                if based[rawTypeName.name] != nil {
                    based[rawTypeName.name] = nil
                }
            } else {
                hasRawType = false
            }
        }
    }

    // sourcery: skipDescription, skipEquality
    /// :nodoc:
    public private(set) var hasRawType: Bool

    // sourcery: skipDescription, skipEquality
    /// Enum raw value type, if known
    public var rawType: Type?

    // sourcery: skipEquality, skipDescription, skipCoding
    /// Names of types or protocols this type inherits from, including unknown (not scanned) types
    public override var based: [String: String] {
        didSet {
            if let rawTypeName = rawTypeName, based[rawTypeName.name] != nil {
                based[rawTypeName.name] = nil
            }
        }
    }

    /// Whether enum contains any associated values
    public var hasAssociatedValues: Bool {
        return cases.contains(where: { $0.hasAssociatedValue })
    }

    /// :nodoc:
    public init(name: String = "",
                parent: Type? = nil,
                accessLevel: AccessLevel = .internal,
                isExtension: Bool = false,
                inheritedTypes: [String] = [],
                rawTypeName: TypeName? = nil,
                cases: [EnumCase] = [],
                variables: [Variable] = [],
                methods: [Method] = [],
                containedTypes: [Type] = [],
                typealiases: [Typealias] = [],
                attributes: AttributeList = [:],
                modifiers: [SourceryModifier] = [],
                annotations: [String: NSObject] = [:],
                documentation: [String] = [],
                isGeneric: Bool = false) {

        self.cases = cases
        self.rawTypeName = rawTypeName
        self.hasRawType = rawTypeName != nil || !inheritedTypes.isEmpty

        super.init(name: name, parent: parent, accessLevel: accessLevel, isExtension: isExtension, variables: variables, methods: methods, inheritedTypes: inheritedTypes, containedTypes: containedTypes, typealiases: typealiases, attributes: attributes, modifiers: modifiers, annotations: annotations, documentation: documentation, isGeneric: isGeneric)

        if let rawTypeName = rawTypeName?.name, let index = self.inheritedTypes.firstIndex(of: rawTypeName) {
            self.inheritedTypes.remove(at: index)
        }
    }

// sourcery:inline:Enum.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let cases: [EnumCase] = aDecoder.decode(forKey: "cases") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["cases"])); fatalError() }; self.cases = cases
            self.rawTypeName = aDecoder.decode(forKey: "rawTypeName")
            self.hasRawType = aDecoder.decode(forKey: "hasRawType")
            self.rawType = aDecoder.decode(forKey: "rawType")
            super.init(coder: aDecoder)
        }

        /// :nodoc:
        override public func encode(with aCoder: NSCoder) {
            super.encode(with: aCoder)
            aCoder.encode(self.cases, forKey: "cases")
            aCoder.encode(self.rawTypeName, forKey: "rawTypeName")
            aCoder.encode(self.hasRawType, forKey: "hasRawType")
            aCoder.encode(self.rawType, forKey: "rawType")
        }
// sourcery:end
}
