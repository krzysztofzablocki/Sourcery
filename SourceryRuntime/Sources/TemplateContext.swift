//
// Created by Krzysztof Zablocki on 31/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import Stencil

/// :nodoc:
// sourcery: skipCoding
#if canImport(ObjectiveC)
@objcMembers
#endif
public final class TemplateContext: NSObject, SourceryModel, NSCoding, Diffable {
    // sourcery: skipJSExport
    public let parserResult: FileParserResult?
    public let functions: [SourceryMethod]
    public let types: Types
    public let argument: [String: NSObject]

    // sourcery: skipDescription
    public var type: [String: Type] {
        return types.typesByName
    }

    public init(parserResult: FileParserResult?, types: Types, functions: [SourceryMethod], arguments: [String: NSObject]) {
        self.parserResult = parserResult
        self.types = types
        self.functions = functions
        self.argument = arguments
    }

    /// :nodoc:
    required public init?(coder aDecoder: NSCoder) {
        guard let parserResult: FileParserResult = aDecoder.decode(forKey: "parserResult") else { 
                withVaList(["parserResult"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found. FileParserResults are required for template context that needs persisting.", arguments: arguments)
                }
                fatalError()
             }
        guard let argument: [String: NSObject] = aDecoder.decode(forKey: "argument") else { 
                withVaList(["argument"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }

        // if we want to support multiple cycles of encode / decode we need deep copy because composer changes reference types
        let fileParserResultCopy: FileParserResult? = nil
//      fileParserResultCopy = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(NSKeyedArchiver.archivedData(withRootObject: parserResult)) as? FileParserResult

        let composed = Composer.uniqueTypesAndFunctions(parserResult)
        self.types = .init(types: composed.types, typealiases: composed.typealiases)
        self.functions = composed.functions

        self.parserResult = fileParserResultCopy
        self.argument = argument
    }

    /// :nodoc:
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.parserResult, forKey: "parserResult")
        aCoder.encode(self.argument, forKey: "argument")
    }

    public var stencilContext: [String: Any] {
        return [
            "types": types,
            "functions": functions,
            "type": types.typesByName,
            "argument": argument
        ]
    }

    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "parserResult = \(String(describing: self.parserResult)), "
        string += "functions = \(String(describing: self.functions)), "
        string += "types = \(String(describing: self.types)), "
        string += "argument = \(String(describing: self.argument)), "
        string += "stencilContext = \(String(describing: self.stencilContext))"
        return string
    }

    public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? TemplateContext else {
            results.append("Incorrect type <expected: TemplateContext, received: \(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "parserResult").trackDifference(actual: self.parserResult, expected: castObject.parserResult))
        results.append(contentsOf: DiffableResult(identifier: "functions").trackDifference(actual: self.functions, expected: castObject.functions))
        results.append(contentsOf: DiffableResult(identifier: "types").trackDifference(actual: self.types, expected: castObject.types))
        results.append(contentsOf: DiffableResult(identifier: "argument").trackDifference(actual: self.argument, expected: castObject.argument))
        return results
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.parserResult)
        hasher.combine(self.functions)
        hasher.combine(self.types)
        hasher.combine(self.argument)
        return hasher.finalize()
    }

    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TemplateContext else { return false }
        if self.parserResult != rhs.parserResult { return false }
        if self.functions != rhs.functions { return false }
        if self.types != rhs.types { return false }
        if self.argument != rhs.argument { return false }
        return true
    }

    // sourcery: skipDescription, skipEquality
    public var jsContext: [String: Any] {
        return [
            "types": [
                "all": types.all,
                "protocols": types.protocols,
                "classes": types.classes,
                "structs": types.structs,
                "enums": types.enums,
                "extensions": types.extensions,
                "based": types.based,
                "inheriting": types.inheriting,
                "implementing": types.implementing
            ],
            "functions": functions,
            "type": types.typesByName,
            "argument": argument
        ]
    }

}

