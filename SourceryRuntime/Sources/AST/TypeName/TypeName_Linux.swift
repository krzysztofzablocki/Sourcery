//
// Created by Krzysztof Zabłocki on 25/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//
#if !canImport(ObjectiveC)
import Foundation
// For DynamicMemberLookup we need to import Stencil,
// however, this is different from SourceryRuntime.content.generated.swift, because
// it cannot reference Stencil
import Stencil

/// Describes name of the type used in typed declaration (variable, method parameter or return value etc.)
public final class TypeName: NSObject, SourceryModelWithoutDescription, LosslessStringConvertible, Diffable, DynamicMemberLookup {
    public subscript(dynamicMember member: String) -> Any? {
        switch member {
            case "tuple":
                return tuple
            case "name":
                return name
            case "isOptional":
                return isOptional
            case "unwrappedTypeName":
                return unwrappedTypeName
            case "isProtocolComposition":
                return isProtocolComposition
            case "isVoid":
                return isVoid
            case "isClosure":
                return isClosure
            case "closure":
                return closure
            default:
                fatalError("unable to lookup: \(member) in \(self)")
        }
    }

    /// :nodoc:
    public init(name: String,
                actualTypeName: TypeName? = nil,
                unwrappedTypeName: String? = nil,
                attributes: AttributeList = [:],
                isOptional: Bool = false,
                isImplicitlyUnwrappedOptional: Bool = false,
                tuple: TupleType? = nil,
                array: ArrayType? = nil,
                dictionary: DictionaryType? = nil,
                closure: ClosureType? = nil,
                generic: GenericType? = nil,
                isProtocolComposition: Bool = false) {

        let optionalSuffix: String
        // TODO: TBR
        if !name.hasPrefix("Optional<") && !name.contains(" where ") {
            if isOptional {
                optionalSuffix = "?"
            } else if isImplicitlyUnwrappedOptional {
                optionalSuffix = "!"
            } else {
                optionalSuffix = ""
            }
        } else {
            optionalSuffix = ""
        }

        self.name = name + optionalSuffix
        self.actualTypeName = actualTypeName
        self.unwrappedTypeName = unwrappedTypeName ?? name
        self.tuple = tuple
        self.array = array
        self.dictionary = dictionary
        self.closure = closure
        self.generic = generic
        self.isOptional = isOptional || isImplicitlyUnwrappedOptional
        self.isImplicitlyUnwrappedOptional = isImplicitlyUnwrappedOptional
        self.isProtocolComposition = isProtocolComposition

        self.attributes = attributes
        self.modifiers = []
        super.init()
    }

    /// Type name used in declaration
    public var name: String

    /// The generics of this TypeName
    public var generic: GenericType?

    /// Whether this TypeName is generic
    public var isGeneric: Bool {
        actualTypeName?.generic != nil || generic != nil
    }

    /// Whether this TypeName is protocol composition
    public var isProtocolComposition: Bool

    // sourcery: skipEquality
    /// Actual type name if given type name is a typealias
    public var actualTypeName: TypeName?

    /// Type name attributes, i.e. `@escaping`
    public var attributes: AttributeList

    /// Modifiers, i.e. `escaping`
    public var modifiers: [SourceryModifier]

    // sourcery: skipEquality
    /// Whether type is optional
    public let isOptional: Bool

    // sourcery: skipEquality
    /// Whether type is implicitly unwrapped optional
    public let isImplicitlyUnwrappedOptional: Bool

    // sourcery: skipEquality
    /// Type name without attributes and optional type information
    public var unwrappedTypeName: String

    // sourcery: skipEquality
    /// Whether type is void (`Void` or `()`)
    public var isVoid: Bool {
        return name == "Void" || name == "()" || unwrappedTypeName == "Void"
    }

    /// Whether type is a tuple
    public var isTuple: Bool {
        actualTypeName?.tuple != nil || tuple != nil
    }

    /// Tuple type data
    public var tuple: TupleType?

    /// Whether type is an array
    public var isArray: Bool {
        actualTypeName?.array != nil || array != nil
    }

    /// Array type data
    public var array: ArrayType?

    /// Whether type is a dictionary
    public var isDictionary: Bool {
        actualTypeName?.dictionary != nil || dictionary != nil
    }

    /// Dictionary type data
    public var dictionary: DictionaryType?

    /// Whether type is a closure
    public var isClosure: Bool {
        actualTypeName?.closure != nil || closure != nil
    }

    /// Closure type data
    public var closure: ClosureType?

    /// Prints typename as it would appear on definition
    public var asSource: String {
        // TODO: TBR special treatment
        let specialTreatment = isOptional && name.hasPrefix("Optional<")

        var description = (
          attributes.flatMap({ $0.value }).map({ $0.asSource }).sorted() +
          modifiers.map({ $0.asSource }) +
          [specialTreatment ? name : unwrappedTypeName]
        ).joined(separator: " ")

        if let _ = self.dictionary { // array and dictionary cases are covered by the unwrapped type name
//            description.append(dictionary.asSource)
        } else if let _ = self.array {
//            description.append(array.asSource)
        } else if let _ = self.generic {
//            let arguments = generic.typeParameters
//              .map({ $0.typeName.asSource })
//              .joined(separator: ", ")
//            description.append("<\(arguments)>")
        }
        if !specialTreatment {
            if isImplicitlyUnwrappedOptional {
                description.append("!")
            } else if isOptional {
                description.append("?")
            }
        }

        return description
    }

