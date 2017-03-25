//
// Created by Krzysztof Zabłocki on 25/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

/// Descibes typed declaration, i.e. variable, method parameter, tuple element, enum case associated value
protocol Typed {

    /// Type, if known
    // sourcery: skipEquality, skipDescription
    var type: Type? { get set }

    /// Type name
    // sourcery: skipEquality, skipDescription
    var typeName: TypeName { get }

    /// Whether type is optional
    // sourcery: skipEquality, skipDescription
    var isOptional: Bool { get }

    /// Whether type is implicitly unwrapped optional
    // sourcery: skipEquality, skipDescription
    var isImplicitlyUnwrappedOptional: Bool { get }

    /// Type name without attributes and optional type information
    // sourcery: skipEquality, skipDescription
    var unwrappedTypeName: String { get }
}

/// Describes name of the type used in typed declaration (variable, method parameter or return value etc.)
final class TypeName: NSObject, AutoCoding, AutoEquatable, AutoDiffable, AutoJSExport {

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

    /// Type name
    let name: String

    /// Actual type name if given type name is a typealias
    // sourcery: skipEquality
    var actualTypeName: TypeName?

    /// Type name attributes, i.e. `@escaping`
    let attributes: [String: Attribute]

    /// Whether type is optional
    // sourcery: skipEquality
    let isOptional: Bool

    /// Whether type is implicitly unwrapped optional
    // sourcery: skipEquality
    let isImplicitlyUnwrappedOptional: Bool

    /// Type name without attributes and optional type information
    // sourcery: skipEquality
    let unwrappedTypeName: String

    /// Whether type is void (`Void` or `()`)
    // sourcery: skipEquality
    var isVoid: Bool {
        return name == "Void" || name == "()" || unwrappedTypeName == "Void"
    }

    /// Whether type is a tuple
    var isTuple: Bool {
        if let actualTypeName = actualTypeName?.unwrappedTypeName {
            return actualTypeName.isValidTupleName()
        } else {
            return unwrappedTypeName.isValidTupleName()
        }
    }

    /// Tuple type data
    var tuple: TupleType?

    /// Whether type is an array
    var isArray: Bool {
        if let actualTypeName = actualTypeName?.unwrappedTypeName {
            return actualTypeName.isValidArrayName()
        } else {
            return unwrappedTypeName.isValidArrayName()
        }
    }

    /// Array type data
    var array: ArrayType?

    /// Whether type is a dictionary
    var isDictionary: Bool {
        if let actualTypeName = actualTypeName?.unwrappedTypeName {
            return actualTypeName.isValidDictionaryName()
        } else {
            return unwrappedTypeName.isValidDictionaryName()
        }
    }

    /// Dictionary type data
    var dictionary: DictionaryType?

    /// Whether type is a closure
    var isClosure: Bool {
        if let actualTypeName = actualTypeName?.unwrappedTypeName {
            return actualTypeName.isValidClosureName()
        } else {
            return unwrappedTypeName.isValidClosureName()
        }
    }

    override var description: String {
        return name
    }

    // sourcery:inline:TypeName.AutoCoding
        required init?(coder aDecoder: NSCoder) {
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

        func encode(with aCoder: NSCoder) {
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
final class TupleElement: NSObject, SourceryModel, Typed {

    /// Tuple type element name
    let name: String

    /// Tuple type element type name
    let typeName: TypeName

    /// Tuple type element type, if known
    // sourcery: skipEquality, skipDescription
    var type: Type?

    init(name: String = "", typeName: TypeName, type: Type? = nil) {
        self.name = name
        self.typeName = typeName
        self.type = type
    }

    // sourcery:inline:TupleElement.AutoCoding
        required init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let typeName: TypeName = aDecoder.decode(forKey: "typeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typeName"])); fatalError() }; self.typeName = typeName
            self.type = aDecoder.decode(forKey: "type")
        }

        func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.typeName, forKey: "typeName")
            aCoder.encode(self.type, forKey: "type")
        }
     // sourcery:end
}

/// Describes tuple type
final class TupleType: NSObject, SourceryModel {

    /// Type name
    let name: String

    /// Tuple elements
    let elements: [TupleElement]

    init(name: String, elements: [TupleElement]) {
        self.name = name
        self.elements = elements
    }

    // sourcery:inline:TupleType.AutoCoding
        required init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let elements: [TupleElement] = aDecoder.decode(forKey: "elements") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["elements"])); fatalError() }; self.elements = elements
        }

        func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.elements, forKey: "elements")
        }
     // sourcery:end
}

/// Describes array type
final class ArrayType: NSObject, SourceryModel {

    /// Type name
    let name: String

    /// Array element type name
    let elementTypeName: TypeName

    /// Array element type, if known
    var elementType: Type?

    init(name: String, elementTypeName: TypeName, elementType: Type? = nil) {
        self.name = name
        self.elementTypeName = elementTypeName
        self.elementType = elementType
    }

    // sourcery:inline:ArrayType.AutoCoding
        required init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let elementTypeName: TypeName = aDecoder.decode(forKey: "elementTypeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["elementTypeName"])); fatalError() }; self.elementTypeName = elementTypeName
            self.elementType = aDecoder.decode(forKey: "elementType")
        }

        func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.elementTypeName, forKey: "elementTypeName")
            aCoder.encode(self.elementType, forKey: "elementType")
        }
    // sourcery:end
}

/// Describes dictionary type
final class DictionaryType: NSObject, SourceryModel {

    /// Type name
    let name: String

    /// Dictionary value type name
    let valueTypeName: TypeName

    /// Dictionary value type, if known
    var valueType: Type?

    /// Dictionary key type name
    let keyTypeName: TypeName

    /// Dictionary key type, if known
    var keyType: Type?

    init(name: String, valueTypeName: TypeName, valueType: Type? = nil, keyTypeName: TypeName, keyType: Type? = nil) {
        self.name = name
        self.valueTypeName = valueTypeName
        self.valueType = valueType
        self.keyTypeName = keyTypeName
        self.keyType = keyType
    }

    // sourcery:inline:DictionaryType.AutoCoding
        required init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let valueTypeName: TypeName = aDecoder.decode(forKey: "valueTypeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["valueTypeName"])); fatalError() }; self.valueTypeName = valueTypeName
            self.valueType = aDecoder.decode(forKey: "valueType")
            guard let keyTypeName: TypeName = aDecoder.decode(forKey: "keyTypeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["keyTypeName"])); fatalError() }; self.keyTypeName = keyTypeName
            self.keyType = aDecoder.decode(forKey: "keyType")
        }

        func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.valueTypeName, forKey: "valueTypeName")
            aCoder.encode(self.valueType, forKey: "valueType")
            aCoder.encode(self.keyTypeName, forKey: "keyTypeName")
            aCoder.encode(self.keyType, forKey: "keyType")
        }
    // sourcery:end
}