extension ProcessInfo {
    /// :nodoc:
    public var context: TemplateContext! {
        return NSKeyedUnarchiver.unarchiveObject(withFile: arguments[1]) as? TemplateContext
    }
}

// sourcery: skipJSExport
/// Collection of scanned types for accessing in templates
#if canImport(ObjectiveC)
@objcMembers
#endif
public final class Types: NSObject, SourceryModel, Diffable, DynamicMemberLookup {
    public subscript(dynamicMember member: String) -> Any? {
        switch member {
            case "types":
                return types
            case "enums":
                return enums
            case "all":
                return all
            case "protocols":
                return protocols
            case "classes":
                return classes
            case "structs":
                return structs
            case "extensions":
                return extensions
            case "implementing":
                return implementing
            default:
                fatalError("unable to lookup: \(member) in \(self)")
        }
    }

    /// :nodoc:
    public let types: [Type]

    /// All known typealiases
    public let typealiases: [Typealias]

    /// :nodoc:
    public init(types: [Type], typealiases: [Typealias] = []) {
        self.types = types
        self.typealiases = typealiases
    }

    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "types = \(String(describing: self.types)), "
        string += "typealiases = \(String(describing: self.typealiases))"
        return string
    }

    public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? Types else {
            results.append("Incorrect type <expected: Types, received: \(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "types").trackDifference(actual: self.types, expected: castObject.types))
        results.append(contentsOf: DiffableResult(identifier: "typealiases").trackDifference(actual: self.typealiases, expected: castObject.typealiases))
        return results
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.types)
        hasher.combine(self.typealiases)
        return hasher.finalize()
    }

    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Types else { return false }
        if self.types != rhs.types { return false }
        if self.typealiases != rhs.typealiases { return false }
        return true
    }

