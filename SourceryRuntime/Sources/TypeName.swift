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
@objcMembers public final class TypeName: NSObject, AutoCoding, AutoEquatable, AutoDiffable, AutoJSExport, LosslessStringConvertible {

    /// :nodoc:
    public init(_ name: String,
                actualTypeName: TypeName? = nil,
                attributes: [String: Attribute] = [:],
                tuple: TupleType? = nil,
                array: ArrayType? = nil,
                dictionary: DictionaryType? = nil,
                closure: ClosureType? = nil,
                generic: GenericType? = nil) {

        self.name = name
        self.actualTypeName = actualTypeName
        self.attributes = attributes
        self.tuple = tuple
        self.array = array
        self.dictionary = dictionary
        self.closure = closure
        self.generic = generic

        var name = name
        attributes.forEach {
            name = name.trimmingPrefix($0.value.description)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if let genericConstraint = name.range(of: "where") {
            name = String(name.prefix(upTo: genericConstraint.lowerBound))
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if name.isEmpty {
            self.unwrappedTypeName = "Void"
            self.isImplicitlyUnwrappedOptional = false
            self.isOptional = false
            self.isGeneric = false
        } else {
            name = name.bracketsBalancing()
            name = name.trimmingPrefix("inout ").trimmingCharacters(in: .whitespacesAndNewlines)
            let isImplicitlyUnwrappedOptional = name.hasSuffix("!") || name.hasPrefix("ImplicitlyUnwrappedOptional<")
            let isOptional = name.hasSuffix("?") || name.hasPrefix("Optional<") || isImplicitlyUnwrappedOptional
            self.isImplicitlyUnwrappedOptional = isImplicitlyUnwrappedOptional
            self.isOptional = isOptional

            var unwrappedTypeName: String

            if isOptional {
                if name.hasSuffix("?") || name.hasSuffix("!") {
                    unwrappedTypeName = String(name.dropLast())
                } else if name.hasPrefix("Optional<") {
                    unwrappedTypeName = name.drop(first: "Optional<".count, last: 1)
                } else {
                    unwrappedTypeName = name.drop(first: "ImplicitlyUnwrappedOptional<".count, last: 1)
                }
                unwrappedTypeName = unwrappedTypeName.bracketsBalancing()
            } else {
                unwrappedTypeName = name
            }

            self.unwrappedTypeName = unwrappedTypeName
            self.isGeneric = (unwrappedTypeName.contains("<") && unwrappedTypeName.last == ">")
                || unwrappedTypeName.isValidArrayName()
                || unwrappedTypeName.isValidDictionaryName()
        }
    }

    /// Type name used in declaration
    public let name: String

    /// The generics of this TypeName
    public var generic: GenericType?

    /// Whether this TypeName is generic
    public let isGeneric: Bool

    // sourcery: skipEquality
    /// Actual type name if given type name is a typealias
    public var actualTypeName: TypeName?

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
    public var dictionary: DictionaryType?

    /// Whether type is a closure
    public var isClosure: Bool {
        if let actualTypeName = actualTypeName?.unwrappedTypeName {
            return actualTypeName.isValidClosureName()
        } else {
            return unwrappedTypeName.isValidClosureName()
        }
    }

    /// Closure type data
    public var closure: ClosureType?

    /// Returns value of `name` property.
    public override var description: String {
        return name
    }

    // sourcery:inline:TypeName.AutoCoding
        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            self.generic = aDecoder.decode(forKey: "generic")
            self.isGeneric = aDecoder.decode(forKey: "isGeneric")
            self.actualTypeName = aDecoder.decode(forKey: "actualTypeName")
            guard let attributes: [String: Attribute] = aDecoder.decode(forKey: "attributes") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["attributes"])); fatalError() }; self.attributes = attributes
            self.isOptional = aDecoder.decode(forKey: "isOptional")
            self.isImplicitlyUnwrappedOptional = aDecoder.decode(forKey: "isImplicitlyUnwrappedOptional")
            guard let unwrappedTypeName: String = aDecoder.decode(forKey: "unwrappedTypeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["unwrappedTypeName"])); fatalError() }; self.unwrappedTypeName = unwrappedTypeName
            self.tuple = aDecoder.decode(forKey: "tuple")
            self.array = aDecoder.decode(forKey: "array")
            self.dictionary = aDecoder.decode(forKey: "dictionary")
            self.closure = aDecoder.decode(forKey: "closure")
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.generic, forKey: "generic")
            aCoder.encode(self.isGeneric, forKey: "isGeneric")
            aCoder.encode(self.actualTypeName, forKey: "actualTypeName")
            aCoder.encode(self.attributes, forKey: "attributes")
            aCoder.encode(self.isOptional, forKey: "isOptional")
            aCoder.encode(self.isImplicitlyUnwrappedOptional, forKey: "isImplicitlyUnwrappedOptional")
            aCoder.encode(self.unwrappedTypeName, forKey: "unwrappedTypeName")
            aCoder.encode(self.tuple, forKey: "tuple")
            aCoder.encode(self.array, forKey: "array")
            aCoder.encode(self.dictionary, forKey: "dictionary")
            aCoder.encode(self.closure, forKey: "closure")
        }
        // sourcery:end

    // MARK: - LosslessStringConvertible

    /// :nodoc:
    public convenience init(_ description: String) {
        self.init(description, actualTypeName: nil)
    }

    // sourcery: skipEquality, skipDescription
    /// :nodoc:
    public override var debugDescription: String {
        return name
    }
}

/// Descibes Swift generic type parameter
@objcMembers public final class GenericTypeParameter: NSObject, SourceryModel {

