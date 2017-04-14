//
// Created by Krzysztof Zabłocki on 25/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

/// Descibes typed declaration, i.e. variable, method parameter, tuple element, enum case associated value
public protocol Typed {

    // sourcery: skipEquality, skipDescription
    /// Type, if known
    var type: Type? { get }

    // sourcery: skipEquality, skipDescription
    /// Type name
    var typeName: TypeName { get }

    // sourcery: skipEquality, skipDescription
    /// Whether type is optional
    var isOptional: Bool { get }

    // sourcery: skipEquality, skipDescription
    /// Whether type is implicitly unwrapped optional
    var isImplicitlyUnwrappedOptional: Bool { get }

    // sourcery: skipEquality, skipDescription
    /// Type name without attributes and optional type information
    var unwrappedTypeName: String { get }
}

/// Describes name of the type used in typed declaration (variable, method parameter or return value etc.)
public final class TypeName: NSObject, AutoCoding, AutoEquatable, AutoDiffable, AutoJSExport {

    init(_ name: String,
         actualTypeName: TypeName? = nil,
         attributes: [String: Attribute] = [:],
         tuple: TupleType? = nil,
         array: ArrayType? = nil,
         dictionary: DictionaryType? = nil) {

        self.name = name
        self.actualTypeName = actualTypeName
        self.attributes = attributes
        self.tuple = tuple
        self.array = array
        self.dictionary = dictionary

        var name = name
        attributes.forEach {
            name = name.trimmingPrefix($0.value.description)
                .trimmingCharacters(in: .whitespaces)
        }

        if let genericConstraint = name.range(of: "where") {
            name = String(name.characters.prefix(upTo: genericConstraint.lowerBound))
                .trimmingCharacters(in: .whitespaces)
        }

        if name.isEmpty {
            self.unwrappedTypeName = "Void"
            self.isImplicitlyUnwrappedOptional = false
            self.isOptional = false
        } else {
            name = name.bracketsBalancing()
            let isImplicitlyUnwrappedOptional = name.hasSuffix("!") || name.hasPrefix("ImplicitlyUnwrappedOptional<")
            let isOptional = name.hasSuffix("?") || name.hasPrefix("Optional<") || isImplicitlyUnwrappedOptional
            self.isImplicitlyUnwrappedOptional = isImplicitlyUnwrappedOptional
            self.isOptional = isOptional

            if isOptional {
                let unwrappedTypeName: String
                if name.hasSuffix("?") || name.hasSuffix("!") {
                    unwrappedTypeName = String(name.characters.dropLast())
                } else if name.hasPrefix("Optional<") {
                    unwrappedTypeName = name.drop(first: "Optional<".characters.count, last: 1)
                } else {
                    unwrappedTypeName = name.drop(first: "ImplicitlyUnwrappedOptional<".characters.count, last: 1)
                }
                self.unwrappedTypeName = unwrappedTypeName.bracketsBalancing()
            } else {
                self.unwrappedTypeName = name
            }
        }
    }

    /// Type name used in declaration
    public let name: String

    // sourcery: skipEquality
    /// Actual type name if given type name is a typealias
    public internal(set) var actualTypeName: TypeName?

    /// Type name attributes, i.e. `@escaping`
    public let attributes: [String: Attribute]

    // sourcery: skipEquality
    /// Whether type is optional
    public let isOptional: Bool

    // sourcery: skipEquality
    /// Whether type is implicitly unwrapped optional
    public let isImplicitlyUnwrappedOptional: Bool

    // sourcery: skipEquality
    /// Type name without attributes and optional type information
    public let unwrappedTypeName: String

    // sourcery: skipEquality
    /// Whether type is void (`Void` or `()`)
    public var isVoid: Bool {
        return name == "Void" || name == "()" || unwrappedTypeName == "Void"
    }

    /// Whether type is a tuple
    public var isTuple: Bool {
        if let actualTypeName = actualTypeName?.unwrappedTypeName {
            return actualTypeName.isValidTupleName()
        } else {
            return unwrappedTypeName.isValidTupleName()
        }
    }

    /// Tuple type data
    public var tuple: TupleType?

    /// Whether type is an array
    public var isArray: Bool {
        if let actualTypeName = actualTypeName?.unwrappedTypeName {
            return actualTypeName.isValidArrayName()
        } else {
            return unwrappedTypeName.isValidArrayName()
        }
    }

    /// Array type data
    public var array: ArrayType?

    /// Whether type is a dictionary
    public var isDictionary: Bool {
        if let actualTypeName = actualTypeName?.unwrappedTypeName {
            return actualTypeName.isValidDictionaryName()
        } else {
            return unwrappedTypeName.isValidDictionaryName()
        }
    }

    /// Dictionary type data
    public internal(set) var dictionary: DictionaryType?

    /// Whether type is a closure
    public var isClosure: Bool {
        if let actualTypeName = actualTypeName?.unwrappedTypeName {
            return actualTypeName.isValidClosureName()
        } else {
            return unwrappedTypeName.isValidClosureName()
        }
    }

    /// Returns value of `name` property.
    public override var description: String {
        return name
    }