// sourcery:inline:Types.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let types: [Type] = aDecoder.decode(forKey: "types") else { 
                withVaList(["types"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.types = types
            guard let typealiases: [Typealias] = aDecoder.decode(forKey: "typealiases") else { 
                withVaList(["typealiases"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.typealiases = typealiases
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.types, forKey: "types")
            aCoder.encode(self.typealiases, forKey: "typealiases")
        }
// sourcery:end

    // sourcery: skipDescription, skipEquality, skipCoding
    /// :nodoc:
    public lazy internal(set) var typesByName: [String: Type] = {
        var typesByName = [String: Type]()
        self.types.forEach { typesByName[$0.globalName] = $0 }
        return typesByName
    }()

    // sourcery: skipDescription, skipEquality, skipCoding
    /// :nodoc:
    public lazy internal(set) var typesaliasesByName: [String: Typealias] = {
        var typesaliasesByName = [String: Typealias]()
        self.typealiases.forEach { typesaliasesByName[$0.name] = $0 }
        return typesaliasesByName
    }()

    // sourcery: skipDescription, skipEquality, skipCoding
    /// All known types, excluding protocols or protocol compositions.
    public lazy internal(set) var all: [Type] = {
        return self.types.filter { !($0 is Protocol || $0 is ProtocolComposition) }
    }()

    // sourcery: skipDescription, skipEquality, skipCoding
    /// All known protocols
    public lazy internal(set) var protocols: [Protocol] = {
        return self.types.compactMap { $0 as? Protocol }
    }()

    // sourcery: skipDescription, skipEquality, skipCoding
    /// All known protocol compositions
    public lazy internal(set) var protocolCompositions: [ProtocolComposition] = {
        return self.types.compactMap { $0 as? ProtocolComposition }
    }()

    // sourcery: skipDescription, skipEquality, skipCoding
    /// All known classes
    public lazy internal(set) var classes: [Class] = {
        return self.all.compactMap { $0 as? Class }
    }()

    // sourcery: skipDescription, skipEquality, skipCoding
    /// All known structs
    public lazy internal(set) var structs: [Struct] = {
        return self.all.compactMap { $0 as? Struct }
    }()

    // sourcery: skipDescription, skipEquality, skipCoding
    /// All known enums
    public lazy internal(set) var enums: [Enum] = {
        return self.all.compactMap { $0 as? Enum }
    }()

    // sourcery: skipDescription, skipEquality, skipCoding
    /// All known extensions
    public lazy internal(set) var extensions: [Type] = {
        return self.all.compactMap { $0.isExtension ? $0 : nil }
    }()

    // sourcery: skipDescription, skipEquality, skipCoding
    /// Types based on any other type, grouped by its name, even if they are not known.
    /// `types.based.MyType` returns list of types based on `MyType`
    public lazy internal(set) var based: TypesCollection = {
        TypesCollection(
            types: self.types,
            collection: { Array($0.based.keys) }
        )
    }()

    // sourcery: skipDescription, skipEquality, skipCoding
    /// Classes inheriting from any known class, grouped by its name.
    /// `types.inheriting.MyClass` returns list of types inheriting from `MyClass`
    public lazy internal(set) var inheriting: TypesCollection = {
        TypesCollection(
            types: self.types,
            collection: { Array($0.inherits.keys) },
            validate: { type in
                guard type is Class else {
                    throw "\(type.name) is not a class and should be used with `implementing` or `based`"
                }
            })
    }()

    // sourcery: skipDescription, skipEquality, skipCoding
    /// Types implementing known protocol, grouped by its name.
    /// `types.implementing.MyProtocol` returns list of types implementing `MyProtocol`
    public lazy internal(set) var implementing: TypesCollection = {
        TypesCollection(
            types: self.types,
            collection: { Array($0.implements.keys) },
            validate: { type in
                guard type is Protocol else {
                    throw "\(type.name) is a class and should be used with `inheriting` or `based`"
                }
        })
    }()
}

/// :nodoc:
#if canImport(ObjectiveC)
@objcMembers
#endif
public class TypesCollection: NSObject, AutoJSExport {

    // sourcery:begin: skipJSExport
    let all: [Type]
    let types: [String: [Type]]
    let validate: ((Type) throws -> Void)?
    // sourcery:end

    init(types: [Type], collection: (Type) -> [String], validate: ((Type) throws -> Void)? = nil) {
        self.all = types
        var content = [String: [Type]]()
        self.all.forEach { type in
            collection(type).forEach { name in
                var list = content[name] ?? [Type]()
                list.append(type)
                content[name] = list
            }
        }
        self.types = content
        self.validate = validate
    }

    public func types(forKey key: String) throws -> [Type] {
        // In some configurations, the types are keyed by "ModuleName.TypeName"
        var longKey: String?

        if let validate = validate {
            guard let type = all.first(where: { $0.name == key }) else {
                throw "Unknown type \(key), should be used with `based`"
            }

            try validate(type)

            if let module = type.module {
                longKey = [module, type.name].joined(separator: ".")
            }
        }

        // If we find the types directly, return them
        if let types = types[key] {
            return types
        }

        // if we find a types for the longKey, return them
        if let longKey = longKey, let types = types[longKey] {
            return types
        }

        return []
    }

    /// :nodoc:
#if canImport(ObjectiveC)
    override public func value(forKey key: String) -> Any? {
        do {
            return try types(forKey: key)
        } catch {
            Log.error(error)
            return nil
        }
    }
#else
public func value(forKey key: String) -> Any? {
        do {
            return try types(forKey: key)
        } catch {
            Log.error(error)
            return nil
        }
    }
#endif

    /// :nodoc:
    public subscript(_ key: String) -> [Type] {
        do {
            return try types(forKey: key)
        } catch {
            Log.error(error)
            return []
        }
    }

#if canImport(ObjectiveC)
    override public func responds(to aSelector: Selector!) -> Bool {
        return true
    }
#endif
}