    /// Generic parameter type name
    public let typeName: TypeName

    // sourcery: skipEquality, skipDescription
    /// Generic parameter type, if known
    public var type: Type?

    /// :nodoc:
    public init(typeName: TypeName, type: Type? = nil) {
        self.typeName = typeName
        self.type = type
    }

    // sourcery:inline:GenericTypeParameter.AutoCoding
        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let typeName: TypeName = aDecoder.decode(forKey: "typeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typeName"])); fatalError() }; self.typeName = typeName
            self.type = aDecoder.decode(forKey: "type")
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.typeName, forKey: "typeName")
            aCoder.encode(self.type, forKey: "type")
        }

    // sourcery:end
}

/// Descibes Swift generic type
@objcMembers public final class GenericType: NSObject, SourceryModel {
    /// The name of the base type, i.e. `Array` for `Array<Int>`
    public let name: String

    /// This generic type parameters
    public let typeParameters: [GenericTypeParameter]

    /// :nodoc:
    public init(name: String, typeParameters: [GenericTypeParameter] = []) {
        self.name = name
        self.typeParameters = typeParameters
    }

    // sourcery:inline:GenericType.AutoCoding
        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let typeParameters: [GenericTypeParameter] = aDecoder.decode(forKey: "typeParameters") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typeParameters"])); fatalError() }; self.typeParameters = typeParameters
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.typeParameters, forKey: "typeParameters")
        }

    // sourcery:end
}

/// Describes tuple type element
@objcMembers public final class TupleElement: NSObject, SourceryModel, Typed {

    /// Tuple element name
    public let name: String

    /// Tuple element type name
    public let typeName: TypeName

    // sourcery: skipEquality, skipDescription
    /// Tuple element type, if known
    public var type: Type?

    /// :nodoc:
    public init(name: String = "", typeName: TypeName, type: Type? = nil) {
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
@objcMembers public final class TupleType: NSObject, SourceryModel {

    /// Type name used in declaration
    public let name: String

    /// Tuple elements
    public let elements: [TupleElement]

    /// :nodoc:
    public init(name: String, elements: [TupleElement]) {
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
@objcMembers public final class ArrayType: NSObject, SourceryModel {

    /// Type name used in declaration
    public let name: String

    /// Array element type name
    public let elementTypeName: TypeName

    // sourcery: skipEquality, skipDescription
    /// Array element type, if known
    public var elementType: Type?

    /// :nodoc:
    public init(name: String, elementTypeName: TypeName, elementType: Type? = nil) {
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
@objcMembers public final class DictionaryType: NSObject, SourceryModel {

    /// Type name used in declaration
    public let name: String

    /// Dictionary value type name
    public let valueTypeName: TypeName

    // sourcery: skipEquality, skipDescription
    /// Dictionary value type, if known
    public var valueType: Type?

    /// Dictionary key type name
    public let keyTypeName: TypeName

    // sourcery: skipEquality, skipDescription
    /// Dictionary key type, if known
    public var keyType: Type?

    /// :nodoc:
    public init(name: String, valueTypeName: TypeName, valueType: Type? = nil, keyTypeName: TypeName, keyType: Type? = nil) {
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

/// Describes closure type
@objcMembers public final class ClosureType: NSObject, SourceryModel {

    /// Type name used in declaration with stripped whitespaces and new lines
    public let name: String

    /// List of closure parameters
    public let parameters: [MethodParameter]

    /// Return value type name
    public let returnTypeName: TypeName

    /// Actual return value type name if declaration uses typealias, otherwise just a `returnTypeName`
    public var actualReturnTypeName: TypeName {
        return returnTypeName.actualTypeName ?? returnTypeName
    }

    // sourcery: skipEquality, skipDescription
    /// Actual return value type, if known
    public var returnType: Type?

    // sourcery: skipEquality, skipDescription
    /// Whether return value type is optional
    public var isOptionalReturnType: Bool {
        return returnTypeName.isOptional
    }

    // sourcery: skipEquality, skipDescription
    /// Whether return value type is implicitly unwrapped optional
    public var isImplicitlyUnwrappedOptionalReturnType: Bool {
        return returnTypeName.isImplicitlyUnwrappedOptional
    }

    // sourcery: skipEquality, skipDescription
    /// Return value type name without attributes and optional type information
    public var unwrappedReturnTypeName: String {
        return returnTypeName.unwrappedTypeName
    }

    /// Whether closure throws
    public let `throws`: Bool

    /// :nodoc:
    public init(name: String, parameters: [MethodParameter], returnTypeName: TypeName, returnType: Type? = nil, `throws`: Bool = false) {
        self.name = name
        self.parameters = parameters
        self.returnTypeName = returnTypeName
        self.returnType = returnType
        self.`throws` = `throws`
    }

    // sourcery:inline:ClosureType.AutoCoding
        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let parameters: [MethodParameter] = aDecoder.decode(forKey: "parameters") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["parameters"])); fatalError() }; self.parameters = parameters
            guard let returnTypeName: TypeName = aDecoder.decode(forKey: "returnTypeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["returnTypeName"])); fatalError() }; self.returnTypeName = returnTypeName
            self.returnType = aDecoder.decode(forKey: "returnType")
            self.`throws` = aDecoder.decode(forKey: "`throws`")
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.parameters, forKey: "parameters")
            aCoder.encode(self.returnTypeName, forKey: "returnTypeName")
            aCoder.encode(self.returnType, forKey: "returnType")
            aCoder.encode(self.`throws`, forKey: "`throws`")
        }
    // sourcery:end

}