    // sourcery:inline:TypeName.AutoCoding
        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            self.actualTypeName = aDecoder.decode(forKey: "actualTypeName")
            guard let attributes: [String: Attribute] = aDecoder.decode(forKey: "attributes") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["attributes"])); fatalError() }; self.attributes = attributes
            self.isOptional = aDecoder.decode(forKey: "isOptional")
            self.isImplicitlyUnwrappedOptional = aDecoder.decode(forKey: "isImplicitlyUnwrappedOptional")
            guard let unwrappedTypeName: String = aDecoder.decode(forKey: "unwrappedTypeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["unwrappedTypeName"])); fatalError() }; self.unwrappedTypeName = unwrappedTypeName
            self.tuple = aDecoder.decode(forKey: "tuple")
            self.array = aDecoder.decode(forKey: "array")
            self.dictionary = aDecoder.decode(forKey: "dictionary")
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.actualTypeName, forKey: "actualTypeName")
            aCoder.encode(self.attributes, forKey: "attributes")
            aCoder.encode(self.isOptional, forKey: "isOptional")
            aCoder.encode(self.isImplicitlyUnwrappedOptional, forKey: "isImplicitlyUnwrappedOptional")
            aCoder.encode(self.unwrappedTypeName, forKey: "unwrappedTypeName")
            aCoder.encode(self.tuple, forKey: "tuple")
            aCoder.encode(self.array, forKey: "array")
            aCoder.encode(self.dictionary, forKey: "dictionary")
        }
        // sourcery:end

}

/// Describes tuple type element
public final class TupleElement: NSObject, SourceryModel, Typed {

    /// Tuple element name
    public let name: String

    /// Tuple element type name
    public let typeName: TypeName

    // sourcery: skipEquality, skipDescription
    /// Tuple element type, if known
    public internal(set) var type: Type?

    init(name: String = "", typeName: TypeName, type: Type? = nil) {
        self.name = name
        self.typeName = typeName
        self.type = type
    }

    // sourcery:inline:TupleElement.AutoCoding
        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let typeName: TypeName = aDecoder.decode(forKey: "typeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typeName"])); fatalError() }; self.typeName = typeName
            self.type = aDecoder.decode(forKey: "type")
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.typeName, forKey: "typeName")
            aCoder.encode(self.type, forKey: "type")
        }
     // sourcery:end
}

/// Describes tuple type
public final class TupleType: NSObject, SourceryModel {

    /// Type name used in declaration
    public let name: String

    /// Tuple elements
    public let elements: [TupleElement]

    init(name: String, elements: [TupleElement]) {
        self.name = name
        self.elements = elements
    }

    // sourcery:inline:TupleType.AutoCoding
        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let elements: [TupleElement] = aDecoder.decode(forKey: "elements") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["elements"])); fatalError() }; self.elements = elements
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.elements, forKey: "elements")
        }
     // sourcery:end
}

/// Describes array type
public final class ArrayType: NSObject, SourceryModel {

    /// Type name used in declaration
    public let name: String

    /// Array element type name
    public let elementTypeName: TypeName

    // sourcery: skipEquality, skipDescription
    /// Array element type, if known
    public internal(set) var elementType: Type?

    init(name: String, elementTypeName: TypeName, elementType: Type? = nil) {
        self.name = name
        self.elementTypeName = elementTypeName
        self.elementType = elementType
    }

    // sourcery:inline:ArrayType.AutoCoding
        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let elementTypeName: TypeName = aDecoder.decode(forKey: "elementTypeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["elementTypeName"])); fatalError() }; self.elementTypeName = elementTypeName
            self.elementType = aDecoder.decode(forKey: "elementType")
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.elementTypeName, forKey: "elementTypeName")
            aCoder.encode(self.elementType, forKey: "elementType")
        }
    // sourcery:end
}

/// Describes dictionary type
public final class DictionaryType: NSObject, SourceryModel {

    /// Type name used in declaration
    public let name: String

    /// Dictionary value type name
    public let valueTypeName: TypeName

    // sourcery: skipEquality, skipDescription
    /// Dictionary value type, if known
    public internal(set) var valueType: Type?

    /// Dictionary key type name
    public let keyTypeName: TypeName

    // sourcery: skipEquality, skipDescription
    /// Dictionary key type, if known
    public internal(set) var keyType: Type?

    init(name: String, valueTypeName: TypeName, valueType: Type? = nil, keyTypeName: TypeName, keyType: Type? = nil) {
        self.name = name
        self.valueTypeName = valueTypeName
        self.valueType = valueType
        self.keyTypeName = keyTypeName
        self.keyType = keyType
    }

    // sourcery:inline:DictionaryType.AutoCoding
        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let valueTypeName: TypeName = aDecoder.decode(forKey: "valueTypeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["valueTypeName"])); fatalError() }; self.valueTypeName = valueTypeName
            self.valueType = aDecoder.decode(forKey: "valueType")
            guard let keyTypeName: TypeName = aDecoder.decode(forKey: "keyTypeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["keyTypeName"])); fatalError() }; self.keyTypeName = keyTypeName
            self.keyType = aDecoder.decode(forKey: "keyType")
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.valueTypeName, forKey: "valueTypeName")
            aCoder.encode(self.valueType, forKey: "valueType")
            aCoder.encode(self.keyTypeName, forKey: "keyTypeName")
            aCoder.encode(self.keyType, forKey: "keyType")
        }
    // sourcery:end
}