    public override var description: String {
       (
          attributes.flatMap({ $0.value }).map({ $0.asSource }).sorted() +
          modifiers.map({ $0.asSource }) +
          [name]
        ).joined(separator: " ")
    }

    public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? TypeName else {
            results.append("Incorrect type <expected: TypeName, received: \(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: castObject.name))
        results.append(contentsOf: DiffableResult(identifier: "generic").trackDifference(actual: self.generic, expected: castObject.generic))
        results.append(contentsOf: DiffableResult(identifier: "isProtocolComposition").trackDifference(actual: self.isProtocolComposition, expected: castObject.isProtocolComposition))
        results.append(contentsOf: DiffableResult(identifier: "attributes").trackDifference(actual: self.attributes, expected: castObject.attributes))
        results.append(contentsOf: DiffableResult(identifier: "modifiers").trackDifference(actual: self.modifiers, expected: castObject.modifiers))
        results.append(contentsOf: DiffableResult(identifier: "tuple").trackDifference(actual: self.tuple, expected: castObject.tuple))
        results.append(contentsOf: DiffableResult(identifier: "array").trackDifference(actual: self.array, expected: castObject.array))
        results.append(contentsOf: DiffableResult(identifier: "dictionary").trackDifference(actual: self.dictionary, expected: castObject.dictionary))
        results.append(contentsOf: DiffableResult(identifier: "closure").trackDifference(actual: self.closure, expected: castObject.closure))
        return results
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.generic)
        hasher.combine(self.isProtocolComposition)
        hasher.combine(self.attributes)
        hasher.combine(self.modifiers)
        hasher.combine(self.tuple)
        hasher.combine(self.array)
        hasher.combine(self.dictionary)
        hasher.combine(self.closure)
        return hasher.finalize()
    }

    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TypeName else { return false }
        if self.name != rhs.name { return false }
        if self.generic != rhs.generic { return false }
        if self.isProtocolComposition != rhs.isProtocolComposition { return false }
        if self.attributes != rhs.attributes { return false }
        if self.modifiers != rhs.modifiers { return false }
        if self.tuple != rhs.tuple { return false }
        if self.array != rhs.array { return false }
        if self.dictionary != rhs.dictionary { return false }
        if self.closure != rhs.closure { return false }
        return true
    }

// sourcery:inline:TypeName.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { 
                withVaList(["name"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.name = name
            self.generic = aDecoder.decode(forKey: "generic")
            self.isProtocolComposition = aDecoder.decode(forKey: "isProtocolComposition")
            self.actualTypeName = aDecoder.decode(forKey: "actualTypeName")
            guard let attributes: AttributeList = aDecoder.decode(forKey: "attributes") else { 
                withVaList(["attributes"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.attributes = attributes
            guard let modifiers: [SourceryModifier] = aDecoder.decode(forKey: "modifiers") else { 
                withVaList(["modifiers"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.modifiers = modifiers
            self.isOptional = aDecoder.decode(forKey: "isOptional")
            self.isImplicitlyUnwrappedOptional = aDecoder.decode(forKey: "isImplicitlyUnwrappedOptional")
            guard let unwrappedTypeName: String = aDecoder.decode(forKey: "unwrappedTypeName") else { 
                withVaList(["unwrappedTypeName"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.unwrappedTypeName = unwrappedTypeName
            self.tuple = aDecoder.decode(forKey: "tuple")
            self.array = aDecoder.decode(forKey: "array")
            self.dictionary = aDecoder.decode(forKey: "dictionary")
            self.closure = aDecoder.decode(forKey: "closure")
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.generic, forKey: "generic")
            aCoder.encode(self.isProtocolComposition, forKey: "isProtocolComposition")
            aCoder.encode(self.actualTypeName, forKey: "actualTypeName")
            aCoder.encode(self.attributes, forKey: "attributes")
            aCoder.encode(self.modifiers, forKey: "modifiers")
            aCoder.encode(self.isOptional, forKey: "isOptional")
            aCoder.encode(self.isImplicitlyUnwrappedOptional, forKey: "isImplicitlyUnwrappedOptional")
            aCoder.encode(self.unwrappedTypeName, forKey: "unwrappedTypeName")
            aCoder.encode(self.tuple, forKey: "tuple")
            aCoder.encode(self.array, forKey: "array")
            aCoder.encode(self.dictionary, forKey: "dictionary")
            aCoder.encode(self.closure, forKey: "closure")
        }
// sourcery:end

    // sourcery: skipEquality, skipDescription
    /// :nodoc:
    public override var debugDescription: String {
        return name
    }

    public convenience init(_ description: String) {
        self.init(name: description, actualTypeName: nil)
    }
}

extension TypeName {
    public static func unknown(description: String?, attributes: AttributeList = [:]) -> TypeName {
        if let description = description {
            Log.astWarning("Unknown type, please add type attribution to \(description)")
        } else {
            Log.astWarning("Unknown type, please add type attribution")
        }
        return TypeName(name: "UnknownTypeSoAddTypeAttributionToVariable", attributes: attributes)
    }
}
#endif
