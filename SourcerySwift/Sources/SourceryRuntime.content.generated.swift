let sourceryRuntimeFiles: [FolderSynchronizer.File] = [
    .init(name: "AccessLevel.swift", content:
"""
//
// Created by Krzysztof Zablocki on 13/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

/// :nodoc:
public enum AccessLevel: String {
    case `internal` = "internal"
    case `private` = "private"
    case `fileprivate` = "fileprivate"
    case `public` = "public"
    case `open` = "open"
    case none = ""
}

"""),
    .init(name: "Annotations.swift", content:
"""
import Foundation

public typealias Annotations = [String: NSObject]

/// Describes annotated declaration, i.e. type, method, variable, enum case
public protocol Annotated {
    /**
     All annotations of declaration stored by their name. Value can be `bool`, `String`, float `NSNumber`
     or array of those types if you use several annotations with the same name.
    
     **Example:**
     
     ```
     //sourcery: booleanAnnotation
     //sourcery: stringAnnotation = "value"
     //sourcery: numericAnnotation = 0.5
     
     [
      "booleanAnnotation": true,
      "stringAnnotation": "value",
      "numericAnnotation": 0.5
     ]
     ```
    */
    var annotations: Annotations { get }
}

"""),
    .init(name: "Array+Parallel.swift", content:
"""
//
// Created by Krzysztof Zablocki on 06/01/2017.
// Copyright (c) 2017 Pixle. All rights reserved.
//

import Foundation

public extension Array {
    func parallelFlatMap<T>(transform: (Element) -> [T]) -> [T] {
        return parallelMap(transform: transform).flatMap { $0 }
    }

    func parallelCompactMap<T>(transform: (Element) -> T?) -> [T] {
        return parallelMap(transform: transform).compactMap { $0 }
    }

    func parallelMap<T>(transform: (Element) -> T) -> [T] {
        var result = ContiguousArray<T?>(repeating: nil, count: count)
        return result.withUnsafeMutableBufferPointer { buffer in
            DispatchQueue.concurrentPerform(iterations: buffer.count) { idx in
                buffer[idx] = transform(self[idx])
            }
            return buffer.map { $0! }
        }
    }

    func parallelPerform(transform: (Element) -> Void) {
        DispatchQueue.concurrentPerform(iterations: count) { idx in
            transform(self[idx])
        }
    }
}

"""),
    .init(name: "Array.swift", content:
"""
import Foundation

/// Describes array type
@objcMembers public final class ArrayType: NSObject, SourceryModel {

    /// Type name used in declaration
    public var name: String

    /// Array element type name
    public var elementTypeName: TypeName

    // sourcery: skipEquality, skipDescription
    /// Array element type, if known
    public var elementType: Type?

    /// :nodoc:
    public init(name: String, elementTypeName: TypeName, elementType: Type? = nil) {
        self.name = name
        self.elementTypeName = elementTypeName
        self.elementType = elementType
    }

    /// Returns array as generic type
    public var asGeneric: GenericType {
        GenericType(name: "Array", typeParameters: [
            .init(typeName: elementTypeName)
        ])
    }

    public var asSource: String {
        "[\\(elementTypeName.asSource)]"
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

"""),
    .init(name: "AssociatedType.swift", content:
"""
import Foundation

/// Describes Swift AssociatedType
@objcMembers public final class AssociatedType: NSObject, SourceryModel {
    /// Associated type name
    public let name: String

    /// Associated type type constraint name, if specified
    public let typeName: TypeName?

    // sourcery: skipEquality, skipDescription
    /// Associated type constrained type, if known, i.e. if the type is declared in the scanned sources.
    public var type: Type?

    /// :nodoc:
    public init(name: String, typeName: TypeName? = nil, type: Type? = nil) {
        self.name = name
        self.typeName = typeName
        self.type = type
    }

// sourcery:inline:AssociatedType.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            self.typeName = aDecoder.decode(forKey: "typeName")
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

"""),
    .init(name: "Attribute.swift", content:
"""
import Foundation

/// Describes Swift attribute
@objcMembers public class Attribute: NSObject, AutoCoding, AutoEquatable, AutoDiffable, AutoJSExport {

    /// Attribute name
    public let name: String

    /// Attribute arguments
    public let arguments: [String: NSObject]

    // sourcery: skipJSExport
    let _description: String

    // sourcery: skipEquality, skipDescription, skipCoding, skipJSExport
    /// :nodoc:
    public var __parserData: Any?

    /// :nodoc:
    public init(name: String, arguments: [String: NSObject] = [:], description: String? = nil) {
        self.name = name
        self.arguments = arguments
        self._description = description ?? "@\\(name)"
    }

    /// TODO: unify `asSource` / `description`?
    public var asSource: String {
        description
    }

    /// Attribute description that can be used in a template.
    public override var description: String {
        return _description
    }

    /// :nodoc:
    public enum Identifier: String {
        case convenience
        case required
        case available
        case discardableResult
        case GKInspectable = "gkinspectable"
        case objc
        case objcMembers
        case nonobjc
        case NSApplicationMain
        case NSCopying
        case NSManaged
        case UIApplicationMain
        case IBOutlet = "iboutlet"
        case IBInspectable = "ibinspectable"
        case IBDesignable = "ibdesignable"
        case autoclosure
        case convention
        case mutating
        case escaping
        case final
        case open
        case lazy
        case `public` = "public"
        case `internal` = "internal"
        case `private` = "private"
        case `fileprivate` = "fileprivate"
        case publicSetter = "setter_access.public"
        case internalSetter = "setter_access.internal"
        case privateSetter = "setter_access.private"
        case fileprivateSetter = "setter_access.fileprivate"
        case optional

        public init?(identifier: String) {
            let identifier = identifier.trimmingPrefix("source.decl.attribute.")
            if identifier == "objc.name" {
                self.init(rawValue: "objc")
            } else {
                self.init(rawValue: identifier)
            }
        }

        public static func from(string: String) -> Identifier? {
            switch string {
            case "GKInspectable":
                return Identifier.GKInspectable
            case "objc":
                return .objc
            case "IBOutlet":
                return .IBOutlet
            case "IBInspectable":
                return .IBInspectable
            case "IBDesignable":
                return .IBDesignable
            default:
                return Identifier(rawValue: string)
            }
        }

        public var name: String {
            switch self {
            case .GKInspectable:
                return "GKInspectable"
            case .objc:
                return "objc"
            case .IBOutlet:
                return "IBOutlet"
            case .IBInspectable:
                return "IBInspectable"
            case .IBDesignable:
                return "IBDesignable"
            case .fileprivateSetter:
                return "fileprivate"
            case .privateSetter:
                return "private"
            case .internalSetter:
                return "internal"
            case .publicSetter:
                return "public"
            default:
                return rawValue
            }
        }

        public var description: String {
            return hasAtPrefix ? "@\\(name)" : name
        }

        public var hasAtPrefix: Bool {
            switch self {
            case .available,
                 .discardableResult,
                 .GKInspectable,
                 .objc,
                 .objcMembers,
                 .nonobjc,
                 .NSApplicationMain,
                 .NSCopying,
                 .NSManaged,
                 .UIApplicationMain,
                 .IBOutlet,
                 .IBInspectable,
                 .IBDesignable,
                 .autoclosure,
                 .convention,
                 .escaping:
                return true
            default:
                return false
            }
        }
    }

// sourcery:inline:Attribute.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let arguments: [String: NSObject] = aDecoder.decode(forKey: "arguments") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["arguments"])); fatalError() }; self.arguments = arguments
            guard let _description: String = aDecoder.decode(forKey: "_description") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["_description"])); fatalError() }; self._description = _description
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.arguments, forKey: "arguments")
            aCoder.encode(self._description, forKey: "_description")
        }
// sourcery:end

}

"""),
    .init(name: "AutoHashable.generated.swift", content:
"""
// Generated using Sourcery 1.3.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all


// MARK: - AutoHashable for classes, protocols, structs

// MARK: - AutoHashable for Enums

"""),
    .init(name: "BytesRange.swift", content:
"""
//
//  Created by Sébastien Duperron on 03/01/2018.
//  Copyright © 2018 Pixle. All rights reserved.
//

import Foundation

/// :nodoc:
@objcMembers public final class BytesRange: NSObject, SourceryModel {

    public let offset: Int64
    public let length: Int64

    public init(offset: Int64, length: Int64) {
        self.offset = offset
        self.length = length
    }

    public convenience init(range: (offset: Int64, length: Int64)) {
        self.init(offset: range.offset, length: range.length)
    }

// sourcery:inline:BytesRange.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            self.offset = aDecoder.decodeInt64(forKey: "offset")
            self.length = aDecoder.decodeInt64(forKey: "length")
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.offset, forKey: "offset")
            aCoder.encode(self.length, forKey: "length")
        }
// sourcery:end
}

"""),
    .init(name: "Class.swift", content:
"""
import Foundation

// sourcery: skipDescription
/// Descibes Swift class
@objc(SwiftClass) @objcMembers public final class Class: Type {
    /// Returns "class"
    public override var kind: String { return "class" }

    /// Whether type is final 
    public var isFinal: Bool {
        return modifiers.contains { $0.name == "final" }
    }

    /// :nodoc:
    public override init(name: String = "",
                         parent: Type? = nil,
                         accessLevel: AccessLevel = .internal,
                         isExtension: Bool = false,
                         variables: [Variable] = [],
                         methods: [Method] = [],
                         subscripts: [Subscript] = [],
                         inheritedTypes: [String] = [],
                         containedTypes: [Type] = [],
                         typealiases: [Typealias] = [],
                         attributes: AttributeList = [:],
                         modifiers: [SourceryModifier] = [],
                         annotations: [String: NSObject] = [:],
                         documentation: [String] = [],
                         isGeneric: Bool = false) {
        super.init(
            name: name,
            parent: parent,
            accessLevel: accessLevel,
            isExtension: isExtension,
            variables: variables,
            methods: methods,
            subscripts: subscripts,
            inheritedTypes: inheritedTypes,
            containedTypes: containedTypes,
            typealiases: typealiases,
            attributes: attributes,
            modifiers: modifiers,
            annotations: annotations,
            documentation: documentation,
            isGeneric: isGeneric
        )
    }

// sourcery:inline:Class.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }

        /// :nodoc:
        override public func encode(with aCoder: NSCoder) {
            super.encode(with: aCoder)
        }
// sourcery:end
}

"""),
    .init(name: "Closure.swift", content:
"""
import Foundation

/// Describes closure type
@objcMembers public final class ClosureType: NSObject, SourceryModel {

    /// Type name used in declaration with stripped whitespaces and new lines
    public let name: String

    /// List of closure parameters
    public let parameters: [ClosureParameter]

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
    
    /// Whether method is async method
    public let isAsync: Bool

    /// async keyword
    public let asyncKeyword: String?

    /// Whether closure throws
    public let `throws`: Bool

    /// throws or rethrows keyword
    public let throwsOrRethrowsKeyword: String?

    /// :nodoc:
    public init(name: String, parameters: [ClosureParameter], returnTypeName: TypeName, returnType: Type? = nil, asyncKeyword: String? = nil, throwsOrRethrowsKeyword: String? = nil) {
        self.name = name
        self.parameters = parameters
        self.returnTypeName = returnTypeName
        self.returnType = returnType
        self.asyncKeyword = asyncKeyword
        self.isAsync = asyncKeyword != nil
        self.throwsOrRethrowsKeyword = throwsOrRethrowsKeyword
        self.`throws` = throwsOrRethrowsKeyword != nil
    }

    public var asSource: String {
        "\\(parameters.asSource)\\(asyncKeyword != nil ? " \\(asyncKeyword!)" : "")\\(throwsOrRethrowsKeyword != nil ? " \\(throwsOrRethrowsKeyword!)" : "") -> \\(returnTypeName.asSource)"
    }

// sourcery:inline:ClosureType.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let parameters: [ClosureParameter] = aDecoder.decode(forKey: "parameters") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["parameters"])); fatalError() }; self.parameters = parameters
            guard let returnTypeName: TypeName = aDecoder.decode(forKey: "returnTypeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["returnTypeName"])); fatalError() }; self.returnTypeName = returnTypeName
            self.returnType = aDecoder.decode(forKey: "returnType")
            self.isAsync = aDecoder.decode(forKey: "isAsync")
            self.asyncKeyword = aDecoder.decode(forKey: "asyncKeyword")
            self.`throws` = aDecoder.decode(forKey: "`throws`")
            self.throwsOrRethrowsKeyword = aDecoder.decode(forKey: "throwsOrRethrowsKeyword")
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.parameters, forKey: "parameters")
            aCoder.encode(self.returnTypeName, forKey: "returnTypeName")
            aCoder.encode(self.returnType, forKey: "returnType")
            aCoder.encode(self.isAsync, forKey: "isAsync")
            aCoder.encode(self.asyncKeyword, forKey: "asyncKeyword")
            aCoder.encode(self.`throws`, forKey: "`throws`")
            aCoder.encode(self.throwsOrRethrowsKeyword, forKey: "throwsOrRethrowsKeyword")
        }
// sourcery:end

}

"""),
    .init(name: "Coding.generated.swift", content:
"""
// Generated using Sourcery 1.8.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable vertical_whitespace trailing_newline

import Foundation


extension NSCoder {

    @nonobjc func decode(forKey: String) -> String? {
        return self.maybeDecode(forKey: forKey) as String?
    }

    @nonobjc func decode(forKey: String) -> TypeName? {
        return self.maybeDecode(forKey: forKey) as TypeName?
    }

    @nonobjc func decode(forKey: String) -> AccessLevel? {
        return self.maybeDecode(forKey: forKey) as AccessLevel?
    }

    @nonobjc func decode(forKey: String) -> Bool {
        return self.decodeBool(forKey: forKey)
    }

    @nonobjc func decode(forKey: String) -> Int {
        return self.decodeInteger(forKey: forKey)
    }

    func decode<E>(forKey: String) -> E? {
        return maybeDecode(forKey: forKey) as E?
    }

    fileprivate func maybeDecode<E>(forKey: String) -> E? {
        guard let object = self.decodeObject(forKey: forKey) else {
            return nil
        }

        return object as? E
    }

}

extension ArrayType: NSCoding {}

extension AssociatedType: NSCoding {}

extension AssociatedValue: NSCoding {}

extension Attribute: NSCoding {}

extension BytesRange: NSCoding {}


extension ClosureParameter: NSCoding {}

extension ClosureType: NSCoding {}

extension DictionaryType: NSCoding {}


extension EnumCase: NSCoding {}

extension FileParserResult: NSCoding {}

extension GenericRequirement: NSCoding {}

extension GenericType: NSCoding {}

extension GenericTypeParameter: NSCoding {}

extension Import: NSCoding {}

extension Method: NSCoding {}

extension MethodParameter: NSCoding {}

extension Modifier: NSCoding {}




extension Subscript: NSCoding {}

extension TupleElement: NSCoding {}

extension TupleType: NSCoding {}

extension Type: NSCoding {}

extension TypeName: NSCoding {}

extension Typealias: NSCoding {}

extension Types: NSCoding {}

extension Variable: NSCoding {}


"""),
    .init(name: "Composer.swift", content:
"""
//
// Created by Krzysztof Zablocki on 31/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

private func currentTimestamp() -> TimeInterval {
    return CFAbsoluteTimeGetCurrent()
}

/// Responsible for composing results of `FileParser`.
public enum Composer {
    internal final class State {
        private(set) var typeMap = [String: Type]()
        private(set) var modules = [String: [String: Type]]()
        let parsedTypes: [Type]
        let functions: [SourceryMethod]
        let resolvedTypealiases: [String: Typealias]
        let unresolvedTypealiases: [String: Typealias]

        init(parserResult: FileParserResult) {
            // TODO: This logic should really be more complicated
            // For any resolution we need to be looking at accessLevel and module boundaries
            // e.g. there might be a typealias `private typealias Something = MyType` in one module and same name in another with public modifier, one could be accessed and the other could not
            self.functions = parserResult.functions
            let aliases = Self.typealiases(parserResult)
            resolvedTypealiases = aliases.resolved
            unresolvedTypealiases = aliases.unresolved
            parsedTypes = parserResult.types

            // set definedInType for all methods and variables
            parsedTypes
              .forEach { type in
                type.variables.forEach { $0.definedInType = type }
                type.methods.forEach { $0.definedInType = type }
                type.subscripts.forEach { $0.definedInType = type }
            }

            // map all known types to their names
            parsedTypes
              .filter { $0.isExtension == false }
              .forEach {
                  typeMap[$0.globalName] = $0
                  if let module = $0.module {
                      var typesByModules = modules[module, default: [:]]
                      typesByModules[$0.name] = $0
                      modules[module] = typesByModules
                  }
              }
        }

        func unifyTypes() -> [Type] {
            /// Resolve actual names of extensions, as they could have been done on typealias and note updated child names in uniques if needed
            parsedTypes
              .filter { $0.isExtension == true }
              .forEach {
                  let oldName = $0.globalName

                  if let resolved = resolveGlobalName(for: oldName, containingType: $0.parent, unique: typeMap, modules: modules, typealiases: resolvedTypealiases)?.name {
                      $0.localName = resolved.replacingOccurrences(of: "\\($0.module != nil ? "\\($0.module!)." : "")", with: "")
                  } else {
                      return
                  }

                  // nothing left to do
                  guard oldName != $0.globalName else {
                      return
                  }

                  // if it had contained types, they might have been fully defined and so their name has to be noted in uniques
                  func rewriteChildren(of type: Type) {
                      // child is never an extension so no need to check
                      for child in type.containedTypes {
                          typeMap[child.globalName] = child
                          rewriteChildren(of: child)
                      }
                  }
                  rewriteChildren(of: $0)
              }

            // extend all types with their extensions
            parsedTypes.forEach { type in
                type.inheritedTypes = type.inheritedTypes.map { inheritedName in
                    resolveGlobalName(for: inheritedName, containingType: type.parent, unique: typeMap, modules: modules, typealiases: resolvedTypealiases)?.name ?? inheritedName
                }

                let uniqueType = typeMap[type.globalName] ?? // this check will only fail on an extension?
                  typeFromComposedName(type.name, modules: modules) ?? // this can happen for an extension on unknown type, this case should probably be handled by the inferTypeNameFromModules
                  (inferTypeNameFromModules(from: type.localName, containedInType: type.parent, uniqueTypes: typeMap, modules: modules).flatMap { typeMap[$0] })

                guard let current = uniqueType else {
                    assert(type.isExtension)

                    // for unknown types we still store their extensions but mark them as unknown
                    type.isUnknownExtension = true
                    if let existingType = typeMap[type.globalName] {
                        existingType.extend(type)
                        typeMap[type.globalName] = existingType
                    } else {
                        typeMap[type.globalName] = type
                    }

                    let inheritanceClause = type.inheritedTypes.isEmpty ? "" :
                      ": \\(type.inheritedTypes.joined(separator: ", "))"

                    Log.astWarning("Found \\"extension \\(type.name)\\(inheritanceClause)\\" of type for which there is no original type declaration information.")
                    return
                }

                if current == type { return }

                current.extend(type)
                typeMap[current.globalName] = current
            }

            let values = typeMap.values
            var processed = Set<String>(minimumCapacity: values.count)
            return typeMap.values.filter({
                let name = $0.globalName
                let wasProcessed = processed.contains(name)
                processed.insert(name)
                return !wasProcessed
            })
        }

        /// returns typealiases map to their full names, with `resolved` removing intermediate
        /// typealises and `unresolved` including typealiases that reference other typealiases.
        private static func typealiases(_ parserResult: FileParserResult) -> (resolved: [String: Typealias], unresolved: [String: Typealias]) {
            var typealiasesByNames = [String: Typealias]()
            parserResult.typealiases.forEach { typealiasesByNames[$0.name] = $0 }
            parserResult.types.forEach { type in
                type.typealiases.forEach({ (_, alias) in
                    // TODO: should I deal with the fact that alias.name depends on type name but typenames might be updated later on
                    // maybe just handle non extension case here and extension aliases after resolving them?
                    typealiasesByNames[alias.name] = alias
                })
            }

            let unresolved = typealiasesByNames

            // ! if a typealias leads to another typealias, follow through and replace with final type
            typealiasesByNames.forEach { _, alias in
                var aliasNamesToReplace = [alias.name]
                var finalAlias = alias
                while let targetAlias = typealiasesByNames[finalAlias.typeName.name] {
                    aliasNamesToReplace.append(targetAlias.name)
                    finalAlias = targetAlias
                }

                // ! replace all keys
                aliasNamesToReplace.forEach { typealiasesByNames[$0] = finalAlias }
            }

            return (resolved: typealiasesByNames, unresolved: unresolved)
        }

        /// Resolves type identifier for name
        func resolveGlobalName(for type: String,
                                              containingType: Type? = nil,
                                              unique: [String: Type]? = nil,
                                              modules: [String: [String: Type]],
                                              typealiases: [String: Typealias]) -> (name: String, typealias: Typealias?)? {
            // if the type exists for this name and isn't an extension just return it's name
            // if it's extension we need to check if there aren't other options TODO: verify
            if let realType = unique?[type], realType.isExtension == false {
                return (name: realType.globalName, typealias: nil)
            }

            if let alias = typealiases[type] {
                return (name: alias.type?.globalName ?? alias.typeName.name, typealias: alias)
            }

            if let containingType = containingType {
                if type == "Self" {
                    return (name: containingType.globalName, typealias: nil)
                }

                var currentContainer: Type? = containingType
                while currentContainer != nil, let parentName = currentContainer?.globalName {
                    /// TODO: no parent for sure?
                    /// manually walk the containment tree
                    if let name = resolveGlobalName(for: "\\(parentName).\\(type)", containingType: nil, unique: unique, modules: modules, typealiases: typealiases) {
                        return name
                    }

                    currentContainer = currentContainer?.parent
                }

//            if let name = resolveGlobalName(for: "\\(containingType.globalName).\\(type)", containingType: containingType.parent, unique: unique, modules: modules, typealiases: typealiases) {
//                return name
//            }

//             last check it's via module
//            if let module = containingType.module, let name = resolveGlobalName(for: "\\(module).\\(type)", containingType: nil, unique: unique, modules: modules, typealiases: typealiases) {
//                return name
//            }
            }

            // TODO: is this needed?
            if let inferred = inferTypeNameFromModules(from: type, containedInType: containingType, uniqueTypes: unique ?? [:], modules: modules) {
                return (name: inferred, typealias: nil)
            }

            return typeFromComposedName(type, modules: modules).map { (name: $0.globalName, typealias: nil) }
        }

        private func inferTypeNameFromModules(from typeIdentifier: String, containedInType: Type?, uniqueTypes: [String: Type], modules: [String: [String: Type]]) -> String? {
            func fullName(for module: String) -> String {
                "\\(module).\\(typeIdentifier)"
            }

            func type(for module: String) -> Type? {
                return modules[module]?[typeIdentifier]
            }

            func ambiguousErrorMessage(from types: [Type]) -> String? {
                Log.astWarning("Ambiguous type \\(typeIdentifier), found \\(types.map { $0.globalName }.joined(separator: ", ")). Specify module name at declaration site to disambiguate.")
                return nil
            }

            let explicitModulesAtDeclarationSite: [String] = [
                containedInType?.module.map { [$0] } ?? [],    // main module for this typename
                containedInType?.imports.map { $0.moduleName } ?? []    // imported modules
            ]
              .flatMap { $0 }

            let remainingModules = Set(modules.keys).subtracting(explicitModulesAtDeclarationSite)

            /// We need to check whether we can find type in one of the modules but we need to be careful to avoid amibiguity
            /// First checking explicit modules available at declaration site (so source module + all imported ones)
            /// If there is no ambigiuity there we can assume that module will be resolved by the compiler
            /// If that's not the case we look after remaining modules in the application and if the typename has no ambigiuity we use that
            /// But if there is more than 1 typename duplication across modules we have no way to resolve what is the compiler going to use so we fail
            let moduleSetsToCheck: [[String]] = [
                explicitModulesAtDeclarationSite,
                Array(remainingModules)
            ]

            for modules in moduleSetsToCheck {
                let possibleTypes = modules
                  .compactMap { type(for: $0) }

                if possibleTypes.count > 1 {
                    return ambiguousErrorMessage(from: possibleTypes)
                }

                if let type = possibleTypes.first {
                    return type.globalName
                }
            }

            // as last result for unknown types / extensions
            // try extracting type from unique array
            if let module = containedInType?.module {
                return uniqueTypes[fullName(for: module)]?.globalName
            }
            return nil
        }

        func typeFromComposedName(_ name: String, modules: [String: [String: Type]]) -> Type? {
            guard name.contains(".") else { return nil }
            let nameComponents = name.components(separatedBy: ".")
            let moduleName = nameComponents[0]
            let typeName = nameComponents.suffix(from: 1).joined(separator: ".")
            return modules[moduleName]?[typeName]
        }
    }

    /// Performs final processing of discovered types:
    /// - extends types with their corresponding extensions;
    /// - replaces typealiases with actual types
    /// - finds actual types for variables and enums raw values
    /// - filters out any private types and extensions
    ///
    /// - Parameter parserResult: Result of parsing source code.
    /// - Returns: Final types and extensions of unknown types.
    public static func uniqueTypesAndFunctions(_ parserResult: FileParserResult) -> (types: [Type], functions: [SourceryMethod], typealiases: [Typealias]) {
        let state = State(parserResult: parserResult)

        let resolveType = { (typeName: TypeName, containingType: Type?) -> Type? in
            return self.resolveType(typeName: typeName, containingType: containingType, state: state)
        }

        /// Resolve typealiases
        let typealiases = Array(state.unresolvedTypealiases.values)
        typealiases.forEach { alias in
            alias.type = resolveType(alias.typeName, alias.parent)
        }

        let types = state.unifyTypes()

        let resolutionStart = currentTimestamp()

        types.parallelPerform { type in
            type.variables.forEach {
                resolveVariableTypes($0, of: type, resolve: resolveType)
            }
            type.methods.forEach {
                resolveMethodTypes($0, of: type, resolve: resolveType)
            }
            type.subscripts.forEach {
                resolveSubscriptTypes($0, of: type, resolve: resolveType)
            }

            if let enumeration = type as? Enum {
                resolveEnumTypes(enumeration, types: state.typeMap, resolve: resolveType)
            }

            if let composition = type as? ProtocolComposition {
                resolveProtocolCompositionTypes(composition, resolve: resolveType)
            }

            if let sourceryProtocol = type as? SourceryProtocol {
                resolveProtocolTypes(sourceryProtocol, resolve: resolveType)
            }
        }

        state.functions.parallelPerform { function in
            resolveMethodTypes(function, of: nil, resolve: resolveType)
        }

        Log.benchmark("resolution took \\(currentTimestamp() - resolutionStart)")

        updateTypeRelationships(types: types)

        return (
            types: types.sorted { $0.globalName < $1.globalName },
            functions: state.functions.sorted { $0.name < $1.name },
            typealiases: typealiases.sorted(by: { $0.name < $1.name })
        )
    }

    private static func resolveType(typeName: TypeName, containingType: Type?, state: State) -> Type? {
        let resolveTypeWithName = { (typeName: TypeName) -> Type? in
            return self.resolveType(typeName: typeName, containingType: containingType, state: state)
        }

        let unique = state.typeMap
        let modules = state.modules
        let typealiases = state.resolvedTypealiases

        if let name = typeName.actualTypeName {
            let resolvedIdentifier = name.generic?.name ?? name.unwrappedTypeName
            return unique[resolvedIdentifier]
        }

        let retrievedName = self.actualTypeName(for: typeName, containingType: containingType, state: state)
        let lookupName = retrievedName ?? typeName

        if let tuple = lookupName.tuple {
            var needsUpdate = false

            tuple.elements.forEach { tupleElement in
                tupleElement.type = resolveTypeWithName(tupleElement.typeName)
                if tupleElement.typeName.actualTypeName != nil {
                    needsUpdate = true
                }
            }

            if needsUpdate || retrievedName != nil {
                let tupleCopy = TupleType(name: tuple.name, elements: tuple.elements)
                tupleCopy.elements.forEach {
                    $0.typeName = $0.actualTypeName ?? $0.typeName
                    $0.typeName.actualTypeName = nil
                }
                tupleCopy.name = tupleCopy.elements.asTypeName

                typeName.tuple = tupleCopy // TODO: really don't like this old behaviour
                typeName.actualTypeName = TypeName(name: tupleCopy.name,
                                                   isOptional: typeName.isOptional,
                                                   isImplicitlyUnwrappedOptional: typeName.isImplicitlyUnwrappedOptional,
                                                   tuple: tupleCopy,
                                                   array: lookupName.array,
                                                   dictionary: lookupName.dictionary,
                                                   closure: lookupName.closure,
                                                   generic: lookupName.generic
                )
            }
            return nil
        } else
        if let array = lookupName.array {
            array.elementType = resolveTypeWithName(array.elementTypeName)

            if array.elementTypeName.actualTypeName != nil || retrievedName != nil {
                let array = ArrayType(name: array.name, elementTypeName: array.elementTypeName, elementType: array.elementType)
                array.elementTypeName = array.elementTypeName.actualTypeName ?? array.elementTypeName
                array.elementTypeName.actualTypeName = nil
                array.name = array.asSource
                typeName.array = array // TODO: really don't like this old behaviour
                typeName.generic = array.asGeneric // TODO: really don't like this old behaviour

                typeName.actualTypeName = TypeName(name: array.name,
                                                   isOptional: typeName.isOptional,
                                                   isImplicitlyUnwrappedOptional: typeName.isImplicitlyUnwrappedOptional,
                                                   tuple: lookupName.tuple,
                                                   array: array,
                                                   dictionary: lookupName.dictionary,
                                                   closure: lookupName.closure,
                                                   generic: typeName.generic
                )
            }
        } else
        if let dictionary = lookupName.dictionary {
            dictionary.keyType = resolveTypeWithName(dictionary.keyTypeName)
            dictionary.valueType = resolveTypeWithName(dictionary.valueTypeName)

            if dictionary.keyTypeName.actualTypeName != nil || dictionary.valueTypeName.actualTypeName != nil || retrievedName != nil {
                let dictionary = DictionaryType(name: dictionary.name, valueTypeName: dictionary.valueTypeName, valueType: dictionary.valueType, keyTypeName: dictionary.keyTypeName, keyType: dictionary.keyType)
                dictionary.keyTypeName = dictionary.keyTypeName.actualTypeName ?? dictionary.keyTypeName
                dictionary.keyTypeName.actualTypeName = nil // TODO: really don't like this old behaviour
                dictionary.valueTypeName = dictionary.valueTypeName.actualTypeName ?? dictionary.valueTypeName
                dictionary.valueTypeName.actualTypeName = nil // TODO: really don't like this old behaviour

                dictionary.name = dictionary.asSource

                typeName.dictionary = dictionary // TODO: really don't like this old behaviour
                typeName.generic = dictionary.asGeneric // TODO: really don't like this old behaviour

                typeName.actualTypeName = TypeName(name: dictionary.asSource,
                                                   isOptional: typeName.isOptional,
                                                   isImplicitlyUnwrappedOptional: typeName.isImplicitlyUnwrappedOptional,
                                                   tuple: lookupName.tuple,
                                                   array: lookupName.array,
                                                   dictionary: dictionary,
                                                   closure: lookupName.closure,
                                                   generic: dictionary.asGeneric
                )
            }
        } else
        if let closure = lookupName.closure {
            var needsUpdate = false

            closure.returnType = resolveTypeWithName(closure.returnTypeName)
            closure.parameters.forEach { parameter in
                parameter.type = resolveTypeWithName(parameter.typeName)
                if parameter.typeName.actualTypeName != nil {
                    needsUpdate = true
                }
            }

            if closure.returnTypeName.actualTypeName != nil || needsUpdate || retrievedName != nil {
                typeName.closure = closure // TODO: really don't like this old behaviour

                typeName.actualTypeName = TypeName(name: closure.asSource,
                                                   isOptional: typeName.isOptional,
                                                   isImplicitlyUnwrappedOptional: typeName.isImplicitlyUnwrappedOptional,
                                                   tuple: lookupName.tuple,
                                                   array: lookupName.array,
                                                   dictionary: lookupName.dictionary,
                                                   closure: closure,
                                                   generic: lookupName.generic
                )
            }

            return nil
        } else
        if let generic = lookupName.generic {
            var needsUpdate = false

            generic.typeParameters.forEach { parameter in
                parameter.type = resolveTypeWithName(parameter.typeName)
                if parameter.typeName.actualTypeName != nil {
                    needsUpdate = true
                }
            }

            if needsUpdate || retrievedName != nil {
                let generic = GenericType(name: generic.name, typeParameters: generic.typeParameters)
                generic.typeParameters.forEach {
                    $0.typeName = $0.typeName.actualTypeName ?? $0.typeName
                    $0.typeName.actualTypeName = nil // TODO: really don't like this old behaviour
                }
                typeName.generic = generic // TODO: really don't like this old behaviour
                typeName.array = lookupName.array // TODO: really don't like this old behaviour
                typeName.dictionary = lookupName.dictionary // TODO: really don't like this old behaviour

                let params = generic.typeParameters.map { $0.typeName.asSource }.joined(separator: ", ")

                typeName.actualTypeName = TypeName(name: "\\(generic.name)<\\(params)>",
                                                   isOptional: typeName.isOptional,
                                                   isImplicitlyUnwrappedOptional: typeName.isImplicitlyUnwrappedOptional,
                                                   tuple: lookupName.tuple,
                                                   array: lookupName.array, // TODO: asArray
                                                   dictionary: lookupName.dictionary, // TODO: asDictionary
                                                   closure: lookupName.closure,
                                                   generic: generic
                )
            }
        }

        if let aliasedName = (typeName.actualTypeName ?? retrievedName), aliasedName.unwrappedTypeName != typeName.unwrappedTypeName {
            typeName.actualTypeName = aliasedName
        }

        let finalLookup = typeName.actualTypeName ?? typeName
        let resolvedIdentifier = finalLookup.generic?.name ?? finalLookup.unwrappedTypeName

        // should we cache resolved typenames?
        return unique[resolvedIdentifier]
    }

    typealias TypeResolver = (TypeName, Type?) -> Type?

    private static func resolveVariableTypes(_ variable: Variable, of type: Type, resolve: TypeResolver) {
        variable.type = resolve(variable.typeName, type)

        /// The actual `definedInType` is assigned in `uniqueTypes` but we still
        /// need to resolve the type to correctly parse typealiases
        /// @see https://github.com/krzysztofzablocki/Sourcery/pull/374
        if let definedInTypeName = variable.definedInTypeName {
            _ = resolve(definedInTypeName, type)
        }
    }

    private static func resolveSubscriptTypes(_ subscript: Subscript, of type: Type, resolve: TypeResolver) {
        `subscript`.parameters.forEach { (parameter) in
            parameter.type = resolve(parameter.typeName, type)
        }

        `subscript`.returnType = resolve(`subscript`.returnTypeName, type)
        if let definedInTypeName = `subscript`.definedInTypeName {
            _ = resolve(definedInTypeName, type)
        }
    }

    private static func resolveMethodTypes(_ method: SourceryMethod, of type: Type?, resolve: TypeResolver) {
        method.parameters.forEach { parameter in
            parameter.type = resolve(parameter.typeName, type)
        }

        /// The actual `definedInType` is assigned in `uniqueTypes` but we still
        /// need to resolve the type to correctly parse typealiases
        /// @see https://github.com/krzysztofzablocki/Sourcery/pull/374
        var definedInType: Type?
        if let definedInTypeName = method.definedInTypeName {
            definedInType = resolve(definedInTypeName, type)
        }

        guard !method.returnTypeName.isVoid else { return }

        if method.isInitializer || method.isFailableInitializer {
            method.returnType = definedInType
            if let type = method.actualDefinedInTypeName {
                if method.isFailableInitializer {
                    method.returnTypeName = TypeName(
                        name: type.name,
                        isOptional: true,
                        isImplicitlyUnwrappedOptional: false,
                        tuple: type.tuple,
                        array: type.array,
                        dictionary: type.dictionary,
                        closure: type.closure,
                        generic: type.generic,
                        isProtocolComposition: type.isProtocolComposition
                    )
                } else if method.isInitializer {
                    method.returnTypeName = type
                }
            }
        } else {
            method.returnType = resolve(method.returnTypeName, type)
        }
    }

    private static func resolveEnumTypes(_ enumeration: Enum, types: [String: Type], resolve: TypeResolver) {
        enumeration.cases.forEach { enumCase in
            enumCase.associatedValues.forEach { associatedValue in
                associatedValue.type = resolve(associatedValue.typeName, enumeration)
            }
        }

        guard enumeration.hasRawType else { return }

        if let rawValueVariable = enumeration.variables.first(where: { $0.name == "rawValue" && !$0.isStatic }) {
            enumeration.rawTypeName = rawValueVariable.actualTypeName
            enumeration.rawType = rawValueVariable.type
        } else if let rawTypeName = enumeration.inheritedTypes.first {
            // enums with no cases or enums with cases that contain associated values can't have raw type
            guard !enumeration.cases.isEmpty,
                  !enumeration.hasAssociatedValues else {
                return enumeration.rawTypeName = nil
            }

            if let rawTypeCandidate = types[rawTypeName] {
                if !((rawTypeCandidate is SourceryProtocol) || (rawTypeCandidate is ProtocolComposition)) {
                    enumeration.rawTypeName = TypeName(rawTypeName)
                    enumeration.rawType = rawTypeCandidate
                }
            } else {
                enumeration.rawTypeName = TypeName(rawTypeName)
            }
        }
    }

    private static func resolveProtocolCompositionTypes(_ protocolComposition: ProtocolComposition, resolve: TypeResolver) {
        let composedTypes = protocolComposition.composedTypeNames.compactMap { typeName in
            resolve(typeName, protocolComposition)
        }

        protocolComposition.composedTypes = composedTypes
    }

    private static func resolveProtocolTypes(_ sourceryProtocol: SourceryProtocol, resolve: TypeResolver) {
        sourceryProtocol.associatedTypes.forEach { (_, value) in
            guard let typeName = value.typeName,
                  let type = resolve(typeName, sourceryProtocol)
            else { return }
            value.type = type
        }

        sourceryProtocol.genericRequirements.forEach { requirment in
            if let knownAssociatedType = sourceryProtocol.associatedTypes[requirment.leftType.name] {
                requirment.leftType = knownAssociatedType
            }
            requirment.rightType.type = resolve(requirment.rightType.typeName, sourceryProtocol)
        }
    }

    private static func actualTypeName(for typeName: TypeName,
                                       containingType: Type? = nil,
                                       state: State) -> TypeName? {
        let unique = state.typeMap
        let modules = state.modules
        let typealiases = state.resolvedTypealiases

        var unwrapped = typeName.unwrappedTypeName
        if let generic = typeName.generic {
            unwrapped = generic.name
        }

        guard let aliased = state.resolveGlobalName(for: unwrapped, containingType: containingType, unique: unique, modules: modules, typealiases: typealiases) else {
            return nil
        }

        /// TODO: verify
        let generic = typeName.generic.map { GenericType(name: $0.name, typeParameters: $0.typeParameters) }
        generic?.name = aliased.name
        let dictionary = typeName.dictionary.map { DictionaryType(name: $0.name, valueTypeName: $0.valueTypeName, valueType: $0.valueType, keyTypeName: $0.keyTypeName, keyType: $0.keyType) }
        dictionary?.name = aliased.name
        let array = typeName.array.map { ArrayType(name: $0.name, elementTypeName: $0.elementTypeName, elementType: $0.elementType) }
        array?.name = aliased.name

        return TypeName(name: aliased.name,
                        isOptional: typeName.isOptional,
                        isImplicitlyUnwrappedOptional: typeName.isImplicitlyUnwrappedOptional,
                        tuple: aliased.typealias?.typeName.tuple ?? typeName.tuple, // TODO: verify
                        array: aliased.typealias?.typeName.array ?? array,
                        dictionary: aliased.typealias?.typeName.dictionary ?? dictionary,
                        closure: aliased.typealias?.typeName.closure ?? typeName.closure,
                        generic: aliased.typealias?.typeName.generic ?? generic
        )
    }

    private static func updateTypeRelationships(types: [Type]) {
        var typesByName = [String: Type]()
        types.forEach { typesByName[$0.globalName] = $0 }

        var processed = [String: Bool]()
        types.forEach { type in
            if let type = type as? Class, let supertype = type.inheritedTypes.first.flatMap({ typesByName[$0] }) as? Class {
                type.supertype = supertype
            }
            processed[type.globalName] = true
            updateTypeRelationship(for: type, typesByName: typesByName, processed: &processed)
        }
    }

    private static func findBaseType(for type: Type, name: String, typesByName: [String: Type]) -> Type? {
        if let baseType = typesByName[name] {
            return baseType
        }
        if let module = type.module, let baseType = typesByName["\\(module).\\(name)"] {
            return baseType
        }
        for importModule in type.imports {
            if let baseType = typesByName["\\(importModule).\\(name)"] {
                return baseType
            }
        }
        return nil
    }

    private static func updateTypeRelationship(for type: Type, typesByName: [String: Type], processed: inout [String: Bool]) {
        type.based.keys.forEach { name in
            guard let baseType = findBaseType(for: type, name: name, typesByName: typesByName) else { return }
            let globalName = baseType.globalName
            if processed[globalName] != true {
                processed[globalName] = true
                updateTypeRelationship(for: baseType, typesByName: typesByName, processed: &processed)
            }

            baseType.based.keys.forEach { type.based[$0] = $0 }
            baseType.basedTypes.forEach { type.basedTypes[$0.key] = $0.value }
            baseType.inherits.forEach { type.inherits[$0.key] = $0.value }
            baseType.implements.forEach { type.implements[$0.key] = $0.value }

            if baseType is Class {
                type.inherits[globalName] = baseType
            } else if let baseProtocol = baseType as? SourceryProtocol {
                type.implements[globalName] = baseProtocol
                if let extendingProtocol = type as? SourceryProtocol {
                    baseProtocol.associatedTypes.forEach {
                        if extendingProtocol.associatedTypes[$0.key] == nil {
                            extendingProtocol.associatedTypes[$0.key] = $0.value
                        }
                    }
                }
            } else if baseType is ProtocolComposition {
                // TODO: associated types?
                type.implements[globalName] = baseType
            }

            type.basedTypes[globalName] = baseType
        }
    }
}

"""),
    .init(name: "Definition.swift", content:
"""
import Foundation

/// Describes that the object is defined in a context of some `Type`
public protocol Definition: AnyObject {
    /// Reference to type name where the object is defined, 
    /// nil if defined outside of any `enum`, `struct`, `class` etc
    var definedInTypeName: TypeName? { get }

    /// Reference to actual type where the object is defined, 
    /// nil if defined outside of any `enum`, `struct`, `class` etc or type is unknown
    var definedInType: Type? { get }

    // sourcery: skipJSExport
    /// Reference to actual type name where the method is defined if declaration uses typealias, otherwise just a `definedInTypeName`
    var actualDefinedInTypeName: TypeName? { get }
}

"""),
    .init(name: "Description.generated.swift", content:
"""
// Generated using Sourcery 1.8.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable vertical_whitespace


extension ArrayType {
    /// :nodoc:
    override public var description: String {
        var string = "\\(Swift.type(of: self)): "
        string += "name = \\(String(describing: self.name)), "
        string += "elementTypeName = \\(String(describing: self.elementTypeName)), "
        string += "asGeneric = \\(String(describing: self.asGeneric)), "
        string += "asSource = \\(String(describing: self.asSource))"
        return string
    }
}
extension AssociatedType {
    /// :nodoc:
    override public var description: String {
        var string = "\\(Swift.type(of: self)): "
        string += "name = \\(String(describing: self.name)), "
        string += "typeName = \\(String(describing: self.typeName))"
        return string
    }
}
extension AssociatedValue {
    /// :nodoc:
    override public var description: String {
        var string = "\\(Swift.type(of: self)): "
        string += "localName = \\(String(describing: self.localName)), "
        string += "externalName = \\(String(describing: self.externalName)), "
        string += "typeName = \\(String(describing: self.typeName)), "
        string += "defaultValue = \\(String(describing: self.defaultValue)), "
        string += "annotations = \\(String(describing: self.annotations))"
        return string
    }
}
extension BytesRange {
    /// :nodoc:
    override public var description: String {
        var string = "\\(Swift.type(of: self)): "
        string += "offset = \\(String(describing: self.offset)), "
        string += "length = \\(String(describing: self.length))"
        return string
    }
}
extension Class {
    /// :nodoc:
    override public var description: String {
        var string = super.description
        string += ", "
        string += "kind = \\(String(describing: self.kind)), "
        string += "isFinal = \\(String(describing: self.isFinal))"
        return string
    }
}
extension ClosureParameter {
    /// :nodoc:
    override public var description: String {
        var string = "\\(Swift.type(of: self)): "
        string += "argumentLabel = \\(String(describing: self.argumentLabel)), "
        string += "name = \\(String(describing: self.name)), "
        string += "typeName = \\(String(describing: self.typeName)), "
        string += "`inout` = \\(String(describing: self.`inout`)), "
        string += "typeAttributes = \\(String(describing: self.typeAttributes)), "
        string += "defaultValue = \\(String(describing: self.defaultValue)), "
        string += "annotations = \\(String(describing: self.annotations)), "
        string += "asSource = \\(String(describing: self.asSource))"
        return string
    }
}
extension ClosureType {
    /// :nodoc:
    override public var description: String {
        var string = "\\(Swift.type(of: self)): "
        string += "name = \\(String(describing: self.name)), "
        string += "parameters = \\(String(describing: self.parameters)), "
        string += "returnTypeName = \\(String(describing: self.returnTypeName)), "
        string += "actualReturnTypeName = \\(String(describing: self.actualReturnTypeName)), "
        string += "isAsync = \\(String(describing: self.isAsync)), "
        string += "asyncKeyword = \\(String(describing: self.asyncKeyword)), "
        string += "`throws` = \\(String(describing: self.`throws`)), "
        string += "throwsOrRethrowsKeyword = \\(String(describing: self.throwsOrRethrowsKeyword)), "
        string += "asSource = \\(String(describing: self.asSource))"
        return string
    }
}
extension DictionaryType {
    /// :nodoc:
    override public var description: String {
        var string = "\\(Swift.type(of: self)): "
        string += "name = \\(String(describing: self.name)), "
        string += "valueTypeName = \\(String(describing: self.valueTypeName)), "
        string += "keyTypeName = \\(String(describing: self.keyTypeName)), "
        string += "asGeneric = \\(String(describing: self.asGeneric)), "
        string += "asSource = \\(String(describing: self.asSource))"
        return string
    }
}
extension Enum {
    /// :nodoc:
    override public var description: String {
        var string = super.description
        string += ", "
        string += "cases = \\(String(describing: self.cases)), "
        string += "rawTypeName = \\(String(describing: self.rawTypeName)), "
        string += "hasAssociatedValues = \\(String(describing: self.hasAssociatedValues))"
        return string
    }
}
extension EnumCase {
    /// :nodoc:
    override public var description: String {
        var string = "\\(Swift.type(of: self)): "
        string += "name = \\(String(describing: self.name)), "
        string += "rawValue = \\(String(describing: self.rawValue)), "
        string += "associatedValues = \\(String(describing: self.associatedValues)), "
        string += "annotations = \\(String(describing: self.annotations)), "
        string += "documentation = \\(String(describing: self.documentation)), "
        string += "indirect = \\(String(describing: self.indirect)), "
        string += "hasAssociatedValue = \\(String(describing: self.hasAssociatedValue))"
        return string
    }
}
extension FileParserResult {
    /// :nodoc:
    override public var description: String {
        var string = "\\(Swift.type(of: self)): "
        string += "path = \\(String(describing: self.path)), "
        string += "module = \\(String(describing: self.module)), "
        string += "types = \\(String(describing: self.types)), "
        string += "functions = \\(String(describing: self.functions)), "
        string += "typealiases = \\(String(describing: self.typealiases)), "
        string += "inlineRanges = \\(String(describing: self.inlineRanges)), "
        string += "inlineIndentations = \\(String(describing: self.inlineIndentations)), "
        string += "modifiedDate = \\(String(describing: self.modifiedDate)), "
        string += "sourceryVersion = \\(String(describing: self.sourceryVersion)), "
        string += "isEmpty = \\(String(describing: self.isEmpty))"
        return string
    }
}
extension GenericRequirement {
    /// :nodoc:
    override public var description: String {
        var string = "\\(Swift.type(of: self)): "
        string += "leftType = \\(String(describing: self.leftType)), "
        string += "rightType = \\(String(describing: self.rightType)), "
        string += "relationship = \\(String(describing: self.relationship)), "
        string += "relationshipSyntax = \\(String(describing: self.relationshipSyntax))"
        return string
    }
}
extension GenericTypeParameter {
    /// :nodoc:
    override public var description: String {
        var string = "\\(Swift.type(of: self)): "
        string += "typeName = \\(String(describing: self.typeName))"
        return string
    }
}
extension Method {
    /// :nodoc:
    override public var description: String {
        var string = "\\(Swift.type(of: self)): "
        string += "name = \\(String(describing: self.name)), "
        string += "selectorName = \\(String(describing: self.selectorName)), "
        string += "parameters = \\(String(describing: self.parameters)), "
        string += "returnTypeName = \\(String(describing: self.returnTypeName)), "
        string += "isAsync = \\(String(describing: self.isAsync)), "
        string += "`throws` = \\(String(describing: self.`throws`)), "
        string += "`rethrows` = \\(String(describing: self.`rethrows`)), "
        string += "accessLevel = \\(String(describing: self.accessLevel)), "
        string += "isStatic = \\(String(describing: self.isStatic)), "
        string += "isClass = \\(String(describing: self.isClass)), "
        string += "isFailableInitializer = \\(String(describing: self.isFailableInitializer)), "
        string += "annotations = \\(String(describing: self.annotations)), "
        string += "documentation = \\(String(describing: self.documentation)), "
        string += "definedInTypeName = \\(String(describing: self.definedInTypeName)), "
        string += "attributes = \\(String(describing: self.attributes)), "
        string += "modifiers = \\(String(describing: self.modifiers))"
        return string
    }
}
extension MethodParameter {
    /// :nodoc:
    override public var description: String {
        var string = "\\(Swift.type(of: self)): "
        string += "argumentLabel = \\(String(describing: self.argumentLabel)), "
        string += "name = \\(String(describing: self.name)), "
        string += "typeName = \\(String(describing: self.typeName)), "
        string += "`inout` = \\(String(describing: self.`inout`)), "
        string += "isVariadic = \\(String(describing: self.isVariadic)), "
        string += "typeAttributes = \\(String(describing: self.typeAttributes)), "
        string += "defaultValue = \\(String(describing: self.defaultValue)), "
        string += "annotations = \\(String(describing: self.annotations)), "
        string += "asSource = \\(String(describing: self.asSource))"
        return string
    }
}
extension Protocol {
    /// :nodoc:
    override public var description: String {
        var string = super.description
        string += ", "
        string += "kind = \\(String(describing: self.kind)), "
        string += "associatedTypes = \\(String(describing: self.associatedTypes)), "
        string += "genericRequirements = \\(String(describing: self.genericRequirements))"
        return string
    }
}
extension ProtocolComposition {
    /// :nodoc:
    override public var description: String {
        var string = super.description
        string += ", "
        string += "kind = \\(String(describing: self.kind)), "
        string += "composedTypeNames = \\(String(describing: self.composedTypeNames))"
        return string
    }
}
extension Struct {
    /// :nodoc:
    override public var description: String {
        var string = super.description
        string += ", "
        string += "kind = \\(String(describing: self.kind))"
        return string
    }
}
extension Subscript {
    /// :nodoc:
    override public var description: String {
        var string = "\\(Swift.type(of: self)): "
        string += "parameters = \\(String(describing: self.parameters)), "
        string += "returnTypeName = \\(String(describing: self.returnTypeName)), "
        string += "actualReturnTypeName = \\(String(describing: self.actualReturnTypeName)), "
        string += "isFinal = \\(String(describing: self.isFinal)), "
        string += "readAccess = \\(String(describing: self.readAccess)), "
        string += "writeAccess = \\(String(describing: self.writeAccess)), "
        string += "isMutable = \\(String(describing: self.isMutable)), "
        string += "annotations = \\(String(describing: self.annotations)), "
        string += "documentation = \\(String(describing: self.documentation)), "
        string += "definedInTypeName = \\(String(describing: self.definedInTypeName)), "
        string += "actualDefinedInTypeName = \\(String(describing: self.actualDefinedInTypeName)), "
        string += "attributes = \\(String(describing: self.attributes)), "
        string += "modifiers = \\(String(describing: self.modifiers))"
        return string
    }
}
extension TemplateContext {
    /// :nodoc:
    override public var description: String {
        var string = "\\(Swift.type(of: self)): "
        string += "parserResult = \\(String(describing: self.parserResult)), "
        string += "functions = \\(String(describing: self.functions)), "
        string += "types = \\(String(describing: self.types)), "
        string += "argument = \\(String(describing: self.argument)), "
        string += "stencilContext = \\(String(describing: self.stencilContext))"
        return string
    }
}
extension TupleElement {
    /// :nodoc:
    override public var description: String {
        var string = "\\(Swift.type(of: self)): "
        string += "name = \\(String(describing: self.name)), "
        string += "typeName = \\(String(describing: self.typeName)), "
        string += "asSource = \\(String(describing: self.asSource))"
        return string
    }
}
extension TupleType {
    /// :nodoc:
    override public var description: String {
        var string = "\\(Swift.type(of: self)): "
        string += "name = \\(String(describing: self.name)), "
        string += "elements = \\(String(describing: self.elements))"
        return string
    }
}
extension Type {
    /// :nodoc:
    override public var description: String {
        var string = "\\(Swift.type(of: self)): "
        string += "module = \\(String(describing: self.module)), "
        string += "imports = \\(String(describing: self.imports)), "
        string += "allImports = \\(String(describing: self.allImports)), "
        string += "typealiases = \\(String(describing: self.typealiases)), "
        string += "isExtension = \\(String(describing: self.isExtension)), "
        string += "kind = \\(String(describing: self.kind)), "
        string += "accessLevel = \\(String(describing: self.accessLevel)), "
        string += "name = \\(String(describing: self.name)), "
        string += "isUnknownExtension = \\(String(describing: self.isUnknownExtension)), "
        string += "isGeneric = \\(String(describing: self.isGeneric)), "
        string += "localName = \\(String(describing: self.localName)), "
        string += "rawVariables = \\(String(describing: self.rawVariables)), "
        string += "rawMethods = \\(String(describing: self.rawMethods)), "
        string += "rawSubscripts = \\(String(describing: self.rawSubscripts)), "
        string += "initializers = \\(String(describing: self.initializers)), "
        string += "annotations = \\(String(describing: self.annotations)), "
        string += "documentation = \\(String(describing: self.documentation)), "
        string += "staticVariables = \\(String(describing: self.staticVariables)), "
        string += "staticMethods = \\(String(describing: self.staticMethods)), "
        string += "classMethods = \\(String(describing: self.classMethods)), "
        string += "instanceVariables = \\(String(describing: self.instanceVariables)), "
        string += "instanceMethods = \\(String(describing: self.instanceMethods)), "
        string += "computedVariables = \\(String(describing: self.computedVariables)), "
        string += "storedVariables = \\(String(describing: self.storedVariables)), "
        string += "inheritedTypes = \\(String(describing: self.inheritedTypes)), "
        string += "inherits = \\(String(describing: self.inherits)), "
        string += "containedTypes = \\(String(describing: self.containedTypes)), "
        string += "parentName = \\(String(describing: self.parentName)), "
        string += "parentTypes = \\(String(describing: self.parentTypes)), "
        string += "attributes = \\(String(describing: self.attributes)), "
        string += "modifiers = \\(String(describing: self.modifiers)), "
        string += "fileName = \\(String(describing: self.fileName))"
        return string
    }
}
extension Typealias {
    /// :nodoc:
    override public var description: String {
        var string = "\\(Swift.type(of: self)): "
        string += "aliasName = \\(String(describing: self.aliasName)), "
        string += "typeName = \\(String(describing: self.typeName)), "
        string += "module = \\(String(describing: self.module)), "
        string += "accessLevel = \\(String(describing: self.accessLevel)), "
        string += "parentName = \\(String(describing: self.parentName)), "
        string += "name = \\(String(describing: self.name))"
        return string
    }
}
extension Types {
    /// :nodoc:
    override public var description: String {
        var string = "\\(Swift.type(of: self)): "
        string += "types = \\(String(describing: self.types)), "
        string += "typealiases = \\(String(describing: self.typealiases))"
        return string
    }
}
extension Variable {
    /// :nodoc:
    override public var description: String {
        var string = "\\(Swift.type(of: self)): "
        string += "name = \\(String(describing: self.name)), "
        string += "typeName = \\(String(describing: self.typeName)), "
        string += "isComputed = \\(String(describing: self.isComputed)), "
        string += "isAsync = \\(String(describing: self.isAsync)), "
        string += "`throws` = \\(String(describing: self.`throws`)), "
        string += "isStatic = \\(String(describing: self.isStatic)), "
        string += "readAccess = \\(String(describing: self.readAccess)), "
        string += "writeAccess = \\(String(describing: self.writeAccess)), "
        string += "accessLevel = \\(String(describing: self.accessLevel)), "
        string += "isMutable = \\(String(describing: self.isMutable)), "
        string += "defaultValue = \\(String(describing: self.defaultValue)), "
        string += "annotations = \\(String(describing: self.annotations)), "
        string += "documentation = \\(String(describing: self.documentation)), "
        string += "attributes = \\(String(describing: self.attributes)), "
        string += "modifiers = \\(String(describing: self.modifiers)), "
        string += "isFinal = \\(String(describing: self.isFinal)), "
        string += "isLazy = \\(String(describing: self.isLazy)), "
        string += "definedInTypeName = \\(String(describing: self.definedInTypeName)), "
        string += "actualDefinedInTypeName = \\(String(describing: self.actualDefinedInTypeName))"
        return string
    }
}

"""),
    .init(name: "Dictionary.swift", content:
"""
import Foundation

/// Describes dictionary type
@objcMembers public final class DictionaryType: NSObject, SourceryModel {
    /// Type name used in declaration
    public var name: String

    /// Dictionary value type name
    public var valueTypeName: TypeName

    // sourcery: skipEquality, skipDescription
    /// Dictionary value type, if known
    public var valueType: Type?

    /// Dictionary key type name
    public var keyTypeName: TypeName

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

    /// Returns dictionary as generic type
    public var asGeneric: GenericType {
        GenericType(name: "Dictionary", typeParameters: [
            .init(typeName: keyTypeName),
            .init(typeName: valueTypeName)
        ])
    }

    public var asSource: String {
        "[\\(keyTypeName.asSource): \\(valueTypeName.asSource)]"
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

"""),
    .init(name: "Diffable.generated.swift", content:
"""
// Generated using Sourcery 1.8.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation

extension ArrayType: Diffable {
    @objc public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? ArrayType else {
            results.append("Incorrect type <expected: ArrayType, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: castObject.name))
        results.append(contentsOf: DiffableResult(identifier: "elementTypeName").trackDifference(actual: self.elementTypeName, expected: castObject.elementTypeName))
        return results
    }
}
extension AssociatedType: Diffable {
    @objc public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? AssociatedType else {
            results.append("Incorrect type <expected: AssociatedType, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: castObject.name))
        results.append(contentsOf: DiffableResult(identifier: "typeName").trackDifference(actual: self.typeName, expected: castObject.typeName))
        return results
    }
}
extension AssociatedValue: Diffable {
    @objc public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? AssociatedValue else {
            results.append("Incorrect type <expected: AssociatedValue, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "localName").trackDifference(actual: self.localName, expected: castObject.localName))
        results.append(contentsOf: DiffableResult(identifier: "externalName").trackDifference(actual: self.externalName, expected: castObject.externalName))
        results.append(contentsOf: DiffableResult(identifier: "typeName").trackDifference(actual: self.typeName, expected: castObject.typeName))
        results.append(contentsOf: DiffableResult(identifier: "defaultValue").trackDifference(actual: self.defaultValue, expected: castObject.defaultValue))
        results.append(contentsOf: DiffableResult(identifier: "annotations").trackDifference(actual: self.annotations, expected: castObject.annotations))
        return results
    }
}
extension Attribute: Diffable {
    @objc public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? Attribute else {
            results.append("Incorrect type <expected: Attribute, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: castObject.name))
        results.append(contentsOf: DiffableResult(identifier: "arguments").trackDifference(actual: self.arguments, expected: castObject.arguments))
        results.append(contentsOf: DiffableResult(identifier: "_description").trackDifference(actual: self._description, expected: castObject._description))
        return results
    }
}
extension BytesRange: Diffable {
    @objc public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? BytesRange else {
            results.append("Incorrect type <expected: BytesRange, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "offset").trackDifference(actual: self.offset, expected: castObject.offset))
        results.append(contentsOf: DiffableResult(identifier: "length").trackDifference(actual: self.length, expected: castObject.length))
        return results
    }
}
extension Class {
    override public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? Class else {
            results.append("Incorrect type <expected: Class, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: super.diffAgainst(castObject))
        return results
    }
}
extension ClosureType: Diffable {
    @objc public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? ClosureType else {
            results.append("Incorrect type <expected: ClosureType, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: castObject.name))
        results.append(contentsOf: DiffableResult(identifier: "parameters").trackDifference(actual: self.parameters, expected: castObject.parameters))
        results.append(contentsOf: DiffableResult(identifier: "returnTypeName").trackDifference(actual: self.returnTypeName, expected: castObject.returnTypeName))
        results.append(contentsOf: DiffableResult(identifier: "isAsync").trackDifference(actual: self.isAsync, expected: castObject.isAsync))
        results.append(contentsOf: DiffableResult(identifier: "asyncKeyword").trackDifference(actual: self.asyncKeyword, expected: castObject.asyncKeyword))
        results.append(contentsOf: DiffableResult(identifier: "`throws`").trackDifference(actual: self.`throws`, expected: castObject.`throws`))
        results.append(contentsOf: DiffableResult(identifier: "throwsOrRethrowsKeyword").trackDifference(actual: self.throwsOrRethrowsKeyword, expected: castObject.throwsOrRethrowsKeyword))
        return results
    }
}
extension DictionaryType: Diffable {
    @objc public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? DictionaryType else {
            results.append("Incorrect type <expected: DictionaryType, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: castObject.name))
        results.append(contentsOf: DiffableResult(identifier: "valueTypeName").trackDifference(actual: self.valueTypeName, expected: castObject.valueTypeName))
        results.append(contentsOf: DiffableResult(identifier: "keyTypeName").trackDifference(actual: self.keyTypeName, expected: castObject.keyTypeName))
        return results
    }
}
extension Enum {
    override public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? Enum else {
            results.append("Incorrect type <expected: Enum, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "cases").trackDifference(actual: self.cases, expected: castObject.cases))
        results.append(contentsOf: DiffableResult(identifier: "rawTypeName").trackDifference(actual: self.rawTypeName, expected: castObject.rawTypeName))
        results.append(contentsOf: super.diffAgainst(castObject))
        return results
    }
}
extension EnumCase: Diffable {
    @objc public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? EnumCase else {
            results.append("Incorrect type <expected: EnumCase, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: castObject.name))
        results.append(contentsOf: DiffableResult(identifier: "rawValue").trackDifference(actual: self.rawValue, expected: castObject.rawValue))
        results.append(contentsOf: DiffableResult(identifier: "associatedValues").trackDifference(actual: self.associatedValues, expected: castObject.associatedValues))
        results.append(contentsOf: DiffableResult(identifier: "annotations").trackDifference(actual: self.annotations, expected: castObject.annotations))
        results.append(contentsOf: DiffableResult(identifier: "documentation").trackDifference(actual: self.documentation, expected: castObject.documentation))
        results.append(contentsOf: DiffableResult(identifier: "indirect").trackDifference(actual: self.indirect, expected: castObject.indirect))
        return results
    }
}
extension FileParserResult: Diffable {
    @objc public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? FileParserResult else {
            results.append("Incorrect type <expected: FileParserResult, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "path").trackDifference(actual: self.path, expected: castObject.path))
        results.append(contentsOf: DiffableResult(identifier: "module").trackDifference(actual: self.module, expected: castObject.module))
        results.append(contentsOf: DiffableResult(identifier: "types").trackDifference(actual: self.types, expected: castObject.types))
        results.append(contentsOf: DiffableResult(identifier: "functions").trackDifference(actual: self.functions, expected: castObject.functions))
        results.append(contentsOf: DiffableResult(identifier: "typealiases").trackDifference(actual: self.typealiases, expected: castObject.typealiases))
        results.append(contentsOf: DiffableResult(identifier: "inlineRanges").trackDifference(actual: self.inlineRanges, expected: castObject.inlineRanges))
        results.append(contentsOf: DiffableResult(identifier: "inlineIndentations").trackDifference(actual: self.inlineIndentations, expected: castObject.inlineIndentations))
        results.append(contentsOf: DiffableResult(identifier: "modifiedDate").trackDifference(actual: self.modifiedDate, expected: castObject.modifiedDate))
        results.append(contentsOf: DiffableResult(identifier: "sourceryVersion").trackDifference(actual: self.sourceryVersion, expected: castObject.sourceryVersion))
        return results
    }
}
extension GenericRequirement: Diffable {
    @objc public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? GenericRequirement else {
            results.append("Incorrect type <expected: GenericRequirement, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "leftType").trackDifference(actual: self.leftType, expected: castObject.leftType))
        results.append(contentsOf: DiffableResult(identifier: "rightType").trackDifference(actual: self.rightType, expected: castObject.rightType))
        results.append(contentsOf: DiffableResult(identifier: "relationship").trackDifference(actual: self.relationship, expected: castObject.relationship))
        results.append(contentsOf: DiffableResult(identifier: "relationshipSyntax").trackDifference(actual: self.relationshipSyntax, expected: castObject.relationshipSyntax))
        return results
    }
}
extension GenericType: Diffable {
    @objc public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? GenericType else {
            results.append("Incorrect type <expected: GenericType, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: castObject.name))
        results.append(contentsOf: DiffableResult(identifier: "typeParameters").trackDifference(actual: self.typeParameters, expected: castObject.typeParameters))
        return results
    }
}
extension GenericTypeParameter: Diffable {
    @objc public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? GenericTypeParameter else {
            results.append("Incorrect type <expected: GenericTypeParameter, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "typeName").trackDifference(actual: self.typeName, expected: castObject.typeName))
        return results
    }
}
extension Import: Diffable {
    @objc public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? Import else {
            results.append("Incorrect type <expected: Import, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "kind").trackDifference(actual: self.kind, expected: castObject.kind))
        results.append(contentsOf: DiffableResult(identifier: "path").trackDifference(actual: self.path, expected: castObject.path))
        return results
    }
}
extension Method: Diffable {
    @objc public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? Method else {
            results.append("Incorrect type <expected: Method, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: castObject.name))
        results.append(contentsOf: DiffableResult(identifier: "selectorName").trackDifference(actual: self.selectorName, expected: castObject.selectorName))
        results.append(contentsOf: DiffableResult(identifier: "parameters").trackDifference(actual: self.parameters, expected: castObject.parameters))
        results.append(contentsOf: DiffableResult(identifier: "returnTypeName").trackDifference(actual: self.returnTypeName, expected: castObject.returnTypeName))
        results.append(contentsOf: DiffableResult(identifier: "isAsync").trackDifference(actual: self.isAsync, expected: castObject.isAsync))
        results.append(contentsOf: DiffableResult(identifier: "`throws`").trackDifference(actual: self.`throws`, expected: castObject.`throws`))
        results.append(contentsOf: DiffableResult(identifier: "`rethrows`").trackDifference(actual: self.`rethrows`, expected: castObject.`rethrows`))
        results.append(contentsOf: DiffableResult(identifier: "accessLevel").trackDifference(actual: self.accessLevel, expected: castObject.accessLevel))
        results.append(contentsOf: DiffableResult(identifier: "isStatic").trackDifference(actual: self.isStatic, expected: castObject.isStatic))
        results.append(contentsOf: DiffableResult(identifier: "isClass").trackDifference(actual: self.isClass, expected: castObject.isClass))
        results.append(contentsOf: DiffableResult(identifier: "isFailableInitializer").trackDifference(actual: self.isFailableInitializer, expected: castObject.isFailableInitializer))
        results.append(contentsOf: DiffableResult(identifier: "annotations").trackDifference(actual: self.annotations, expected: castObject.annotations))
        results.append(contentsOf: DiffableResult(identifier: "documentation").trackDifference(actual: self.documentation, expected: castObject.documentation))
        results.append(contentsOf: DiffableResult(identifier: "definedInTypeName").trackDifference(actual: self.definedInTypeName, expected: castObject.definedInTypeName))
        results.append(contentsOf: DiffableResult(identifier: "attributes").trackDifference(actual: self.attributes, expected: castObject.attributes))
        results.append(contentsOf: DiffableResult(identifier: "modifiers").trackDifference(actual: self.modifiers, expected: castObject.modifiers))
        return results
    }
}
extension MethodParameter: Diffable {
    @objc public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? MethodParameter else {
            results.append("Incorrect type <expected: MethodParameter, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "argumentLabel").trackDifference(actual: self.argumentLabel, expected: castObject.argumentLabel))
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: castObject.name))
        results.append(contentsOf: DiffableResult(identifier: "typeName").trackDifference(actual: self.typeName, expected: castObject.typeName))
        results.append(contentsOf: DiffableResult(identifier: "`inout`").trackDifference(actual: self.`inout`, expected: castObject.`inout`))
        results.append(contentsOf: DiffableResult(identifier: "isVariadic").trackDifference(actual: self.isVariadic, expected: castObject.isVariadic))
        results.append(contentsOf: DiffableResult(identifier: "defaultValue").trackDifference(actual: self.defaultValue, expected: castObject.defaultValue))
        results.append(contentsOf: DiffableResult(identifier: "annotations").trackDifference(actual: self.annotations, expected: castObject.annotations))
        return results
    }
}
extension Modifier: Diffable {
    @objc public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? Modifier else {
            results.append("Incorrect type <expected: Modifier, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: castObject.name))
        results.append(contentsOf: DiffableResult(identifier: "detail").trackDifference(actual: self.detail, expected: castObject.detail))
        return results
    }
}
extension Protocol {
    override public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? Protocol else {
            results.append("Incorrect type <expected: Protocol, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "associatedTypes").trackDifference(actual: self.associatedTypes, expected: castObject.associatedTypes))
        results.append(contentsOf: DiffableResult(identifier: "genericRequirements").trackDifference(actual: self.genericRequirements, expected: castObject.genericRequirements))
        results.append(contentsOf: super.diffAgainst(castObject))
        return results
    }
}
extension ProtocolComposition {
    override public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? ProtocolComposition else {
            results.append("Incorrect type <expected: ProtocolComposition, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "composedTypeNames").trackDifference(actual: self.composedTypeNames, expected: castObject.composedTypeNames))
        results.append(contentsOf: super.diffAgainst(castObject))
        return results
    }
}
extension Struct {
    override public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? Struct else {
            results.append("Incorrect type <expected: Struct, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: super.diffAgainst(castObject))
        return results
    }
}
extension Subscript: Diffable {
    @objc public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? Subscript else {
            results.append("Incorrect type <expected: Subscript, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "parameters").trackDifference(actual: self.parameters, expected: castObject.parameters))
        results.append(contentsOf: DiffableResult(identifier: "returnTypeName").trackDifference(actual: self.returnTypeName, expected: castObject.returnTypeName))
        results.append(contentsOf: DiffableResult(identifier: "readAccess").trackDifference(actual: self.readAccess, expected: castObject.readAccess))
        results.append(contentsOf: DiffableResult(identifier: "writeAccess").trackDifference(actual: self.writeAccess, expected: castObject.writeAccess))
        results.append(contentsOf: DiffableResult(identifier: "annotations").trackDifference(actual: self.annotations, expected: castObject.annotations))
        results.append(contentsOf: DiffableResult(identifier: "documentation").trackDifference(actual: self.documentation, expected: castObject.documentation))
        results.append(contentsOf: DiffableResult(identifier: "definedInTypeName").trackDifference(actual: self.definedInTypeName, expected: castObject.definedInTypeName))
        results.append(contentsOf: DiffableResult(identifier: "attributes").trackDifference(actual: self.attributes, expected: castObject.attributes))
        results.append(contentsOf: DiffableResult(identifier: "modifiers").trackDifference(actual: self.modifiers, expected: castObject.modifiers))
        return results
    }
}
extension TemplateContext: Diffable {
    @objc public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? TemplateContext else {
            results.append("Incorrect type <expected: TemplateContext, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "parserResult").trackDifference(actual: self.parserResult, expected: castObject.parserResult))
        results.append(contentsOf: DiffableResult(identifier: "functions").trackDifference(actual: self.functions, expected: castObject.functions))
        results.append(contentsOf: DiffableResult(identifier: "types").trackDifference(actual: self.types, expected: castObject.types))
        results.append(contentsOf: DiffableResult(identifier: "argument").trackDifference(actual: self.argument, expected: castObject.argument))
        return results
    }
}
extension TupleElement: Diffable {
    @objc public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? TupleElement else {
            results.append("Incorrect type <expected: TupleElement, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: castObject.name))
        results.append(contentsOf: DiffableResult(identifier: "typeName").trackDifference(actual: self.typeName, expected: castObject.typeName))
        return results
    }
}
extension TupleType: Diffable {
    @objc public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? TupleType else {
            results.append("Incorrect type <expected: TupleType, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: castObject.name))
        results.append(contentsOf: DiffableResult(identifier: "elements").trackDifference(actual: self.elements, expected: castObject.elements))
        return results
    }
}
extension Type: Diffable {
    @objc public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? Type else {
            results.append("Incorrect type <expected: Type, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "module").trackDifference(actual: self.module, expected: castObject.module))
        results.append(contentsOf: DiffableResult(identifier: "imports").trackDifference(actual: self.imports, expected: castObject.imports))
        results.append(contentsOf: DiffableResult(identifier: "typealiases").trackDifference(actual: self.typealiases, expected: castObject.typealiases))
        results.append(contentsOf: DiffableResult(identifier: "isExtension").trackDifference(actual: self.isExtension, expected: castObject.isExtension))
        results.append(contentsOf: DiffableResult(identifier: "accessLevel").trackDifference(actual: self.accessLevel, expected: castObject.accessLevel))
        results.append(contentsOf: DiffableResult(identifier: "isUnknownExtension").trackDifference(actual: self.isUnknownExtension, expected: castObject.isUnknownExtension))
        results.append(contentsOf: DiffableResult(identifier: "isGeneric").trackDifference(actual: self.isGeneric, expected: castObject.isGeneric))
        results.append(contentsOf: DiffableResult(identifier: "localName").trackDifference(actual: self.localName, expected: castObject.localName))
        results.append(contentsOf: DiffableResult(identifier: "rawVariables").trackDifference(actual: self.rawVariables, expected: castObject.rawVariables))
        results.append(contentsOf: DiffableResult(identifier: "rawMethods").trackDifference(actual: self.rawMethods, expected: castObject.rawMethods))
        results.append(contentsOf: DiffableResult(identifier: "rawSubscripts").trackDifference(actual: self.rawSubscripts, expected: castObject.rawSubscripts))
        results.append(contentsOf: DiffableResult(identifier: "annotations").trackDifference(actual: self.annotations, expected: castObject.annotations))
        results.append(contentsOf: DiffableResult(identifier: "documentation").trackDifference(actual: self.documentation, expected: castObject.documentation))
        results.append(contentsOf: DiffableResult(identifier: "inheritedTypes").trackDifference(actual: self.inheritedTypes, expected: castObject.inheritedTypes))
        results.append(contentsOf: DiffableResult(identifier: "inherits").trackDifference(actual: self.inherits, expected: castObject.inherits))
        results.append(contentsOf: DiffableResult(identifier: "containedTypes").trackDifference(actual: self.containedTypes, expected: castObject.containedTypes))
        results.append(contentsOf: DiffableResult(identifier: "parentName").trackDifference(actual: self.parentName, expected: castObject.parentName))
        results.append(contentsOf: DiffableResult(identifier: "attributes").trackDifference(actual: self.attributes, expected: castObject.attributes))
        results.append(contentsOf: DiffableResult(identifier: "modifiers").trackDifference(actual: self.modifiers, expected: castObject.modifiers))
        results.append(contentsOf: DiffableResult(identifier: "fileName").trackDifference(actual: self.fileName, expected: castObject.fileName))
        return results
    }
}
extension TypeName: Diffable {
    @objc public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? TypeName else {
            results.append("Incorrect type <expected: TypeName, received: \\(Swift.type(of: object))>")
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
}
extension Typealias: Diffable {
    @objc public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? Typealias else {
            results.append("Incorrect type <expected: Typealias, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "aliasName").trackDifference(actual: self.aliasName, expected: castObject.aliasName))
        results.append(contentsOf: DiffableResult(identifier: "typeName").trackDifference(actual: self.typeName, expected: castObject.typeName))
        results.append(contentsOf: DiffableResult(identifier: "module").trackDifference(actual: self.module, expected: castObject.module))
        results.append(contentsOf: DiffableResult(identifier: "accessLevel").trackDifference(actual: self.accessLevel, expected: castObject.accessLevel))
        results.append(contentsOf: DiffableResult(identifier: "parentName").trackDifference(actual: self.parentName, expected: castObject.parentName))
        return results
    }
}
extension Types: Diffable {
    @objc public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? Types else {
            results.append("Incorrect type <expected: Types, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "types").trackDifference(actual: self.types, expected: castObject.types))
        results.append(contentsOf: DiffableResult(identifier: "typealiases").trackDifference(actual: self.typealiases, expected: castObject.typealiases))
        return results
    }
}
extension Variable: Diffable {
    @objc public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? Variable else {
            results.append("Incorrect type <expected: Variable, received: \\(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: castObject.name))
        results.append(contentsOf: DiffableResult(identifier: "typeName").trackDifference(actual: self.typeName, expected: castObject.typeName))
        results.append(contentsOf: DiffableResult(identifier: "isComputed").trackDifference(actual: self.isComputed, expected: castObject.isComputed))
        results.append(contentsOf: DiffableResult(identifier: "isAsync").trackDifference(actual: self.isAsync, expected: castObject.isAsync))
        results.append(contentsOf: DiffableResult(identifier: "`throws`").trackDifference(actual: self.`throws`, expected: castObject.`throws`))
        results.append(contentsOf: DiffableResult(identifier: "isStatic").trackDifference(actual: self.isStatic, expected: castObject.isStatic))
        results.append(contentsOf: DiffableResult(identifier: "readAccess").trackDifference(actual: self.readAccess, expected: castObject.readAccess))
        results.append(contentsOf: DiffableResult(identifier: "writeAccess").trackDifference(actual: self.writeAccess, expected: castObject.writeAccess))
        results.append(contentsOf: DiffableResult(identifier: "defaultValue").trackDifference(actual: self.defaultValue, expected: castObject.defaultValue))
        results.append(contentsOf: DiffableResult(identifier: "annotations").trackDifference(actual: self.annotations, expected: castObject.annotations))
        results.append(contentsOf: DiffableResult(identifier: "documentation").trackDifference(actual: self.documentation, expected: castObject.documentation))
        results.append(contentsOf: DiffableResult(identifier: "attributes").trackDifference(actual: self.attributes, expected: castObject.attributes))
        results.append(contentsOf: DiffableResult(identifier: "modifiers").trackDifference(actual: self.modifiers, expected: castObject.modifiers))
        results.append(contentsOf: DiffableResult(identifier: "definedInTypeName").trackDifference(actual: self.definedInTypeName, expected: castObject.definedInTypeName))
        return results
    }
}

"""),
    .init(name: "Diffable.swift", content:
"""
//
//  Diffable.swift
//  Sourcery
//
//  Created by Krzysztof Zabłocki on 22/12/2016.
//  Copyright © 2016 Pixle. All rights reserved.
//

import Foundation

public protocol Diffable {

    /// Returns `DiffableResult` for the given objects.
    ///
    /// - Parameter object: Object to diff against.
    /// - Returns: Diffable results.
    func diffAgainst(_ object: Any?) -> DiffableResult
}

/// :nodoc:
extension NSRange: Diffable {
    /// :nodoc:
    public static func == (lhs: NSRange, rhs: NSRange) -> Bool {
        return NSEqualRanges(lhs, rhs)
    }

    public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let rhs = object as? NSRange else {
            results.append("Incorrect type <expected: FileParserResult, received: \\(type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "location").trackDifference(actual: self.location, expected: rhs.location))
        results.append(contentsOf: DiffableResult(identifier: "length").trackDifference(actual: self.length, expected: rhs.length))
        return results
    }
}

@objcMembers public class DiffableResult: NSObject, AutoEquatable {
    // sourcery: skipEquality
    private var results: [String]
    internal var identifier: String?

    init(results: [String] = [], identifier: String? = nil) {
        self.results = results
        self.identifier = identifier
    }

    func append(_ element: String) {
        results.append(element)
    }

    func append(contentsOf contents: DiffableResult) {
        if !contents.isEmpty {
            results.append(contents.description)
        }
    }

    var isEmpty: Bool { return results.isEmpty }

    public override var description: String {
        guard !results.isEmpty else { return "" }
        return "\\(identifier.flatMap { "\\($0) " } ?? "")" + results.joined(separator: "\\n")
    }
}

public extension DiffableResult {

#if swift(>=4.1)
#else
    /// :nodoc:
    @discardableResult func trackDifference<T: Equatable>(actual: T, expected: T) -> DiffableResult {
        if actual != expected {
            let result = DiffableResult(results: ["<expected: \\(expected), received: \\(actual)>"])
            append(contentsOf: result)
        }
        return self
    }
#endif

    /// :nodoc:
    @discardableResult func trackDifference<T: Equatable>(actual: T?, expected: T?) -> DiffableResult {
        if actual != expected {
            let result = DiffableResult(results: ["<expected: \\(expected.map({ "\\($0)" }) ?? "nil"), received: \\(actual.map({ "\\($0)" }) ?? "nil")>"])
            append(contentsOf: result)
        }
        return self
    }

    /// :nodoc:
    @discardableResult func trackDifference<T: Equatable>(actual: T, expected: T) -> DiffableResult where T: Diffable {
        let diffResult = actual.diffAgainst(expected)
        append(contentsOf: diffResult)
        return self
    }

    /// :nodoc:
    @discardableResult func trackDifference<T: Equatable>(actual: [T], expected: [T]) -> DiffableResult where T: Diffable {
        let diffResult = DiffableResult()
        defer { append(contentsOf: diffResult) }

        guard actual.count == expected.count else {
            diffResult.append("Different count, expected: \\(expected.count), received: \\(actual.count)")
            return self
        }

        for (idx, item) in actual.enumerated() {
            let diff = DiffableResult()
            diff.trackDifference(actual: item, expected: expected[idx])
            if !diff.isEmpty {
                let string = "idx \\(idx): \\(diff)"
                diffResult.append(string)
            }
        }

        return self
    }

    /// :nodoc:
    @discardableResult func trackDifference<T: Equatable>(actual: [T], expected: [T]) -> DiffableResult {
        let diffResult = DiffableResult()
        defer { append(contentsOf: diffResult) }

        guard actual.count == expected.count else {
            diffResult.append("Different count, expected: \\(expected.count), received: \\(actual.count)")
            return self
        }

        for (idx, item) in actual.enumerated() where item != expected[idx] {
            let string = "idx \\(idx): <expected: \\(expected), received: \\(actual)>"
            diffResult.append(string)
        }

        return self
    }

    /// :nodoc:
    @discardableResult func trackDifference<K, T: Equatable>(actual: [K: T], expected: [K: T]) -> DiffableResult where T: Diffable {
        let diffResult = DiffableResult()
        defer { append(contentsOf: diffResult) }

        guard actual.count == expected.count else {
            append("Different count, expected: \\(expected.count), received: \\(actual.count)")

            if expected.count > actual.count {
                let missingKeys = Array(expected.keys.filter {
                    actual[$0] == nil
                }.map {
                    String(describing: $0)
                })
                diffResult.append("Missing keys: \\(missingKeys.joined(separator: ", "))")
            }
            return self
        }

        for (key, actualElement) in actual {
            guard let expectedElement = expected[key] else {
                diffResult.append("Missing key \\"\\(key)\\"")
                continue
            }

            let diff = DiffableResult()
            diff.trackDifference(actual: actualElement, expected: expectedElement)
            if !diff.isEmpty {
                let string = "key \\"\\(key)\\": \\(diff)"
                diffResult.append(string)
            }
        }

        return self
    }

// MARK: - NSObject diffing

    /// :nodoc:
    @discardableResult func trackDifference<K, T: NSObjectProtocol>(actual: [K: T], expected: [K: T]) -> DiffableResult {
        let diffResult = DiffableResult()
        defer { append(contentsOf: diffResult) }

        guard actual.count == expected.count else {
            append("Different count, expected: \\(expected.count), received: \\(actual.count)")

            if expected.count > actual.count {
                let missingKeys = Array(expected.keys.filter {
                    actual[$0] == nil
                    }.map {
                        String(describing: $0)
                })
                diffResult.append("Missing keys: \\(missingKeys.joined(separator: ", "))")
            }
            return self
        }

        for (key, actualElement) in actual {
            guard let expectedElement = expected[key] else {
                diffResult.append("Missing key \\"\\(key)\\"")
                continue
            }

            if !actualElement.isEqual(expectedElement) {
                diffResult.append("key \\"\\(key)\\": <expected: \\(expected), received: \\(actual)>")
            }
        }

        return self
    }
}

"""),
    .init(name: "Documentation.swift", content:
"""
import Foundation

public typealias Documentation = [String]

/// Describes a declaration with documentation, i.e. type, method, variable, enum case
public protocol Documented {
    var documentation: Documentation { get }
}

"""),
    .init(name: "Enum.swift", content:
"""
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

"""),
    .init(name: "Equality.generated.swift", content:
"""
// Generated using Sourcery 1.8.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable vertical_whitespace


extension ArrayType {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? ArrayType else { return false }
        if self.name != rhs.name { return false }
        if self.elementTypeName != rhs.elementTypeName { return false }
        return true
    }
}
extension AssociatedType {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? AssociatedType else { return false }
        if self.name != rhs.name { return false }
        if self.typeName != rhs.typeName { return false }
        return true
    }
}
extension AssociatedValue {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? AssociatedValue else { return false }
        if self.localName != rhs.localName { return false }
        if self.externalName != rhs.externalName { return false }
        if self.typeName != rhs.typeName { return false }
        if self.defaultValue != rhs.defaultValue { return false }
        if self.annotations != rhs.annotations { return false }
        return true
    }
}
extension Attribute {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Attribute else { return false }
        if self.name != rhs.name { return false }
        if self.arguments != rhs.arguments { return false }
        if self._description != rhs._description { return false }
        return true
    }
}
extension BytesRange {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? BytesRange else { return false }
        if self.offset != rhs.offset { return false }
        if self.length != rhs.length { return false }
        return true
    }
}
extension Class {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Class else { return false }
        return super.isEqual(rhs)
    }
}
extension ClosureParameter {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? ClosureParameter else { return false }
        if self.argumentLabel != rhs.argumentLabel { return false }
        if self.name != rhs.name { return false }
        if self.typeName != rhs.typeName { return false }
        if self.`inout` != rhs.`inout` { return false }
        if self.defaultValue != rhs.defaultValue { return false }
        if self.annotations != rhs.annotations { return false }
        return true
    }
}
extension ClosureType {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? ClosureType else { return false }
        if self.name != rhs.name { return false }
        if self.parameters != rhs.parameters { return false }
        if self.returnTypeName != rhs.returnTypeName { return false }
        if self.isAsync != rhs.isAsync { return false }
        if self.asyncKeyword != rhs.asyncKeyword { return false }
        if self.`throws` != rhs.`throws` { return false }
        if self.throwsOrRethrowsKeyword != rhs.throwsOrRethrowsKeyword { return false }
        return true
    }
}
extension DictionaryType {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? DictionaryType else { return false }
        if self.name != rhs.name { return false }
        if self.valueTypeName != rhs.valueTypeName { return false }
        if self.keyTypeName != rhs.keyTypeName { return false }
        return true
    }
}
extension DiffableResult {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? DiffableResult else { return false }
        if self.identifier != rhs.identifier { return false }
        return true
    }
}
extension Enum {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Enum else { return false }
        if self.cases != rhs.cases { return false }
        if self.rawTypeName != rhs.rawTypeName { return false }
        return super.isEqual(rhs)
    }
}
extension EnumCase {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? EnumCase else { return false }
        if self.name != rhs.name { return false }
        if self.rawValue != rhs.rawValue { return false }
        if self.associatedValues != rhs.associatedValues { return false }
        if self.annotations != rhs.annotations { return false }
        if self.documentation != rhs.documentation { return false }
        if self.indirect != rhs.indirect { return false }
        return true
    }
}
extension FileParserResult {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? FileParserResult else { return false }
        if self.path != rhs.path { return false }
        if self.module != rhs.module { return false }
        if self.types != rhs.types { return false }
        if self.functions != rhs.functions { return false }
        if self.typealiases != rhs.typealiases { return false }
        if self.inlineRanges != rhs.inlineRanges { return false }
        if self.inlineIndentations != rhs.inlineIndentations { return false }
        if self.modifiedDate != rhs.modifiedDate { return false }
        if self.sourceryVersion != rhs.sourceryVersion { return false }
        return true
    }
}
extension GenericRequirement {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? GenericRequirement else { return false }
        if self.leftType != rhs.leftType { return false }
        if self.rightType != rhs.rightType { return false }
        if self.relationship != rhs.relationship { return false }
        if self.relationshipSyntax != rhs.relationshipSyntax { return false }
        return true
    }
}
extension GenericType {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? GenericType else { return false }
        if self.name != rhs.name { return false }
        if self.typeParameters != rhs.typeParameters { return false }
        return true
    }
}
extension GenericTypeParameter {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? GenericTypeParameter else { return false }
        if self.typeName != rhs.typeName { return false }
        return true
    }
}
extension Import {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Import else { return false }
        if self.kind != rhs.kind { return false }
        if self.path != rhs.path { return false }
        return true
    }
}
extension Method {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Method else { return false }
        if self.name != rhs.name { return false }
        if self.selectorName != rhs.selectorName { return false }
        if self.parameters != rhs.parameters { return false }
        if self.returnTypeName != rhs.returnTypeName { return false }
        if self.isAsync != rhs.isAsync { return false }
        if self.`throws` != rhs.`throws` { return false }
        if self.`rethrows` != rhs.`rethrows` { return false }
        if self.accessLevel != rhs.accessLevel { return false }
        if self.isStatic != rhs.isStatic { return false }
        if self.isClass != rhs.isClass { return false }
        if self.isFailableInitializer != rhs.isFailableInitializer { return false }
        if self.annotations != rhs.annotations { return false }
        if self.documentation != rhs.documentation { return false }
        if self.definedInTypeName != rhs.definedInTypeName { return false }
        if self.attributes != rhs.attributes { return false }
        if self.modifiers != rhs.modifiers { return false }
        return true
    }
}
extension MethodParameter {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? MethodParameter else { return false }
        if self.argumentLabel != rhs.argumentLabel { return false }
        if self.name != rhs.name { return false }
        if self.typeName != rhs.typeName { return false }
        if self.`inout` != rhs.`inout` { return false }
        if self.isVariadic != rhs.isVariadic { return false }
        if self.defaultValue != rhs.defaultValue { return false }
        if self.annotations != rhs.annotations { return false }
        return true
    }
}
extension Modifier {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Modifier else { return false }
        if self.name != rhs.name { return false }
        if self.detail != rhs.detail { return false }
        return true
    }
}
extension Protocol {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Protocol else { return false }
        if self.associatedTypes != rhs.associatedTypes { return false }
        if self.genericRequirements != rhs.genericRequirements { return false }
        return super.isEqual(rhs)
    }
}
extension ProtocolComposition {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? ProtocolComposition else { return false }
        if self.composedTypeNames != rhs.composedTypeNames { return false }
        return super.isEqual(rhs)
    }
}
extension Struct {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Struct else { return false }
        return super.isEqual(rhs)
    }
}
extension Subscript {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Subscript else { return false }
        if self.parameters != rhs.parameters { return false }
        if self.returnTypeName != rhs.returnTypeName { return false }
        if self.readAccess != rhs.readAccess { return false }
        if self.writeAccess != rhs.writeAccess { return false }
        if self.annotations != rhs.annotations { return false }
        if self.documentation != rhs.documentation { return false }
        if self.definedInTypeName != rhs.definedInTypeName { return false }
        if self.attributes != rhs.attributes { return false }
        if self.modifiers != rhs.modifiers { return false }
        return true
    }
}
extension TemplateContext {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TemplateContext else { return false }
        if self.parserResult != rhs.parserResult { return false }
        if self.functions != rhs.functions { return false }
        if self.types != rhs.types { return false }
        if self.argument != rhs.argument { return false }
        return true
    }
}
extension TupleElement {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TupleElement else { return false }
        if self.name != rhs.name { return false }
        if self.typeName != rhs.typeName { return false }
        return true
    }
}
extension TupleType {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TupleType else { return false }
        if self.name != rhs.name { return false }
        if self.elements != rhs.elements { return false }
        return true
    }
}
extension Type {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Type else { return false }
        if self.module != rhs.module { return false }
        if self.imports != rhs.imports { return false }
        if self.typealiases != rhs.typealiases { return false }
        if self.isExtension != rhs.isExtension { return false }
        if self.accessLevel != rhs.accessLevel { return false }
        if self.isUnknownExtension != rhs.isUnknownExtension { return false }
        if self.isGeneric != rhs.isGeneric { return false }
        if self.localName != rhs.localName { return false }
        if self.rawVariables != rhs.rawVariables { return false }
        if self.rawMethods != rhs.rawMethods { return false }
        if self.rawSubscripts != rhs.rawSubscripts { return false }
        if self.annotations != rhs.annotations { return false }
        if self.documentation != rhs.documentation { return false }
        if self.inheritedTypes != rhs.inheritedTypes { return false }
        if self.inherits != rhs.inherits { return false }
        if self.containedTypes != rhs.containedTypes { return false }
        if self.parentName != rhs.parentName { return false }
        if self.attributes != rhs.attributes { return false }
        if self.modifiers != rhs.modifiers { return false }
        if self.fileName != rhs.fileName { return false }
        if self.kind != rhs.kind { return false }
        return true
    }
}
extension TypeName {
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
}
extension Typealias {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Typealias else { return false }
        if self.aliasName != rhs.aliasName { return false }
        if self.typeName != rhs.typeName { return false }
        if self.module != rhs.module { return false }
        if self.accessLevel != rhs.accessLevel { return false }
        if self.parentName != rhs.parentName { return false }
        return true
    }
}
extension Types {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Types else { return false }
        if self.types != rhs.types { return false }
        if self.typealiases != rhs.typealiases { return false }
        return true
    }
}
extension Variable {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Variable else { return false }
        if self.name != rhs.name { return false }
        if self.typeName != rhs.typeName { return false }
        if self.isComputed != rhs.isComputed { return false }
        if self.isAsync != rhs.isAsync { return false }
        if self.`throws` != rhs.`throws` { return false }
        if self.isStatic != rhs.isStatic { return false }
        if self.readAccess != rhs.readAccess { return false }
        if self.writeAccess != rhs.writeAccess { return false }
        if self.defaultValue != rhs.defaultValue { return false }
        if self.annotations != rhs.annotations { return false }
        if self.documentation != rhs.documentation { return false }
        if self.attributes != rhs.attributes { return false }
        if self.modifiers != rhs.modifiers { return false }
        if self.definedInTypeName != rhs.definedInTypeName { return false }
        return true
    }
}

// MARK: - ArrayType AutoHashable
extension ArrayType {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.elementTypeName)
        return hasher.finalize()
    }
}
// MARK: - AssociatedType AutoHashable
extension AssociatedType {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.typeName)
        return hasher.finalize()
    }
}
// MARK: - AssociatedValue AutoHashable
extension AssociatedValue {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.localName)
        hasher.combine(self.externalName)
        hasher.combine(self.typeName)
        hasher.combine(self.defaultValue)
        hasher.combine(self.annotations)
        return hasher.finalize()
    }
}
// MARK: - Attribute AutoHashable
extension Attribute {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.arguments)
        hasher.combine(self._description)
        return hasher.finalize()
    }
}
// MARK: - BytesRange AutoHashable
extension BytesRange {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.offset)
        hasher.combine(self.length)
        return hasher.finalize()
    }
}
// MARK: - Class AutoHashable
extension Class {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(super.hash)
        return hasher.finalize()
    }
}
// MARK: - ClosureParameter AutoHashable
extension ClosureParameter {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.argumentLabel)
        hasher.combine(self.name)
        hasher.combine(self.typeName)
        hasher.combine(self.`inout`)
        hasher.combine(self.defaultValue)
        hasher.combine(self.annotations)
        return hasher.finalize()
    }
}
// MARK: - ClosureType AutoHashable
extension ClosureType {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.parameters)
        hasher.combine(self.returnTypeName)
        hasher.combine(self.isAsync)
        hasher.combine(self.asyncKeyword)
        hasher.combine(self.`throws`)
        hasher.combine(self.throwsOrRethrowsKeyword)
        return hasher.finalize()
    }
}
// MARK: - DictionaryType AutoHashable
extension DictionaryType {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.valueTypeName)
        hasher.combine(self.keyTypeName)
        return hasher.finalize()
    }
}
// MARK: - DiffableResult AutoHashable
extension DiffableResult {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.identifier)
        return hasher.finalize()
    }
}
// MARK: - Enum AutoHashable
extension Enum {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.cases)
        hasher.combine(self.rawTypeName)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
}
// MARK: - EnumCase AutoHashable
extension EnumCase {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.rawValue)
        hasher.combine(self.associatedValues)
        hasher.combine(self.annotations)
        hasher.combine(self.documentation)
        hasher.combine(self.indirect)
        return hasher.finalize()
    }
}
// MARK: - FileParserResult AutoHashable
extension FileParserResult {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.path)
        hasher.combine(self.module)
        hasher.combine(self.types)
        hasher.combine(self.functions)
        hasher.combine(self.typealiases)
        hasher.combine(self.inlineRanges)
        hasher.combine(self.inlineIndentations)
        hasher.combine(self.modifiedDate)
        hasher.combine(self.sourceryVersion)
        return hasher.finalize()
    }
}
// MARK: - GenericRequirement AutoHashable
extension GenericRequirement {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.leftType)
        hasher.combine(self.rightType)
        hasher.combine(self.relationship)
        hasher.combine(self.relationshipSyntax)
        return hasher.finalize()
    }
}
// MARK: - GenericType AutoHashable
extension GenericType {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.typeParameters)
        return hasher.finalize()
    }
}
// MARK: - GenericTypeParameter AutoHashable
extension GenericTypeParameter {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.typeName)
        return hasher.finalize()
    }
}
// MARK: - Import AutoHashable
extension Import {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.kind)
        hasher.combine(self.path)
        return hasher.finalize()
    }
}
// MARK: - Method AutoHashable
extension Method {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.selectorName)
        hasher.combine(self.parameters)
        hasher.combine(self.returnTypeName)
        hasher.combine(self.isAsync)
        hasher.combine(self.`throws`)
        hasher.combine(self.`rethrows`)
        hasher.combine(self.accessLevel)
        hasher.combine(self.isStatic)
        hasher.combine(self.isClass)
        hasher.combine(self.isFailableInitializer)
        hasher.combine(self.annotations)
        hasher.combine(self.documentation)
        hasher.combine(self.definedInTypeName)
        hasher.combine(self.attributes)
        hasher.combine(self.modifiers)
        return hasher.finalize()
    }
}
// MARK: - MethodParameter AutoHashable
extension MethodParameter {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.argumentLabel)
        hasher.combine(self.name)
        hasher.combine(self.typeName)
        hasher.combine(self.`inout`)
        hasher.combine(self.isVariadic)
        hasher.combine(self.defaultValue)
        hasher.combine(self.annotations)
        return hasher.finalize()
    }
}
// MARK: - Modifier AutoHashable
extension Modifier {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.detail)
        return hasher.finalize()
    }
}
// MARK: - Protocol AutoHashable
extension Protocol {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.associatedTypes)
        hasher.combine(self.genericRequirements)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
}
// MARK: - ProtocolComposition AutoHashable
extension ProtocolComposition {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.composedTypeNames)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
}
// MARK: - Struct AutoHashable
extension Struct {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(super.hash)
        return hasher.finalize()
    }
}
// MARK: - Subscript AutoHashable
extension Subscript {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.parameters)
        hasher.combine(self.returnTypeName)
        hasher.combine(self.readAccess)
        hasher.combine(self.writeAccess)
        hasher.combine(self.annotations)
        hasher.combine(self.documentation)
        hasher.combine(self.definedInTypeName)
        hasher.combine(self.attributes)
        hasher.combine(self.modifiers)
        return hasher.finalize()
    }
}
// MARK: - TemplateContext AutoHashable
extension TemplateContext {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.parserResult)
        hasher.combine(self.functions)
        hasher.combine(self.types)
        hasher.combine(self.argument)
        return hasher.finalize()
    }
}
// MARK: - TupleElement AutoHashable
extension TupleElement {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.typeName)
        return hasher.finalize()
    }
}
// MARK: - TupleType AutoHashable
extension TupleType {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.elements)
        return hasher.finalize()
    }
}
// MARK: - Type AutoHashable
extension Type {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.module)
        hasher.combine(self.imports)
        hasher.combine(self.typealiases)
        hasher.combine(self.isExtension)
        hasher.combine(self.accessLevel)
        hasher.combine(self.isUnknownExtension)
        hasher.combine(self.isGeneric)
        hasher.combine(self.localName)
        hasher.combine(self.rawVariables)
        hasher.combine(self.rawMethods)
        hasher.combine(self.rawSubscripts)
        hasher.combine(self.annotations)
        hasher.combine(self.documentation)
        hasher.combine(self.inheritedTypes)
        hasher.combine(self.inherits)
        hasher.combine(self.containedTypes)
        hasher.combine(self.parentName)
        hasher.combine(self.attributes)
        hasher.combine(self.modifiers)
        hasher.combine(self.fileName)
        hasher.combine(kind)
        return hasher.finalize()
    }
}
// MARK: - TypeName AutoHashable
extension TypeName {
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
}
// MARK: - Typealias AutoHashable
extension Typealias {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.aliasName)
        hasher.combine(self.typeName)
        hasher.combine(self.module)
        hasher.combine(self.accessLevel)
        hasher.combine(self.parentName)
        return hasher.finalize()
    }
}
// MARK: - Types AutoHashable
extension Types {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.types)
        hasher.combine(self.typealiases)
        return hasher.finalize()
    }
}
// MARK: - Variable AutoHashable
extension Variable {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.typeName)
        hasher.combine(self.isComputed)
        hasher.combine(self.isAsync)
        hasher.combine(self.`throws`)
        hasher.combine(self.isStatic)
        hasher.combine(self.readAccess)
        hasher.combine(self.writeAccess)
        hasher.combine(self.defaultValue)
        hasher.combine(self.annotations)
        hasher.combine(self.documentation)
        hasher.combine(self.attributes)
        hasher.combine(self.modifiers)
        hasher.combine(self.definedInTypeName)
        return hasher.finalize()
    }
}

"""),
    .init(name: "Extensions.swift", content:
"""
import Foundation

public extension StringProtocol {
    /// Trimms leading and trailing whitespaces and newlines
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

public extension String {

    /// Returns nil if string is empty
    var nilIfEmpty: String? {
        if isEmpty {
            return nil
        }

        return self
    }

    /// Returns nil if string is empty or contains `_` character
    var nilIfNotValidParameterName: String? {
        if isEmpty {
            return nil
        }

        if self == "_" {
            return nil
        }

        return self
    }

    /// :nodoc:
    /// - Parameter substring: Instance of a substring
    /// - Returns: Returns number of times a substring appears in self
    func countInstances(of substring: String) -> Int {
        guard !substring.isEmpty else { return 0 }
        var count = 0
        var searchRange: Range<String.Index>?
        while let foundRange = range(of: substring, options: [], range: searchRange) {
            count += 1
            searchRange = Range(uncheckedBounds: (lower: foundRange.upperBound, upper: endIndex))
        }
        return count
    }

    /// :nodoc:
    /// Removes leading and trailing whitespace from str. Returns false if str was not altered.
    @discardableResult
    mutating func strip() -> Bool {
        let strippedString = stripped()
        guard strippedString != self else { return false }
        self = strippedString
        return true
    }

    /// :nodoc:
    /// Returns a copy of str with leading and trailing whitespace removed.
    func stripped() -> String {
        return String(self.trimmingCharacters(in: .whitespaces))
    }

    /// :nodoc:
    @discardableResult
    mutating func trimPrefix(_ prefix: String) -> Bool {
        guard hasPrefix(prefix) else { return false }
        self = String(self.suffix(self.count - prefix.count))
        return true
    }

    /// :nodoc:
    func trimmingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(self.suffix(self.count - prefix.count))
    }

    /// :nodoc:
    @discardableResult
    mutating func trimSuffix(_ suffix: String) -> Bool {
        guard hasSuffix(suffix) else { return false }
        self = String(self.prefix(self.count - suffix.count))
        return true
    }

    /// :nodoc:
    func trimmingSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }
        return String(self.prefix(self.count - suffix.count))
    }

    /// :nodoc:
    func dropFirstAndLast(_ n: Int = 1) -> String {
        return drop(first: n, last: n)
    }

    /// :nodoc:
    func drop(first: Int, last: Int) -> String {
        return String(self.dropFirst(first).dropLast(last))
    }

    /// :nodoc:
    /// Wraps brackets if needed to make a valid type name
    func bracketsBalancing() -> String {
        if hasPrefix("(") && hasSuffix(")") {
            let unwrapped = dropFirstAndLast()
            return unwrapped.commaSeparated().count == 1 ? unwrapped.bracketsBalancing() : self
        } else {
            let wrapped = "(\\(self))"
            return wrapped.isValidTupleName() || !isBracketsBalanced() ? wrapped : self
        }
    }

    /// :nodoc:
    /// Returns true if given string can represent a valid tuple type name
    func isValidTupleName() -> Bool {
        guard hasPrefix("(") && hasSuffix(")") else { return false }
        let trimmedBracketsName = dropFirstAndLast()
        return trimmedBracketsName.isBracketsBalanced() && trimmedBracketsName.commaSeparated().count > 1
    }

    /// :nodoc:
    func isValidArrayName() -> Bool {
        if hasPrefix("Array<") { return true }
        if hasPrefix("[") && hasSuffix("]") {
            return dropFirstAndLast().colonSeparated().count == 1
        }
        return false
    }

    /// :nodoc:
    func isValidDictionaryName() -> Bool {
        if hasPrefix("Dictionary<") { return true }
        if hasPrefix("[") && contains(":") && hasSuffix("]") {
            return dropFirstAndLast().colonSeparated().count == 2
        }
        return false
    }

    /// :nodoc:
    func isValidClosureName() -> Bool {
        return components(separatedBy: "->", excludingDelimiterBetween: (["(", "<"], [")", ">"])).count > 1
    }

    /// :nodoc:
    /// Returns true if all opening brackets are balanced with closed brackets.
    func isBracketsBalanced() -> Bool {
        var bracketsCount: Int = 0
        for char in self {
            if char == "(" { bracketsCount += 1 } else if char == ")" { bracketsCount -= 1 }
            if bracketsCount < 0 { return false }
        }
        return bracketsCount == 0
    }

    /// :nodoc:
    /// Returns components separated with a comma respecting nested types
    func commaSeparated() -> [String] {
        return components(separatedBy: ",", excludingDelimiterBetween: ("<[({", "})]>"))
    }

    /// :nodoc:
    /// Returns components separated with colon respecting nested types
    func colonSeparated() -> [String] {
        return components(separatedBy: ":", excludingDelimiterBetween: ("<[({", "})]>"))
    }

    /// :nodoc:
    /// Returns components separated with semicolon respecting nested contexts
    func semicolonSeparated() -> [String] {
        return components(separatedBy: ";", excludingDelimiterBetween: ("{", "}"))
    }

    /// :nodoc:
    func components(separatedBy delimiter: String, excludingDelimiterBetween between: (open: String, close: String)) -> [String] {
        return self.components(separatedBy: delimiter, excludingDelimiterBetween: (between.open.map { String($0) }, between.close.map { String($0) }))
    }

    /// :nodoc:
    func components(separatedBy delimiter: String, excludingDelimiterBetween between: (open: [String], close: [String])) -> [String] {
        var boundingCharactersCount: Int = 0
        var quotesCount: Int = 0
        var item = ""
        var items = [String]()

        var i = self.startIndex
        while i < self.endIndex {
            var offset = 1
            defer {
                i = self.index(i, offsetBy: offset)
            }
            let currentlyScanned = self[i..<(self.index(i, offsetBy: delimiter.count, limitedBy: self.endIndex) ?? self.endIndex)]
            if let openString = between.open.first(where: { String(self[i...]).starts(with: $0) }) {
                if !(boundingCharactersCount == 0 && String(self[i]) == delimiter) {
                    boundingCharactersCount += 1
                }
                offset = openString.count
            } else if let closeString = between.close.first(where: { String(self[i...]).starts(with: $0) }) {
                // do not count `->`
                if !(self[i] == ">" && item.last == "-") {
                    boundingCharactersCount = max(0, boundingCharactersCount - 1)
                }
                offset = closeString.count
            }
            if self[i] == "\\"" {
                quotesCount += 1
            }

            if currentlyScanned == delimiter && boundingCharactersCount == 0 && quotesCount % 2 == 0 {
                items.append(item)
                item = ""
                i = self.index(i, offsetBy: delimiter.count - 1)
            } else {
                item += self[i..<self.index(i, offsetBy: offset)]
            }
        }
        items.append(item)
        return items
    }
}

public extension NSString {
    /// :nodoc:
    var entireRange: NSRange {
        return NSRange(location: 0, length: self.length)
    }
}

"""),
    .init(name: "FileParserResult.swift", content:
"""
//
//  FileParserResult.swift
//  Sourcery
//
//  Created by Krzysztof Zablocki on 11/01/2017.
//  Copyright © 2017 Pixle. All rights reserved.
//

import Foundation

// sourcery: skipJSExport
/// :nodoc:
@objcMembers public final class FileParserResult: NSObject, SourceryModel {
    public let path: String?
    public let module: String?
    public var types = [Type]() {
        didSet {
            types.forEach { type in
                guard type.module == nil, type.kind != "extensions" else { return }
                type.module = module
            }
        }
    }
    public var functions = [SourceryMethod]()
    public var typealiases = [Typealias]()
    public var inlineRanges = [String: NSRange]()
    public var inlineIndentations = [String: String]()

    public var modifiedDate: Date
    public var sourceryVersion: String

    var isEmpty: Bool {
        types.isEmpty && functions.isEmpty && typealiases.isEmpty && inlineRanges.isEmpty && inlineIndentations.isEmpty
    }

    public init(path: String?, module: String?, types: [Type], functions: [SourceryMethod], typealiases: [Typealias] = [], inlineRanges: [String: NSRange] = [:], inlineIndentations: [String: String] = [:], modifiedDate: Date = Date(), sourceryVersion: String = "") {
        self.path = path
        self.module = module
        self.types = types
        self.functions = functions
        self.typealiases = typealiases
        self.inlineRanges = inlineRanges
        self.inlineIndentations = inlineIndentations
        self.modifiedDate = modifiedDate
        self.sourceryVersion = sourceryVersion

        types.forEach { type in type.module = module }
    }

// sourcery:inline:FileParserResult.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            self.path = aDecoder.decode(forKey: "path")
            self.module = aDecoder.decode(forKey: "module")
            guard let types: [Type] = aDecoder.decode(forKey: "types") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["types"])); fatalError() }; self.types = types
            guard let functions: [SourceryMethod] = aDecoder.decode(forKey: "functions") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["functions"])); fatalError() }; self.functions = functions
            guard let typealiases: [Typealias] = aDecoder.decode(forKey: "typealiases") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typealiases"])); fatalError() }; self.typealiases = typealiases
            guard let inlineRanges: [String: NSRange] = aDecoder.decode(forKey: "inlineRanges") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["inlineRanges"])); fatalError() }; self.inlineRanges = inlineRanges
            guard let inlineIndentations: [String: String] = aDecoder.decode(forKey: "inlineIndentations") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["inlineIndentations"])); fatalError() }; self.inlineIndentations = inlineIndentations
            guard let modifiedDate: Date = aDecoder.decode(forKey: "modifiedDate") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["modifiedDate"])); fatalError() }; self.modifiedDate = modifiedDate
            guard let sourceryVersion: String = aDecoder.decode(forKey: "sourceryVersion") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["sourceryVersion"])); fatalError() }; self.sourceryVersion = sourceryVersion
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.path, forKey: "path")
            aCoder.encode(self.module, forKey: "module")
            aCoder.encode(self.types, forKey: "types")
            aCoder.encode(self.functions, forKey: "functions")
            aCoder.encode(self.typealiases, forKey: "typealiases")
            aCoder.encode(self.inlineRanges, forKey: "inlineRanges")
            aCoder.encode(self.inlineIndentations, forKey: "inlineIndentations")
            aCoder.encode(self.modifiedDate, forKey: "modifiedDate")
            aCoder.encode(self.sourceryVersion, forKey: "sourceryVersion")
        }
// sourcery:end
}

"""),
    .init(name: "Generic.swift", content:
"""
import Foundation

/// Descibes Swift generic type
@objcMembers public final class GenericType: NSObject, SourceryModelWithoutDescription {
    /// The name of the base type, i.e. `Array` for `Array<Int>`
    public var name: String

    /// This generic type parameters
    public let typeParameters: [GenericTypeParameter]

    /// :nodoc:
    public init(name: String, typeParameters: [GenericTypeParameter] = []) {
        self.name = name
        self.typeParameters = typeParameters
    }

    public var asSource: String {
        let arguments = typeParameters
          .map({ $0.typeName.asSource })
          .joined(separator: ", ")
        return "\\(name)<\\(arguments)>"
    }

    public override var description: String {
        asSource
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

/// Descibes Swift generic type parameter
@objcMembers public final class GenericTypeParameter: NSObject, SourceryModel {

    /// Generic parameter type name
    public var typeName: TypeName

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

"""),
    .init(name: "GenericRequirement.swift", content:
"""
import Foundation

/// modifier can be thing like `private`, `class`, `nonmutating`
/// if a declaration has modifier like `private(set)` it's name will be `private` and detail will be `set`
@objcMembers public class GenericRequirement: NSObject, SourceryModel {

    public enum Relationship: String {
        case equals
        case conformsTo

        var syntax: String {
            switch self {
            case .equals:
                return "=="
            case .conformsTo:
                return ":"
            }
        }
    }

    public var leftType: AssociatedType
    public let rightType: GenericTypeParameter

    /// relationship name
    public let relationship: String

    /// Syntax e.g. `==` or `:`
    public let relationshipSyntax: String

    public init(leftType: AssociatedType, rightType: GenericTypeParameter, relationship: Relationship) {
        self.leftType = leftType
        self.rightType = rightType
        self.relationship = relationship.rawValue
        self.relationshipSyntax = relationship.syntax
    }

    // sourcery:inline:GenericRequirement.AutoCoding

            /// :nodoc:
            required public init?(coder aDecoder: NSCoder) {
                guard let leftType: AssociatedType = aDecoder.decode(forKey: "leftType") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["leftType"])); fatalError() }; self.leftType = leftType
                guard let rightType: GenericTypeParameter = aDecoder.decode(forKey: "rightType") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["rightType"])); fatalError() }; self.rightType = rightType
                guard let relationship: String = aDecoder.decode(forKey: "relationship") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["relationship"])); fatalError() }; self.relationship = relationship
                guard let relationshipSyntax: String = aDecoder.decode(forKey: "relationshipSyntax") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["relationshipSyntax"])); fatalError() }; self.relationshipSyntax = relationshipSyntax
            }

            /// :nodoc:
            public func encode(with aCoder: NSCoder) {
                aCoder.encode(self.leftType, forKey: "leftType")
                aCoder.encode(self.rightType, forKey: "rightType")
                aCoder.encode(self.relationship, forKey: "relationship")
                aCoder.encode(self.relationshipSyntax, forKey: "relationshipSyntax")
            }
    // sourcery:end
}

"""),
    .init(name: "Import.swift", content:
"""
import Foundation

/// Defines import type
@objcMembers public class Import: NSObject, SourceryModelWithoutDescription {
    /// Import kind, e.g. class, struct in `import class Module.ClassName`
    public var kind: String?

    /// Import path
    public var path: String

    /// :nodoc:
    public init(path: String, kind: String? = nil) {
        self.path = path
        self.kind = kind
    }

    /// Full import value e.g. `import struct Module.StructName`
    public override var description: String {
        if let kind = kind {
            return "\\(kind) \\(path)"
        }

        return path
    }

    /// Returns module name from a import, e.g. if you had `import struct Module.Submodule.Struct` it will return `Module.Submodule`
    public var moduleName: String {
        if kind != nil {
            if let idx = path.lastIndex(of: ".") {
                return String(path[..<idx])
            } else {
                return path
            }
        } else {
            return path
        }
    }

// sourcery:inline:Import.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            self.kind = aDecoder.decode(forKey: "kind")
            guard let path: String = aDecoder.decode(forKey: "path") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["path"])); fatalError() }; self.path = path
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.kind, forKey: "kind")
            aCoder.encode(self.path, forKey: "path")
        }

// sourcery:end
}

"""),
    .init(name: "JSExport.generated.swift", content:
"""
// Generated using Sourcery 1.8.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable vertical_whitespace trailing_newline

import JavaScriptCore

@objc protocol ArrayTypeAutoJSExport: JSExport {
    var name: String { get }
    var elementTypeName: TypeName { get }
    var elementType: Type? { get }
    var asGeneric: GenericType { get }
    var asSource: String { get }
}

extension ArrayType: ArrayTypeAutoJSExport {}

@objc protocol AssociatedTypeAutoJSExport: JSExport {
    var name: String { get }
    var typeName: TypeName? { get }
    var type: Type? { get }
}

extension AssociatedType: AssociatedTypeAutoJSExport {}

@objc protocol AssociatedValueAutoJSExport: JSExport {
    var localName: String? { get }
    var externalName: String? { get }
    var typeName: TypeName { get }
    var type: Type? { get }
    var defaultValue: String? { get }
    var annotations: Annotations { get }
    var isOptional: Bool { get }
    var isImplicitlyUnwrappedOptional: Bool { get }
    var unwrappedTypeName: String { get }
}

extension AssociatedValue: AssociatedValueAutoJSExport {}

@objc protocol AttributeAutoJSExport: JSExport {
    var name: String { get }
    var arguments: [String: NSObject] { get }
    var asSource: String { get }
    var description: String { get }
}

extension Attribute: AttributeAutoJSExport {}

@objc protocol BytesRangeAutoJSExport: JSExport {
    var offset: Int64 { get }
    var length: Int64 { get }
}

extension BytesRange: BytesRangeAutoJSExport {}

@objc protocol ClassAutoJSExport: JSExport {
    var kind: String { get }
    var isFinal: Bool { get }
    var module: String? { get }
    var imports: [Import] { get }
    var allImports: [Import] { get }
    var accessLevel: String { get }
    var name: String { get }
    var isUnknownExtension: Bool { get }
    var globalName: String { get }
    var isGeneric: Bool { get }
    var localName: String { get }
    var variables: [Variable] { get }
    var rawVariables: [Variable] { get }
    var allVariables: [Variable] { get }
    var methods: [Method] { get }
    var rawMethods: [Method] { get }
    var allMethods: [Method] { get }
    var subscripts: [Subscript] { get }
    var rawSubscripts: [Subscript] { get }
    var allSubscripts: [Subscript] { get }
    var initializers: [Method] { get }
    var annotations: Annotations { get }
    var documentation: Documentation { get }
    var staticVariables: [Variable] { get }
    var staticMethods: [Method] { get }
    var classMethods: [Method] { get }
    var instanceVariables: [Variable] { get }
    var instanceMethods: [Method] { get }
    var computedVariables: [Variable] { get }
    var storedVariables: [Variable] { get }
    var inheritedTypes: [String] { get }
    var based: [String: String] { get }
    var basedTypes: [String: Type] { get }
    var inherits: [String: Type] { get }
    var implements: [String: Type] { get }
    var containedTypes: [Type] { get }
    var containedType: [String: Type] { get }
    var parentName: String? { get }
    var parent: Type? { get }
    var supertype: Type? { get }
    var attributes: AttributeList { get }
    var modifiers: [SourceryModifier] { get }
    var fileName: String? { get }
}

extension Class: ClassAutoJSExport {}

@objc protocol ClosureParameterAutoJSExport: JSExport {
    var argumentLabel: String? { get }
    var name: String? { get }
    var typeName: TypeName { get }
    var `inout`: Bool { get }
    var type: Type? { get }
    var typeAttributes: AttributeList { get }
    var defaultValue: String? { get }
    var annotations: Annotations { get }
    var asSource: String { get }
    var isOptional: Bool { get }
    var isImplicitlyUnwrappedOptional: Bool { get }
    var unwrappedTypeName: String { get }
}

extension ClosureParameter: ClosureParameterAutoJSExport {}

@objc protocol ClosureTypeAutoJSExport: JSExport {
    var name: String { get }
    var parameters: [ClosureParameter] { get }
    var returnTypeName: TypeName { get }
    var actualReturnTypeName: TypeName { get }
    var returnType: Type? { get }
    var isOptionalReturnType: Bool { get }
    var isImplicitlyUnwrappedOptionalReturnType: Bool { get }
    var unwrappedReturnTypeName: String { get }
    var isAsync: Bool { get }
    var asyncKeyword: String? { get }
    var `throws`: Bool { get }
    var throwsOrRethrowsKeyword: String? { get }
    var asSource: String { get }
}

extension ClosureType: ClosureTypeAutoJSExport {}

@objc protocol DictionaryTypeAutoJSExport: JSExport {
    var name: String { get }
    var valueTypeName: TypeName { get }
    var valueType: Type? { get }
    var keyTypeName: TypeName { get }
    var keyType: Type? { get }
    var asGeneric: GenericType { get }
    var asSource: String { get }
}

extension DictionaryType: DictionaryTypeAutoJSExport {}

@objc protocol EnumAutoJSExport: JSExport {
    var kind: String { get }
    var cases: [EnumCase] { get }
    var rawTypeName: TypeName? { get }
    var hasRawType: Bool { get }
    var rawType: Type? { get }
    var based: [String: String] { get }
    var hasAssociatedValues: Bool { get }
    var module: String? { get }
    var imports: [Import] { get }
    var allImports: [Import] { get }
    var accessLevel: String { get }
    var name: String { get }
    var isUnknownExtension: Bool { get }
    var globalName: String { get }
    var isGeneric: Bool { get }
    var localName: String { get }
    var variables: [Variable] { get }
    var rawVariables: [Variable] { get }
    var allVariables: [Variable] { get }
    var methods: [Method] { get }
    var rawMethods: [Method] { get }
    var allMethods: [Method] { get }
    var subscripts: [Subscript] { get }
    var rawSubscripts: [Subscript] { get }
    var allSubscripts: [Subscript] { get }
    var initializers: [Method] { get }
    var annotations: Annotations { get }
    var documentation: Documentation { get }
    var staticVariables: [Variable] { get }
    var staticMethods: [Method] { get }
    var classMethods: [Method] { get }
    var instanceVariables: [Variable] { get }
    var instanceMethods: [Method] { get }
    var computedVariables: [Variable] { get }
    var storedVariables: [Variable] { get }
    var inheritedTypes: [String] { get }
    var basedTypes: [String: Type] { get }
    var inherits: [String: Type] { get }
    var implements: [String: Type] { get }
    var containedTypes: [Type] { get }
    var containedType: [String: Type] { get }
    var parentName: String? { get }
    var parent: Type? { get }
    var supertype: Type? { get }
    var attributes: AttributeList { get }
    var modifiers: [SourceryModifier] { get }
    var fileName: String? { get }
}

extension Enum: EnumAutoJSExport {}

@objc protocol EnumCaseAutoJSExport: JSExport {
    var name: String { get }
    var rawValue: String? { get }
    var associatedValues: [AssociatedValue] { get }
    var annotations: Annotations { get }
    var documentation: Documentation { get }
    var indirect: Bool { get }
    var hasAssociatedValue: Bool { get }
}

extension EnumCase: EnumCaseAutoJSExport {}


@objc protocol GenericRequirementAutoJSExport: JSExport {
    var leftType: AssociatedType { get }
    var rightType: GenericTypeParameter { get }
    var relationship: String { get }
    var relationshipSyntax: String { get }
}

extension GenericRequirement: GenericRequirementAutoJSExport {}

@objc protocol GenericTypeAutoJSExport: JSExport {
    var name: String { get }
    var typeParameters: [GenericTypeParameter] { get }
    var asSource: String { get }
    var description: String { get }
}

extension GenericType: GenericTypeAutoJSExport {}

@objc protocol GenericTypeParameterAutoJSExport: JSExport {
    var typeName: TypeName { get }
    var type: Type? { get }
}

extension GenericTypeParameter: GenericTypeParameterAutoJSExport {}

@objc protocol ImportAutoJSExport: JSExport {
    var kind: String? { get }
    var path: String { get }
    var description: String { get }
    var moduleName: String { get }
}

extension Import: ImportAutoJSExport {}

@objc protocol MethodAutoJSExport: JSExport {
    var name: String { get }
    var selectorName: String { get }
    var shortName: String { get }
    var callName: String { get }
    var parameters: [MethodParameter] { get }
    var returnTypeName: TypeName { get }
    var actualReturnTypeName: TypeName { get }
    var returnType: Type? { get }
    var isOptionalReturnType: Bool { get }
    var isImplicitlyUnwrappedOptionalReturnType: Bool { get }
    var unwrappedReturnTypeName: String { get }
    var isAsync: Bool { get }
    var `throws`: Bool { get }
    var `rethrows`: Bool { get }
    var accessLevel: String { get }
    var isStatic: Bool { get }
    var isClass: Bool { get }
    var isInitializer: Bool { get }
    var isDeinitializer: Bool { get }
    var isFailableInitializer: Bool { get }
    var isConvenienceInitializer: Bool { get }
    var isRequired: Bool { get }
    var isFinal: Bool { get }
    var isMutating: Bool { get }
    var isGeneric: Bool { get }
    var isOptional: Bool { get }
    var annotations: Annotations { get }
    var documentation: Documentation { get }
    var definedInTypeName: TypeName? { get }
    var actualDefinedInTypeName: TypeName? { get }
    var definedInType: Type? { get }
    var attributes: AttributeList { get }
    var modifiers: [SourceryModifier] { get }
}

extension Method: MethodAutoJSExport {}

@objc protocol MethodParameterAutoJSExport: JSExport {
    var argumentLabel: String? { get }
    var name: String { get }
    var typeName: TypeName { get }
    var `inout`: Bool { get }
    var isVariadic: Bool { get }
    var type: Type? { get }
    var typeAttributes: AttributeList { get }
    var defaultValue: String? { get }
    var annotations: Annotations { get }
    var asSource: String { get }
    var isOptional: Bool { get }
    var isImplicitlyUnwrappedOptional: Bool { get }
    var unwrappedTypeName: String { get }
}

extension MethodParameter: MethodParameterAutoJSExport {}

@objc protocol ModifierAutoJSExport: JSExport {
    var name: String { get }
    var detail: String? { get }
    var asSource: String { get }
}

extension Modifier: ModifierAutoJSExport {}

@objc protocol ProtocolAutoJSExport: JSExport {
    var kind: String { get }
    var associatedTypes: [String: AssociatedType] { get }
    var genericRequirements: [GenericRequirement] { get }
    var module: String? { get }
    var imports: [Import] { get }
    var allImports: [Import] { get }
    var accessLevel: String { get }
    var name: String { get }
    var isUnknownExtension: Bool { get }
    var globalName: String { get }
    var isGeneric: Bool { get }
    var localName: String { get }
    var variables: [Variable] { get }
    var rawVariables: [Variable] { get }
    var allVariables: [Variable] { get }
    var methods: [Method] { get }
    var rawMethods: [Method] { get }
    var allMethods: [Method] { get }
    var subscripts: [Subscript] { get }
    var rawSubscripts: [Subscript] { get }
    var allSubscripts: [Subscript] { get }
    var initializers: [Method] { get }
    var annotations: Annotations { get }
    var documentation: Documentation { get }
    var staticVariables: [Variable] { get }
    var staticMethods: [Method] { get }
    var classMethods: [Method] { get }
    var instanceVariables: [Variable] { get }
    var instanceMethods: [Method] { get }
    var computedVariables: [Variable] { get }
    var storedVariables: [Variable] { get }
    var inheritedTypes: [String] { get }
    var based: [String: String] { get }
    var basedTypes: [String: Type] { get }
    var inherits: [String: Type] { get }
    var implements: [String: Type] { get }
    var containedTypes: [Type] { get }
    var containedType: [String: Type] { get }
    var parentName: String? { get }
    var parent: Type? { get }
    var supertype: Type? { get }
    var attributes: AttributeList { get }
    var modifiers: [SourceryModifier] { get }
    var fileName: String? { get }
}

extension Protocol: ProtocolAutoJSExport {}




@objc protocol StructAutoJSExport: JSExport {
    var kind: String { get }
    var module: String? { get }
    var imports: [Import] { get }
    var allImports: [Import] { get }
    var accessLevel: String { get }
    var name: String { get }
    var isUnknownExtension: Bool { get }
    var globalName: String { get }
    var isGeneric: Bool { get }
    var localName: String { get }
    var variables: [Variable] { get }
    var rawVariables: [Variable] { get }
    var allVariables: [Variable] { get }
    var methods: [Method] { get }
    var rawMethods: [Method] { get }
    var allMethods: [Method] { get }
    var subscripts: [Subscript] { get }
    var rawSubscripts: [Subscript] { get }
    var allSubscripts: [Subscript] { get }
    var initializers: [Method] { get }
    var annotations: Annotations { get }
    var documentation: Documentation { get }
    var staticVariables: [Variable] { get }
    var staticMethods: [Method] { get }
    var classMethods: [Method] { get }
    var instanceVariables: [Variable] { get }
    var instanceMethods: [Method] { get }
    var computedVariables: [Variable] { get }
    var storedVariables: [Variable] { get }
    var inheritedTypes: [String] { get }
    var based: [String: String] { get }
    var basedTypes: [String: Type] { get }
    var inherits: [String: Type] { get }
    var implements: [String: Type] { get }
    var containedTypes: [Type] { get }
    var containedType: [String: Type] { get }
    var parentName: String? { get }
    var parent: Type? { get }
    var supertype: Type? { get }
    var attributes: AttributeList { get }
    var modifiers: [SourceryModifier] { get }
    var fileName: String? { get }
}

extension Struct: StructAutoJSExport {}

@objc protocol SubscriptAutoJSExport: JSExport {
    var parameters: [MethodParameter] { get }
    var returnTypeName: TypeName { get }
    var actualReturnTypeName: TypeName { get }
    var returnType: Type? { get }
    var isOptionalReturnType: Bool { get }
    var isImplicitlyUnwrappedOptionalReturnType: Bool { get }
    var unwrappedReturnTypeName: String { get }
    var isFinal: Bool { get }
    var readAccess: String { get }
    var writeAccess: String { get }
    var isMutable: Bool { get }
    var annotations: Annotations { get }
    var documentation: Documentation { get }
    var definedInTypeName: TypeName? { get }
    var actualDefinedInTypeName: TypeName? { get }
    var definedInType: Type? { get }
    var attributes: AttributeList { get }
    var modifiers: [SourceryModifier] { get }
}

extension Subscript: SubscriptAutoJSExport {}

@objc protocol TemplateContextAutoJSExport: JSExport {
    var functions: [SourceryMethod] { get }
    var types: Types { get }
    var argument: [String: NSObject] { get }
    var type: [String: Type] { get }
    var stencilContext: [String: Any] { get }
    var jsContext: [String: Any] { get }
}

extension TemplateContext: TemplateContextAutoJSExport {}

@objc protocol TupleElementAutoJSExport: JSExport {
    var name: String? { get }
    var typeName: TypeName { get }
    var type: Type? { get }
    var asSource: String { get }
    var isOptional: Bool { get }
    var isImplicitlyUnwrappedOptional: Bool { get }
    var unwrappedTypeName: String { get }
}

extension TupleElement: TupleElementAutoJSExport {}

@objc protocol TupleTypeAutoJSExport: JSExport {
    var name: String { get }
    var elements: [TupleElement] { get }
}

extension TupleType: TupleTypeAutoJSExport {}

@objc protocol TypeAutoJSExport: JSExport {
    var module: String? { get }
    var imports: [Import] { get }
    var allImports: [Import] { get }
    var kind: String { get }
    var accessLevel: String { get }
    var name: String { get }
    var isUnknownExtension: Bool { get }
    var globalName: String { get }
    var isGeneric: Bool { get }
    var localName: String { get }
    var variables: [Variable] { get }
    var rawVariables: [Variable] { get }
    var allVariables: [Variable] { get }
    var methods: [Method] { get }
    var rawMethods: [Method] { get }
    var allMethods: [Method] { get }
    var subscripts: [Subscript] { get }
    var rawSubscripts: [Subscript] { get }
    var allSubscripts: [Subscript] { get }
    var initializers: [Method] { get }
    var annotations: Annotations { get }
    var documentation: Documentation { get }
    var staticVariables: [Variable] { get }
    var staticMethods: [Method] { get }
    var classMethods: [Method] { get }
    var instanceVariables: [Variable] { get }
    var instanceMethods: [Method] { get }
    var computedVariables: [Variable] { get }
    var storedVariables: [Variable] { get }
    var inheritedTypes: [String] { get }
    var based: [String: String] { get }
    var basedTypes: [String: Type] { get }
    var inherits: [String: Type] { get }
    var implements: [String: Type] { get }
    var containedTypes: [Type] { get }
    var containedType: [String: Type] { get }
    var parentName: String? { get }
    var parent: Type? { get }
    var supertype: Type? { get }
    var attributes: AttributeList { get }
    var modifiers: [SourceryModifier] { get }
    var fileName: String? { get }
}

extension Type: TypeAutoJSExport {}

@objc protocol TypeNameAutoJSExport: JSExport {
    var name: String { get }
    var generic: GenericType? { get }
    var isGeneric: Bool { get }
    var isProtocolComposition: Bool { get }
    var actualTypeName: TypeName? { get }
    var attributes: AttributeList { get }
    var modifiers: [SourceryModifier] { get }
    var isOptional: Bool { get }
    var isImplicitlyUnwrappedOptional: Bool { get }
    var unwrappedTypeName: String { get }
    var isVoid: Bool { get }
    var isTuple: Bool { get }
    var tuple: TupleType? { get }
    var isArray: Bool { get }
    var array: ArrayType? { get }
    var isDictionary: Bool { get }
    var dictionary: DictionaryType? { get }
    var isClosure: Bool { get }
    var closure: ClosureType? { get }
    var asSource: String { get }
    var description: String { get }
    var debugDescription: String { get }
}

extension TypeName: TypeNameAutoJSExport {}



@objc protocol TypesCollectionAutoJSExport: JSExport {
}

extension TypesCollection: TypesCollectionAutoJSExport {}

@objc protocol VariableAutoJSExport: JSExport {
    var name: String { get }
    var typeName: TypeName { get }
    var type: Type? { get }
    var isComputed: Bool { get }
    var isAsync: Bool { get }
    var `throws`: Bool { get }
    var isStatic: Bool { get }
    var readAccess: String { get }
    var writeAccess: String { get }
    var isMutable: Bool { get }
    var defaultValue: String? { get }
    var annotations: Annotations { get }
    var documentation: Documentation { get }
    var attributes: AttributeList { get }
    var modifiers: [SourceryModifier] { get }
    var isFinal: Bool { get }
    var isLazy: Bool { get }
    var definedInTypeName: TypeName? { get }
    var actualDefinedInTypeName: TypeName? { get }
    var definedInType: Type? { get }
    var isOptional: Bool { get }
    var isImplicitlyUnwrappedOptional: Bool { get }
    var unwrappedTypeName: String { get }
}

extension Variable: VariableAutoJSExport {}



"""),
    .init(name: "Log.swift", content:
"""
import Darwin
import Foundation

/// :nodoc:
public enum Log {

    public enum Level: Int {
        case errors
        case warnings
        case info
        case verbose
    }

    public static var level: Level = .warnings
    public static var logBenchmarks: Bool = false
    public static var logAST: Bool = false

    public static func error(_ message: Any) {
        log(level: .errors, "error: \\(message)")
        // to return error when running swift templates which is done in a different process
        if ProcessInfo().processName != "Sourcery" {
            fputs("\\(message)", stderr)
        }
    }

    public static func warning(_ message: Any) {
        log(level: .warnings, "warning: \\(message)")
    }

    public static func astWarning(_ message: Any) {
        guard logAST else { return }
        log(level: .warnings, "ast warning: \\(message)")
    }

    public static func astError(_ message: Any) {
        guard logAST else { return }
        log(level: .errors, "ast error: \\(message)")
    }

    public static func verbose(_ message: Any) {
        log(level: .verbose, message)
    }

    public static func info(_ message: Any) {
        log(level: .info, message)
    }

    public static func benchmark(_ message: Any) {
        guard logBenchmarks else { return }
        print(message)
    }

    private static func log(level logLevel: Level, _ message: Any) {
        guard logLevel.rawValue <= Log.level.rawValue else { return }
        print(message)
    }

}

extension String: Error {}

"""),
    .init(name: "Method.swift", content:
"""
import Foundation

/// :nodoc:
public typealias SourceryMethod = Method

/// Describes method parameter
@objcMembers public class MethodParameter: NSObject, SourceryModel, Typed, Annotated {
    /// Parameter external name
    public var argumentLabel: String?

    // Note: although method parameter can have no name, this property is not optional,
    // this is so to maintain compatibility with existing templates.
    /// Parameter internal name
    public let name: String

    /// Parameter type name
    public let typeName: TypeName

    /// Parameter flag whether it's inout or not
    public let `inout`: Bool
    
    /// Is this variadic parameter?
    public let isVariadic: Bool

    // sourcery: skipEquality, skipDescription
    /// Parameter type, if known
    public var type: Type?

    /// Parameter type attributes, i.e. `@escaping`
    public var typeAttributes: AttributeList {
        return typeName.attributes
    }

    /// Method parameter default value expression
    public var defaultValue: String?

    /// Annotations, that were created with // sourcery: annotation1, other = "annotation value", alterantive = 2
    public var annotations: Annotations = [:]

    /// :nodoc:
    public init(argumentLabel: String?, name: String = "", typeName: TypeName, type: Type? = nil, defaultValue: String? = nil, annotations: [String: NSObject] = [:], isInout: Bool = false, isVariadic: Bool = false) {
        self.typeName = typeName
        self.argumentLabel = argumentLabel
        self.name = name
        self.type = type
        self.defaultValue = defaultValue
        self.annotations = annotations
        self.`inout` = isInout
        self.isVariadic = isVariadic
    }

    /// :nodoc:
    public init(name: String = "", typeName: TypeName, type: Type? = nil, defaultValue: String? = nil, annotations: [String: NSObject] = [:], isInout: Bool = false, isVariadic: Bool = false) {
        self.typeName = typeName
        self.argumentLabel = name
        self.name = name
        self.type = type
        self.defaultValue = defaultValue
        self.annotations = annotations
        self.`inout` = isInout
        self.isVariadic = isVariadic
    }

    public var asSource: String {
        let typeSuffix = ": \\(`inout` ? "inout " : "")\\(typeName.asSource)\\(defaultValue.map { " = \\($0)" } ?? "")" + (isVariadic ? "..." : "")
        guard argumentLabel != name else {
            return name + typeSuffix
        }

        let labels = [argumentLabel ?? "_", name.nilIfEmpty]
          .compactMap { $0 }
          .joined(separator: " ")

        return (labels.nilIfEmpty ?? "_") + typeSuffix
    }

// sourcery:inline:MethodParameter.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            self.argumentLabel = aDecoder.decode(forKey: "argumentLabel")
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let typeName: TypeName = aDecoder.decode(forKey: "typeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typeName"])); fatalError() }; self.typeName = typeName
            self.`inout` = aDecoder.decode(forKey: "`inout`")
            self.isVariadic = aDecoder.decode(forKey: "isVariadic")
            self.type = aDecoder.decode(forKey: "type")
            self.defaultValue = aDecoder.decode(forKey: "defaultValue")
            guard let annotations: Annotations = aDecoder.decode(forKey: "annotations") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["annotations"])); fatalError() }; self.annotations = annotations
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.argumentLabel, forKey: "argumentLabel")
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.typeName, forKey: "typeName")
            aCoder.encode(self.`inout`, forKey: "`inout`")
            aCoder.encode(self.isVariadic, forKey: "isVariadic")
            aCoder.encode(self.type, forKey: "type")
            aCoder.encode(self.defaultValue, forKey: "defaultValue")
            aCoder.encode(self.annotations, forKey: "annotations")
        }
// sourcery:end
}

extension Array where Element == MethodParameter {
    public var asSource: String {
        "(\\(map { $0.asSource }.joined(separator: ", ")))"
    }
}

// sourcery: skipDiffing
@objcMembers public final class ClosureParameter: NSObject, SourceryModel, Typed, Annotated {
    /// Parameter external name
    public var argumentLabel: String?

    /// Parameter internal name
    public let name: String?

    /// Parameter type name
    public let typeName: TypeName

    /// Parameter flag whether it's inout or not
    public let `inout`: Bool

    // sourcery: skipEquality, skipDescription
    /// Parameter type, if known
    public var type: Type?

    /// Parameter type attributes, i.e. `@escaping`
    public var typeAttributes: AttributeList {
        return typeName.attributes
    }

    /// Method parameter default value expression
    public var defaultValue: String?

    /// Annotations, that were created with // sourcery: annotation1, other = "annotation value", alterantive = 2
    public var annotations: Annotations = [:]

    /// :nodoc:
    public init(argumentLabel: String? = nil, name: String? = nil, typeName: TypeName, type: Type? = nil,
                defaultValue: String? = nil, annotations: [String: NSObject] = [:], isInout: Bool = false) {
        self.typeName = typeName
        self.argumentLabel = argumentLabel
        self.name = name
        self.type = type
        self.defaultValue = defaultValue
        self.annotations = annotations
        self.`inout` = isInout
    }

    public var asSource: String {
        let typeInfo = "\\(`inout` ? "inout " : "")\\(typeName.asSource)"
        if argumentLabel?.nilIfNotValidParameterName == nil, name?.nilIfNotValidParameterName == nil {
            return typeInfo
        }

        let typeSuffix = ": \\(typeInfo)"
        guard argumentLabel != name else {
            return name ?? "" + typeSuffix
        }

        let labels = [argumentLabel ?? "_", name?.nilIfEmpty]
          .compactMap { $0 }
          .joined(separator: " ")

        return (labels.nilIfEmpty ?? "_") + typeSuffix
    }

    // sourcery:inline:ClosureParameter.AutoCoding

            /// :nodoc:
            required public init?(coder aDecoder: NSCoder) {
                self.argumentLabel = aDecoder.decode(forKey: "argumentLabel")
                self.name = aDecoder.decode(forKey: "name")
                guard let typeName: TypeName = aDecoder.decode(forKey: "typeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typeName"])); fatalError() }; self.typeName = typeName
                self.`inout` = aDecoder.decode(forKey: "`inout`")
                self.type = aDecoder.decode(forKey: "type")
                self.defaultValue = aDecoder.decode(forKey: "defaultValue")
                guard let annotations: Annotations = aDecoder.decode(forKey: "annotations") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["annotations"])); fatalError() }; self.annotations = annotations
            }

            /// :nodoc:
            public func encode(with aCoder: NSCoder) {
                aCoder.encode(self.argumentLabel, forKey: "argumentLabel")
                aCoder.encode(self.name, forKey: "name")
                aCoder.encode(self.typeName, forKey: "typeName")
                aCoder.encode(self.`inout`, forKey: "`inout`")
                aCoder.encode(self.type, forKey: "type")
                aCoder.encode(self.defaultValue, forKey: "defaultValue")
                aCoder.encode(self.annotations, forKey: "annotations")
            }

    // sourcery:end
}

extension Array where Element == ClosureParameter {
    public var asSource: String {
        "(\\(map { $0.asSource }.joined(separator: ", ")))"
    }
}

/// Describes method
@objc(SwiftMethod) @objcMembers public final class Method: NSObject, SourceryModel, Annotated, Documented, Definition {

    /// Full method name, including generic constraints, i.e. `foo<T>(bar: T)`
    public let name: String

    /// Method name including arguments names, i.e. `foo(bar:)`
    public var selectorName: String

    // sourcery: skipEquality, skipDescription
    /// Method name without arguments names and parenthesis, i.e. `foo<T>`
    public var shortName: String {
        return name.range(of: "(").map({ String(name[..<$0.lowerBound]) }) ?? name
    }

    // sourcery: skipEquality, skipDescription
    /// Method name without arguments names, parenthesis and generic types, i.e. `foo` (can be used to generate code for method call)
    public var callName: String {
        return shortName.range(of: "<").map({ String(shortName[..<$0.lowerBound]) }) ?? shortName
    }

    /// Method parameters
    public var parameters: [MethodParameter]

    /// Return value type name used in declaration, including generic constraints, i.e. `where T: Equatable`
    public var returnTypeName: TypeName

    // sourcery: skipEquality, skipDescription
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
        return returnTypeName.isOptional || isFailableInitializer
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

    /// Whether method is async method
    public let isAsync: Bool

    /// Whether method throws
    public let `throws`: Bool

    /// Whether method rethrows
    public let `rethrows`: Bool

    /// Method access level, i.e. `internal`, `private`, `fileprivate`, `public`, `open`
    public let accessLevel: String

    /// Whether method is a static method
    public let isStatic: Bool

    /// Whether method is a class method
    public let isClass: Bool

    // sourcery: skipEquality, skipDescription
    /// Whether method is an initializer
    public var isInitializer: Bool {
        return selectorName.hasPrefix("init(") || selectorName == "init"
    }

    // sourcery: skipEquality, skipDescription
    /// Whether method is an deinitializer
    public var isDeinitializer: Bool {
        return selectorName == "deinit"
    }

    /// Whether method is a failable initializer
    public let isFailableInitializer: Bool

    // sourcery: skipEquality, skipDescription
    /// Whether method is a convenience initializer
    public var isConvenienceInitializer: Bool {
        modifiers.contains { $0.name == "convenience" }
    }

    // sourcery: skipEquality, skipDescription
    /// Whether method is required
    public var isRequired: Bool {
        modifiers.contains { $0.name == "required" }
    }

    // sourcery: skipEquality, skipDescription
    /// Whether method is final
    public var isFinal: Bool {
        modifiers.contains { $0.name == "final" }
    }

    // sourcery: skipEquality, skipDescription
    /// Whether method is mutating
    public var isMutating: Bool {
        modifiers.contains { $0.name == "mutating" }
    }

    // sourcery: skipEquality, skipDescription
    /// Whether method is generic
    public var isGeneric: Bool {
        shortName.hasSuffix(">")
    }

    // sourcery: skipEquality, skipDescription
    /// Whether method is optional (in an Objective-C protocol)
    public var isOptional: Bool {
        modifiers.contains { $0.name == "optional" }
    }

    /// Annotations, that were created with // sourcery: annotation1, other = "annotation value", alterantive = 2
    public let annotations: Annotations

    public let documentation: Documentation

    /// Reference to type name where the method is defined,
    /// nil if defined outside of any `enum`, `struct`, `class` etc
    public let definedInTypeName: TypeName?

    // sourcery: skipEquality, skipDescription
    /// Reference to actual type name where the method is defined if declaration uses typealias, otherwise just a `definedInTypeName`
    public var actualDefinedInTypeName: TypeName? {
        return definedInTypeName?.actualTypeName ?? definedInTypeName
    }

    // sourcery: skipEquality, skipDescription
    /// Reference to actual type where the object is defined,
    /// nil if defined outside of any `enum`, `struct`, `class` etc or type is unknown
    public var definedInType: Type?

    /// Method attributes, i.e. `@discardableResult`
    public let attributes: AttributeList

    /// Method modifiers, i.e. `private`
    public let modifiers: [SourceryModifier]

    // Underlying parser data, never to be used by anything else
    // sourcery: skipEquality, skipDescription, skipCoding, skipJSExport
    /// :nodoc:
    public var __parserData: Any?

    /// :nodoc:
    public init(name: String,
                selectorName: String? = nil,
                parameters: [MethodParameter] = [],
                returnTypeName: TypeName = TypeName(name: "Void"),
                isAsync: Bool = false,
                throws: Bool = false,
                rethrows: Bool = false,
                accessLevel: AccessLevel = .internal,
                isStatic: Bool = false,
                isClass: Bool = false,
                isFailableInitializer: Bool = false,
                attributes: AttributeList = [:],
                modifiers: [SourceryModifier] = [],
                annotations: [String: NSObject] = [:],
                documentation: [String] = [],
                definedInTypeName: TypeName? = nil) {

        self.name = name
        self.selectorName = selectorName ?? name
        self.parameters = parameters
        self.returnTypeName = returnTypeName
        self.isAsync = isAsync
        self.throws = `throws`
        self.rethrows = `rethrows`
        self.accessLevel = accessLevel.rawValue
        self.isStatic = isStatic
        self.isClass = isClass
        self.isFailableInitializer = isFailableInitializer
        self.attributes = attributes
        self.modifiers = modifiers
        self.annotations = annotations
        self.documentation = documentation
        self.definedInTypeName = definedInTypeName
    }

// sourcery:inline:Method.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let selectorName: String = aDecoder.decode(forKey: "selectorName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["selectorName"])); fatalError() }; self.selectorName = selectorName
            guard let parameters: [MethodParameter] = aDecoder.decode(forKey: "parameters") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["parameters"])); fatalError() }; self.parameters = parameters
            guard let returnTypeName: TypeName = aDecoder.decode(forKey: "returnTypeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["returnTypeName"])); fatalError() }; self.returnTypeName = returnTypeName
            self.returnType = aDecoder.decode(forKey: "returnType")
            self.isAsync = aDecoder.decode(forKey: "isAsync")
            self.`throws` = aDecoder.decode(forKey: "`throws`")
            self.`rethrows` = aDecoder.decode(forKey: "`rethrows`")
            guard let accessLevel: String = aDecoder.decode(forKey: "accessLevel") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["accessLevel"])); fatalError() }; self.accessLevel = accessLevel
            self.isStatic = aDecoder.decode(forKey: "isStatic")
            self.isClass = aDecoder.decode(forKey: "isClass")
            self.isFailableInitializer = aDecoder.decode(forKey: "isFailableInitializer")
            guard let annotations: Annotations = aDecoder.decode(forKey: "annotations") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["annotations"])); fatalError() }; self.annotations = annotations
            guard let documentation: Documentation = aDecoder.decode(forKey: "documentation") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["documentation"])); fatalError() }; self.documentation = documentation
            self.definedInTypeName = aDecoder.decode(forKey: "definedInTypeName")
            self.definedInType = aDecoder.decode(forKey: "definedInType")
            guard let attributes: AttributeList = aDecoder.decode(forKey: "attributes") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["attributes"])); fatalError() }; self.attributes = attributes
            guard let modifiers: [SourceryModifier] = aDecoder.decode(forKey: "modifiers") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["modifiers"])); fatalError() }; self.modifiers = modifiers
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.selectorName, forKey: "selectorName")
            aCoder.encode(self.parameters, forKey: "parameters")
            aCoder.encode(self.returnTypeName, forKey: "returnTypeName")
            aCoder.encode(self.returnType, forKey: "returnType")
            aCoder.encode(self.isAsync, forKey: "isAsync")
            aCoder.encode(self.`throws`, forKey: "`throws`")
            aCoder.encode(self.`rethrows`, forKey: "`rethrows`")
            aCoder.encode(self.accessLevel, forKey: "accessLevel")
            aCoder.encode(self.isStatic, forKey: "isStatic")
            aCoder.encode(self.isClass, forKey: "isClass")
            aCoder.encode(self.isFailableInitializer, forKey: "isFailableInitializer")
            aCoder.encode(self.annotations, forKey: "annotations")
            aCoder.encode(self.documentation, forKey: "documentation")
            aCoder.encode(self.definedInTypeName, forKey: "definedInTypeName")
            aCoder.encode(self.definedInType, forKey: "definedInType")
            aCoder.encode(self.attributes, forKey: "attributes")
            aCoder.encode(self.modifiers, forKey: "modifiers")
        }
// sourcery:end
}

"""),
    .init(name: "Modifier.swift", content:
"""
import Foundation

public typealias SourceryModifier = Modifier
/// modifier can be thing like `private`, `class`, `nonmutating`
/// if a declaration has modifier like `private(set)` it's name will be `private` and detail will be `set`
@objcMembers public class Modifier: NSObject, AutoCoding, AutoEquatable, AutoDiffable, AutoJSExport {

    /// The declaration modifier name.
    public let name: String

    /// The modifier detail, if any.
    public let detail: String?

    public init(name: String, detail: String? = nil) {
        self.name = name
        self.detail = detail
    }

    public var asSource: String {
        if let detail = detail {
            return "\\(name)(\\(detail))"
        } else {
            return name
        }
    }

    // sourcery:inline:Modifier.AutoCoding

            /// :nodoc:
            required public init?(coder aDecoder: NSCoder) {
                guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
                self.detail = aDecoder.decode(forKey: "detail")
            }

            /// :nodoc:
            public func encode(with aCoder: NSCoder) {
                aCoder.encode(self.name, forKey: "name")
                aCoder.encode(self.detail, forKey: "detail")
            }
    // sourcery:end
}

"""),
    .init(name: "PhantomProtocols.swift", content:
"""
//
// Created by Krzysztof Zablocki on 23/01/2017.
// Copyright (c) 2017 Pixle. All rights reserved.
//

import Foundation

/// Phantom protocol for diffing
protocol AutoDiffable {}

/// Phantom protocol for equality
protocol AutoEquatable {}

/// Phantom protocol for equality
protocol AutoDescription {}

/// Phantom protocol for NSCoding
protocol AutoCoding {}

protocol AutoJSExport {}

/// Phantom protocol for NSCoding, Equatable and Diffable
protocol SourceryModelWithoutDescription: AutoDiffable, AutoEquatable, AutoCoding, AutoJSExport {}

protocol SourceryModel: SourceryModelWithoutDescription, AutoDescription {}

"""),
    .init(name: "Protocol.swift", content:
"""
//
//  Protocol.swift
//  Sourcery
//
//  Created by Krzysztof Zablocki on 09/12/2016.
//  Copyright © 2016 Pixle. All rights reserved.
//

import Foundation

/// :nodoc:
public typealias SourceryProtocol = Protocol

/// Describes Swift protocol
@objcMembers public final class Protocol: Type {

    /// Returns "protocol"
    public override var kind: String { return "protocol" }

    /// list of all declared associated types with their names as keys
    public var associatedTypes: [String: AssociatedType] {
        didSet {
            isGeneric = !associatedTypes.isEmpty || !genericRequirements.isEmpty
        }
    }

    /// list of generic requirements
    public var genericRequirements: [GenericRequirement] {
        didSet {
            isGeneric = !associatedTypes.isEmpty || !genericRequirements.isEmpty
        }
    }

    /// :nodoc:
    public init(name: String = "",
                parent: Type? = nil,
                accessLevel: AccessLevel = .internal,
                isExtension: Bool = false,
                variables: [Variable] = [],
                methods: [Method] = [],
                subscripts: [Subscript] = [],
                inheritedTypes: [String] = [],
                containedTypes: [Type] = [],
                typealiases: [Typealias] = [],
                associatedTypes: [String: AssociatedType] = [:],
                genericRequirements: [GenericRequirement] = [],
                attributes: AttributeList = [:],
                modifiers: [SourceryModifier] = [],
                annotations: [String: NSObject] = [:],
                documentation: [String] = []) {
        self.genericRequirements = genericRequirements
        self.associatedTypes = associatedTypes
        super.init(
            name: name,
            parent: parent,
            accessLevel: accessLevel,
            isExtension: isExtension,
            variables: variables,
            methods: methods,
            subscripts: subscripts,
            inheritedTypes: inheritedTypes,
            containedTypes: containedTypes,
            typealiases: typealiases,
            attributes: attributes,
            modifiers: modifiers,
            annotations: annotations,
            documentation: documentation,
            isGeneric: !associatedTypes.isEmpty || !genericRequirements.isEmpty
        )
    }

// sourcery:inline:Protocol.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let associatedTypes: [String: AssociatedType] = aDecoder.decode(forKey: "associatedTypes") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["associatedTypes"])); fatalError() }; self.associatedTypes = associatedTypes
            guard let genericRequirements: [GenericRequirement] = aDecoder.decode(forKey: "genericRequirements") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["genericRequirements"])); fatalError() }; self.genericRequirements = genericRequirements
            super.init(coder: aDecoder)
        }

        /// :nodoc:
        override public func encode(with aCoder: NSCoder) {
            super.encode(with: aCoder)
            aCoder.encode(self.associatedTypes, forKey: "associatedTypes")
            aCoder.encode(self.genericRequirements, forKey: "genericRequirements")
        }
// sourcery:end
}

"""),
    .init(name: "ProtocolComposition.swift", content:
"""
// Created by eric_horacek on 2/12/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import Foundation

// sourcery: skipJSExport
/// Describes a Swift [protocol composition](https://docs.swift.org/swift-book/ReferenceManual/Types.html#ID454).
@objcMembers public final class ProtocolComposition: Type {

    /// Returns "protocolComposition"
    public override var kind: String { return "protocolComposition" }

    /// The names of the types composed to form this composition
    public let composedTypeNames: [TypeName]

    // sourcery: skipEquality, skipDescription
    /// The types composed to form this composition, if known
    public var composedTypes: [Type]?

    /// :nodoc:
    public init(name: String = "",
                parent: Type? = nil,
                accessLevel: AccessLevel = .internal,
                isExtension: Bool = false,
                variables: [Variable] = [],
                methods: [Method] = [],
                subscripts: [Subscript] = [],
                inheritedTypes: [String] = [],
                containedTypes: [Type] = [],
                typealiases: [Typealias] = [],
                attributes: AttributeList = [:],
                annotations: [String: NSObject] = [:],
                isGeneric: Bool = false,
                composedTypeNames: [TypeName] = [],
                composedTypes: [Type]? = nil) {
        self.composedTypeNames = composedTypeNames
        self.composedTypes = composedTypes
        super.init(
            name: name,
            parent: parent,
            accessLevel: accessLevel,
            isExtension: isExtension,
            variables: variables,
            methods: methods,
            subscripts: subscripts,
            inheritedTypes: inheritedTypes,
            containedTypes: containedTypes,
            typealiases: typealiases,
            annotations: annotations,
            isGeneric: isGeneric
        )
    }

// sourcery:inline:ProtocolComposition.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let composedTypeNames: [TypeName] = aDecoder.decode(forKey: "composedTypeNames") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["composedTypeNames"])); fatalError() }; self.composedTypeNames = composedTypeNames
            self.composedTypes = aDecoder.decode(forKey: "composedTypes")
            super.init(coder: aDecoder)
        }

        /// :nodoc:
        override public func encode(with aCoder: NSCoder) {
            super.encode(with: aCoder)
            aCoder.encode(self.composedTypeNames, forKey: "composedTypeNames")
            aCoder.encode(self.composedTypes, forKey: "composedTypes")
        }
// sourcery:end

}

"""),
    .init(name: "Struct.swift", content:
"""
//
//  Struct.swift
//  Sourcery
//
//  Created by Krzysztof Zablocki on 13/09/2016.
//  Copyright © 2016 Pixle. All rights reserved.
//

import Foundation

// sourcery: skipDescription
/// Describes Swift struct
@objcMembers public final class Struct: Type {

    /// Returns "struct"
    public override var kind: String { return "struct" }

    /// :nodoc:
    public override init(name: String = "",
                         parent: Type? = nil,
                         accessLevel: AccessLevel = .internal,
                         isExtension: Bool = false,
                         variables: [Variable] = [],
                         methods: [Method] = [],
                         subscripts: [Subscript] = [],
                         inheritedTypes: [String] = [],
                         containedTypes: [Type] = [],
                         typealiases: [Typealias] = [],
                         attributes: AttributeList = [:],
                         modifiers: [SourceryModifier] = [],
                         annotations: [String: NSObject] = [:],
                         documentation: [String] = [],
                         isGeneric: Bool = false) {
        super.init(
            name: name,
            parent: parent,
            accessLevel: accessLevel,
            isExtension: isExtension,
            variables: variables,
            methods: methods,
            subscripts: subscripts,
            inheritedTypes: inheritedTypes,
            containedTypes: containedTypes,
            typealiases: typealiases,
            attributes: attributes,
            modifiers: modifiers,
            annotations: annotations,
            documentation: documentation,
            isGeneric: isGeneric
        )
    }

// sourcery:inline:Struct.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }

        /// :nodoc:
        override public func encode(with aCoder: NSCoder) {
            super.encode(with: aCoder)
        }
// sourcery:end
}

"""),
    .init(name: "Subscript.swift", content:
"""
import Foundation

/// Describes subscript
@objcMembers public final class Subscript: NSObject, SourceryModel, Annotated, Documented, Definition {

    /// Method parameters
    public var parameters: [MethodParameter]

    /// Return value type name used in declaration, including generic constraints, i.e. `where T: Equatable`
    public var returnTypeName: TypeName

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

    /// Whether method is final
    public var isFinal: Bool {
        modifiers.contains { $0.name == "final" }
    }

    /// Variable read access level, i.e. `internal`, `private`, `fileprivate`, `public`, `open`
    public let readAccess: String

    /// Variable write access, i.e. `internal`, `private`, `fileprivate`, `public`, `open`.
    /// For immutable variables this value is empty string
    public var writeAccess: String

    /// Whether variable is mutable or not
    public var isMutable: Bool {
        return writeAccess != AccessLevel.none.rawValue
    }

    /// Annotations, that were created with // sourcery: annotation1, other = "annotation value", alterantive = 2
    public let annotations: Annotations

    public let documentation: Documentation

    /// Reference to type name where the method is defined,
    /// nil if defined outside of any `enum`, `struct`, `class` etc
    public let definedInTypeName: TypeName?

    /// Reference to actual type name where the method is defined if declaration uses typealias, otherwise just a `definedInTypeName`
    public var actualDefinedInTypeName: TypeName? {
        return definedInTypeName?.actualTypeName ?? definedInTypeName
    }

    // sourcery: skipEquality, skipDescription
    /// Reference to actual type where the object is defined,
    /// nil if defined outside of any `enum`, `struct`, `class` etc or type is unknown
    public var definedInType: Type?

    /// Method attributes, i.e. `@discardableResult`
    public let attributes: AttributeList

    /// Method modifiers, i.e. `private`
    public let modifiers: [SourceryModifier]

    // Underlying parser data, never to be used by anything else
    // sourcery: skipEquality, skipDescription, skipCoding, skipJSExport
    /// :nodoc:
    public var __parserData: Any?

    /// :nodoc:
    public init(parameters: [MethodParameter] = [],
                returnTypeName: TypeName,
                accessLevel: (read: AccessLevel, write: AccessLevel) = (.internal, .internal),
                attributes: AttributeList = [:],
                modifiers: [SourceryModifier] = [],
                annotations: [String: NSObject] = [:],
                documentation: [String] = [],
                definedInTypeName: TypeName? = nil) {

        self.parameters = parameters
        self.returnTypeName = returnTypeName
        self.readAccess = accessLevel.read.rawValue
        self.writeAccess = accessLevel.write.rawValue
        self.attributes = attributes
        self.modifiers = modifiers
        self.annotations = annotations
        self.documentation = documentation
        self.definedInTypeName = definedInTypeName
    }

// sourcery:inline:Subscript.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let parameters: [MethodParameter] = aDecoder.decode(forKey: "parameters") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["parameters"])); fatalError() }; self.parameters = parameters
            guard let returnTypeName: TypeName = aDecoder.decode(forKey: "returnTypeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["returnTypeName"])); fatalError() }; self.returnTypeName = returnTypeName
            self.returnType = aDecoder.decode(forKey: "returnType")
            guard let readAccess: String = aDecoder.decode(forKey: "readAccess") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["readAccess"])); fatalError() }; self.readAccess = readAccess
            guard let writeAccess: String = aDecoder.decode(forKey: "writeAccess") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["writeAccess"])); fatalError() }; self.writeAccess = writeAccess
            guard let annotations: Annotations = aDecoder.decode(forKey: "annotations") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["annotations"])); fatalError() }; self.annotations = annotations
            guard let documentation: Documentation = aDecoder.decode(forKey: "documentation") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["documentation"])); fatalError() }; self.documentation = documentation
            self.definedInTypeName = aDecoder.decode(forKey: "definedInTypeName")
            self.definedInType = aDecoder.decode(forKey: "definedInType")
            guard let attributes: AttributeList = aDecoder.decode(forKey: "attributes") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["attributes"])); fatalError() }; self.attributes = attributes
            guard let modifiers: [SourceryModifier] = aDecoder.decode(forKey: "modifiers") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["modifiers"])); fatalError() }; self.modifiers = modifiers
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.parameters, forKey: "parameters")
            aCoder.encode(self.returnTypeName, forKey: "returnTypeName")
            aCoder.encode(self.returnType, forKey: "returnType")
            aCoder.encode(self.readAccess, forKey: "readAccess")
            aCoder.encode(self.writeAccess, forKey: "writeAccess")
            aCoder.encode(self.annotations, forKey: "annotations")
            aCoder.encode(self.documentation, forKey: "documentation")
            aCoder.encode(self.definedInTypeName, forKey: "definedInTypeName")
            aCoder.encode(self.definedInType, forKey: "definedInType")
            aCoder.encode(self.attributes, forKey: "attributes")
            aCoder.encode(self.modifiers, forKey: "modifiers")
        }
// sourcery:end

}

"""),
    .init(name: "TemplateContext.swift", content:
"""
//
// Created by Krzysztof Zablocki on 31/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

/// :nodoc:
// sourcery: skipCoding
@objcMembers public final class TemplateContext: NSObject, SourceryModel, NSCoding {
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
        guard let parserResult: FileParserResult = aDecoder.decode(forKey: "parserResult") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found. FileParserResults are required for template context that needs persisting.", arguments: getVaList(["parserResult"])); fatalError() }
        guard let argument: [String: NSObject] = aDecoder.decode(forKey: "argument") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["argument"])); fatalError() }

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
@objcMembers public final class Types: NSObject, SourceryModel {

    /// :nodoc:
    public let types: [Type]

    /// All known typealiases
    public let typealiases: [Typealias]

    /// :nodoc:
    public init(types: [Type], typealiases: [Typealias] = []) {
        self.types = types
        self.typealiases = typealiases
    }

// sourcery:inline:Types.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let types: [Type] = aDecoder.decode(forKey: "types") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["types"])); fatalError() }; self.types = types
            guard let typealiases: [Typealias] = aDecoder.decode(forKey: "typealiases") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typealiases"])); fatalError() }; self.typealiases = typealiases
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
                    throw "\\(type.name) is not a class and should be used with `implementing` or `based`"
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
                    throw "\\(type.name) is a class and should be used with `inheriting` or `based`"
                }
        })
    }()
}

/// :nodoc:
@objcMembers public class TypesCollection: NSObject, AutoJSExport {

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
                throw "Unknown type \\(key), should be used with `based`"
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
    public override func value(forKey key: String) -> Any? {
        do {
            return try types(forKey: key)
        } catch {
            Log.error(error)
            return nil
        }
    }

    /// :nodoc:
    public subscript(_ key: String) -> [Type] {
        do {
            return try types(forKey: key)
        } catch {
            Log.error(error)
            return []
        }
    }

    public override func responds(to aSelector: Selector!) -> Bool {
        return true
    }
}

"""),
    .init(name: "Tuple.swift", content:
"""
import Foundation

/// Describes tuple type
@objcMembers public final class TupleType: NSObject, SourceryModel {

    /// Type name used in declaration
    public var name: String

    /// Tuple elements
    public var elements: [TupleElement]

    /// :nodoc:
    public init(name: String, elements: [TupleElement]) {
        self.name = name
        self.elements = elements
    }

    /// :nodoc:
    public init(elements: [TupleElement]) {
        self.name = elements.asSource
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

/// Describes tuple type element
@objcMembers public final class TupleElement: NSObject, SourceryModel, Typed {

    /// Tuple element name
    public let name: String?

    /// Tuple element type name
    public var typeName: TypeName

    // sourcery: skipEquality, skipDescription
    /// Tuple element type, if known
    public var type: Type?

    /// :nodoc:
    public init(name: String? = nil, typeName: TypeName, type: Type? = nil) {
        self.name = name
        self.typeName = typeName
        self.type = type
    }

    public var asSource: String {
        // swiftlint:disable:next force_unwrapping
        "\\(name != nil ? "\\(name!): " : "")\\(typeName.asSource)"
    }

// sourcery:inline:TupleElement.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            self.name = aDecoder.decode(forKey: "name")
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

extension Array where Element == TupleElement {
    public var asSource: String {
        "(\\(map { $0.asSource }.joined(separator: ", ")))"
    }

    public var asTypeName: String {
        "(\\(map { $0.typeName.asSource }.joined(separator: ", ")))"
    }
}

"""),
    .init(name: "Type.swift", content:
"""
//
// Created by Krzysztof Zablocki on 11/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

/// :nodoc:
public typealias AttributeList = [String: [Attribute]]

/// Defines Swift type
@objcMembers public class Type: NSObject, SourceryModel, Annotated, Documented {

    /// :nodoc:
    public var module: String?

    /// Imports that existed in the file that contained this type declaration
    public var imports: [Import] = []

    // sourcery: skipEquality
    /// Imports existed in all files containing this type and all its super classes/protocols
    public var allImports: [Import] {
        return self.unique({ $0.gatherAllImports() }, filter: { $0 == $1 })
    }

    private func gatherAllImports() -> [Import] {
        var allImports: [Import] = Array(self.imports)

        self.basedTypes.values.forEach { (basedType) in
            allImports.append(contentsOf: basedType.imports)
        }
        return allImports
    }

    // All local typealiases
    // sourcery: skipJSExport
    /// :nodoc:
    public var typealiases: [String: Typealias] {
        didSet {
            typealiases.values.forEach { $0.parent = self }
        }
    }

    // sourcery: skipJSExport
    /// Whether declaration is an extension of some type
    public var isExtension: Bool

    // sourcery: forceEquality
    /// Kind of type declaration, i.e. `enum`, `struct`, `class`, `protocol` or `extension`
    public var kind: String { return isExtension ? "extension" : "unknown" }

    /// Type access level, i.e. `internal`, `private`, `fileprivate`, `public`, `open`
    public let accessLevel: String

    /// Type name in global scope. For inner types includes the name of its containing type, i.e. `Type.Inner`
    public var name: String {
        guard let parentName = parent?.name else { return localName }
        return "\\(parentName).\\(localName)"
    }

    // sourcery: skipCoding
    /// Whether the type has been resolved as unknown extension
    public var isUnknownExtension: Bool = false

    // sourcery: skipDescription
    /// Global type name including module name, unless it's an extension of unknown type
    public var globalName: String {
        guard let module = module, !isUnknownExtension else { return name }
        return "\\(module).\\(name)"
    }

    /// Whether type is generic
    public var isGeneric: Bool

    /// Type name in its own scope.
    public var localName: String

    // sourcery: skipEquality, skipDescription
    /// Variables defined in this type only, inluding variables defined in its extensions,
    /// but not including variables inherited from superclasses (for classes only) and protocols
    public var variables: [Variable] {
        unique({ $0.rawVariables }, filter: Self.uniqueVariableFilter)
    }

    /// Unfiltered (can contain duplications from extensions) variables defined in this type only, inluding variables defined in its extensions,
    /// but not including variables inherited from superclasses (for classes only) and protocols
    public var rawVariables: [Variable]

    // sourcery: skipEquality, skipDescription
    /// All variables defined for this type, including variables defined in extensions,
    /// in superclasses (for classes only) and protocols
    public var allVariables: [Variable] {
        return flattenAll({
            return $0.variables
        },
        isExtension: { $0.definedInType?.isExtension == true },
        filter: { all, extracted in
            !all.contains(where: { Self.uniqueVariableFilter($0, rhs: extracted) })
        })
    }

    private static func uniqueVariableFilter(_ lhs: Variable, rhs: Variable) -> Bool {
        return lhs.name == rhs.name && lhs.isStatic == rhs.isStatic && lhs.typeName == rhs.typeName
    }

    // sourcery: skipEquality, skipDescription
    /// Methods defined in this type only, inluding methods defined in its extensions,
    /// but not including methods inherited from superclasses (for classes only) and protocols
    public var methods: [Method] {
        unique({ $0.rawMethods }, filter: Self.uniqueMethodFilter)
    }

    /// Unfiltered (can contain duplications from extensions) methods defined in this type only, inluding methods defined in its extensions,
    /// but not including methods inherited from superclasses (for classes only) and protocols
    public var rawMethods: [Method]

    // sourcery: skipEquality, skipDescription
    /// All methods defined for this type, including methods defined in extensions,
    /// in superclasses (for classes only) and protocols
    public var allMethods: [Method] {
        return flattenAll({
            $0.methods
        },
        isExtension: { $0.definedInType?.isExtension == true },
        filter: { all, extracted in
            !all.contains(where: { Self.uniqueMethodFilter($0, rhs: extracted) })
        })
    }

    private static func uniqueMethodFilter(_ lhs: Method, rhs: Method) -> Bool {
        return lhs.name == rhs.name && lhs.isStatic == rhs.isStatic && lhs.isClass == rhs.isClass && lhs.actualReturnTypeName == rhs.actualReturnTypeName
    }

    // sourcery: skipEquality, skipDescription
    /// Subscripts defined in this type only, inluding subscripts defined in its extensions,
    /// but not including subscripts inherited from superclasses (for classes only) and protocols
    public var subscripts: [Subscript] {
        unique({ $0.rawSubscripts }, filter: Self.uniqueSubscriptFilter)
    }

    /// Unfiltered (can contain duplications from extensions) Subscripts defined in this type only, inluding subscripts defined in its extensions,
    /// but not including subscripts inherited from superclasses (for classes only) and protocols
    public var rawSubscripts: [Subscript]

    // sourcery: skipEquality, skipDescription
    /// All subscripts defined for this type, including subscripts defined in extensions,
    /// in superclasses (for classes only) and protocols
    public var allSubscripts: [Subscript] {
        return flattenAll({ $0.subscripts },
            isExtension: { $0.definedInType?.isExtension == true },
            filter: { all, extracted in
                !all.contains(where: { Self.uniqueSubscriptFilter($0, rhs: extracted) })
            })
    }

    private static func uniqueSubscriptFilter(_ lhs: Subscript, rhs: Subscript) -> Bool {
        return lhs.parameters == rhs.parameters && lhs.returnTypeName == rhs.returnTypeName && lhs.readAccess == rhs.readAccess && lhs.writeAccess == rhs.writeAccess
    }

    // sourcery: skipEquality, skipDescription, skipJSExport
    /// Bytes position of the body of this type in its declaration file if available.
    public var bodyBytesRange: BytesRange?

    // sourcery: skipEquality, skipDescription, skipJSExport
    /// Bytes position of the whole declaration of this type in its declaration file if available.
    public var completeDeclarationRange: BytesRange?

    private func flattenAll<T>(_ extraction: @escaping (Type) -> [T], isExtension: (T) -> Bool, filter: ([T], T) -> Bool) -> [T] {
        let all = NSMutableOrderedSet()
        let allObjects = extraction(self)

        /// The order of importance for properties is:
        /// Base class
        /// Inheritance
        /// Protocol conformance
        /// Extension

        var extensions = [T]()
        var baseObjects = [T]()

        allObjects.forEach {
            if isExtension($0) {
                extensions.append($0)
            } else {
                baseObjects.append($0)
            }
        }

        all.addObjects(from: baseObjects)

        func filteredExtraction(_ target: Type) -> [T] {
            // swiftlint:disable:next force_cast
            let all = all.array as! [T]
            let extracted = extraction(target).filter({ filter(all, $0) })
            return extracted
        }

        inherits.values.sorted(by: { $0.name < $1.name }).forEach { all.addObjects(from: filteredExtraction($0)) }
        implements.values.sorted(by: { $0.name < $1.name }).forEach { all.addObjects(from: filteredExtraction($0)) }

        // swiftlint:disable:next force_cast
        let array = all.array as! [T]
        all.addObjects(from: extensions.filter({ filter(array, $0) }))

        return all.array.compactMap { $0 as? T }
    }

    private func unique<T>(_ extraction: @escaping (Type) -> [T], filter: (T, T) -> Bool) -> [T] {
        let all = NSMutableOrderedSet()
        for nextItem in extraction(self) {
            // swiftlint:disable:next force_cast
            if !all.contains(where: { filter($0 as! T, nextItem) }) {
                all.add(nextItem)
            }
        }

        return all.array.compactMap { $0 as? T }
    }

    /// All initializers defined in this type
    public var initializers: [Method] {
        return methods.filter { $0.isInitializer }
    }

    /// All annotations for this type
    public var annotations: Annotations = [:]

    public var documentation: Documentation = []

    /// Static variables defined in this type
    public var staticVariables: [Variable] {
        return variables.filter { $0.isStatic }
    }

    /// Static methods defined in this type
    public var staticMethods: [Method] {
        return methods.filter { $0.isStatic }
    }

    /// Class methods defined in this type
    public var classMethods: [Method] {
        return methods.filter { $0.isClass }
    }

    /// Instance variables defined in this type
    public var instanceVariables: [Variable] {
        return variables.filter { !$0.isStatic }
    }

    /// Instance methods defined in this type
    public var instanceMethods: [Method] {
        return methods.filter { !$0.isStatic && !$0.isClass }
    }

    /// Computed instance variables defined in this type
    public var computedVariables: [Variable] {
        return variables.filter { $0.isComputed && !$0.isStatic }
    }

    /// Stored instance variables defined in this type
    public var storedVariables: [Variable] {
        return variables.filter { !$0.isComputed && !$0.isStatic }
    }

    /// Names of types this type inherits from (for classes only) and protocols it implements, in order of definition
    public var inheritedTypes: [String] {
        didSet {
            based.removeAll()
            inheritedTypes.forEach { name in
                self.based[name] = name
            }
        }
    }

    // sourcery: skipEquality, skipDescription
    /// Names of types or protocols this type inherits from, including unknown (not scanned) types
    public var based = [String: String]()

    // sourcery: skipEquality, skipDescription
    /// Types this type inherits from or implements, including unknown (not scanned) types with extensions defined
    public var basedTypes = [String: Type]()

    /// Types this type inherits from
    public var inherits = [String: Type]()

    // sourcery: skipEquality, skipDescription
    /// Protocols this type implements
    public var implements = [String: Type]()

    /// Contained types
    public var containedTypes: [Type] {
        didSet {
            containedTypes.forEach {
                containedType[$0.localName] = $0
                $0.parent = self
            }
        }
    }

    // sourcery: skipEquality, skipDescription
    /// Contained types groupd by their names
    public private(set) var containedType: [String: Type] = [:]

    /// Name of parent type (for contained types only)
    public private(set) var parentName: String?

    // sourcery: skipEquality, skipDescription
    /// Parent type, if known (for contained types only)
    public var parent: Type? {
        didSet {
            parentName = parent?.name
        }
    }

    // sourcery: skipJSExport
    /// :nodoc:
    public var parentTypes: AnyIterator<Type> {
        var next: Type? = self
        return AnyIterator {
            next = next?.parent
            return next
        }
    }

    // sourcery: skipEquality, skipDescription
    /// Superclass type, if known (only for classes)
    public var supertype: Type?

    /// Type attributes, i.e. `@objc`
    public var attributes: AttributeList

    /// Type modifiers, i.e. `private`, `final`
    public var modifiers: [SourceryModifier]

    /// Path to file where the type is defined
    // sourcery: skipDescription, skipEquality, skipJSExport
    public var path: String? {
        didSet {
            if let path = path {
                fileName = (path as NSString).lastPathComponent
            }
        }
    }

    /// Directory to file where the type is defined
    // sourcery: skipDescription, skipEquality, skipJSExport
    public var directory: String? {
        get {
            return (path as? NSString)?.deletingLastPathComponent
        }
    }

    /// File name where the type was defined
    public var fileName: String?

    /// :nodoc:
    public init(name: String = "",
                parent: Type? = nil,
                accessLevel: AccessLevel = .internal,
                isExtension: Bool = false,
                variables: [Variable] = [],
                methods: [Method] = [],
                subscripts: [Subscript] = [],
                inheritedTypes: [String] = [],
                containedTypes: [Type] = [],
                typealiases: [Typealias] = [],
                attributes: AttributeList = [:],
                modifiers: [SourceryModifier] = [],
                annotations: [String: NSObject] = [:],
                documentation: [String] = [],
                isGeneric: Bool = false) {

        self.localName = name
        self.accessLevel = accessLevel.rawValue
        self.isExtension = isExtension
        self.rawVariables = variables
        self.rawMethods = methods
        self.rawSubscripts = subscripts
        self.inheritedTypes = inheritedTypes
        self.containedTypes = containedTypes
        self.typealiases = [:]
        self.parent = parent
        self.parentName = parent?.name
        self.attributes = attributes
        self.modifiers = modifiers
        self.annotations = annotations
        self.documentation = documentation
        self.isGeneric = isGeneric

        super.init()
        containedTypes.forEach {
            containedType[$0.localName] = $0
            $0.parent = self
        }
        inheritedTypes.forEach { name in
            self.based[name] = name
        }
        typealiases.forEach({
            $0.parent = self
            self.typealiases[$0.aliasName] = $0
        })
    }

    /// :nodoc:
    public func extend(_ type: Type) {
        type.annotations.forEach { self.annotations[$0.key] = $0.value }
        type.inherits.forEach { self.inherits[$0.key] = $0.value }
        type.implements.forEach { self.implements[$0.key] = $0.value }
        self.inheritedTypes += type.inheritedTypes
        self.containedTypes += type.containedTypes

        self.rawVariables += type.rawVariables
        self.rawMethods += type.rawMethods
        self.rawSubscripts += type.rawSubscripts
    }

// sourcery:inline:Type.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            self.module = aDecoder.decode(forKey: "module")
            guard let imports: [Import] = aDecoder.decode(forKey: "imports") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["imports"])); fatalError() }; self.imports = imports
            guard let typealiases: [String: Typealias] = aDecoder.decode(forKey: "typealiases") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typealiases"])); fatalError() }; self.typealiases = typealiases
            self.isExtension = aDecoder.decode(forKey: "isExtension")
            guard let accessLevel: String = aDecoder.decode(forKey: "accessLevel") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["accessLevel"])); fatalError() }; self.accessLevel = accessLevel
            self.isGeneric = aDecoder.decode(forKey: "isGeneric")
            guard let localName: String = aDecoder.decode(forKey: "localName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["localName"])); fatalError() }; self.localName = localName
            guard let rawVariables: [Variable] = aDecoder.decode(forKey: "rawVariables") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["rawVariables"])); fatalError() }; self.rawVariables = rawVariables
            guard let rawMethods: [Method] = aDecoder.decode(forKey: "rawMethods") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["rawMethods"])); fatalError() }; self.rawMethods = rawMethods
            guard let rawSubscripts: [Subscript] = aDecoder.decode(forKey: "rawSubscripts") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["rawSubscripts"])); fatalError() }; self.rawSubscripts = rawSubscripts
            self.bodyBytesRange = aDecoder.decode(forKey: "bodyBytesRange")
            self.completeDeclarationRange = aDecoder.decode(forKey: "completeDeclarationRange")
            guard let annotations: Annotations = aDecoder.decode(forKey: "annotations") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["annotations"])); fatalError() }; self.annotations = annotations
            guard let documentation: Documentation = aDecoder.decode(forKey: "documentation") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["documentation"])); fatalError() }; self.documentation = documentation
            guard let inheritedTypes: [String] = aDecoder.decode(forKey: "inheritedTypes") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["inheritedTypes"])); fatalError() }; self.inheritedTypes = inheritedTypes
            guard let based: [String: String] = aDecoder.decode(forKey: "based") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["based"])); fatalError() }; self.based = based
            guard let basedTypes: [String: Type] = aDecoder.decode(forKey: "basedTypes") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["basedTypes"])); fatalError() }; self.basedTypes = basedTypes
            guard let inherits: [String: Type] = aDecoder.decode(forKey: "inherits") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["inherits"])); fatalError() }; self.inherits = inherits
            guard let implements: [String: Type] = aDecoder.decode(forKey: "implements") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["implements"])); fatalError() }; self.implements = implements
            guard let containedTypes: [Type] = aDecoder.decode(forKey: "containedTypes") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["containedTypes"])); fatalError() }; self.containedTypes = containedTypes
            guard let containedType: [String: Type] = aDecoder.decode(forKey: "containedType") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["containedType"])); fatalError() }; self.containedType = containedType
            self.parentName = aDecoder.decode(forKey: "parentName")
            self.parent = aDecoder.decode(forKey: "parent")
            self.supertype = aDecoder.decode(forKey: "supertype")
            guard let attributes: AttributeList = aDecoder.decode(forKey: "attributes") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["attributes"])); fatalError() }; self.attributes = attributes
            guard let modifiers: [SourceryModifier] = aDecoder.decode(forKey: "modifiers") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["modifiers"])); fatalError() }; self.modifiers = modifiers
            self.path = aDecoder.decode(forKey: "path")
            self.fileName = aDecoder.decode(forKey: "fileName")
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.module, forKey: "module")
            aCoder.encode(self.imports, forKey: "imports")
            aCoder.encode(self.typealiases, forKey: "typealiases")
            aCoder.encode(self.isExtension, forKey: "isExtension")
            aCoder.encode(self.accessLevel, forKey: "accessLevel")
            aCoder.encode(self.isGeneric, forKey: "isGeneric")
            aCoder.encode(self.localName, forKey: "localName")
            aCoder.encode(self.rawVariables, forKey: "rawVariables")
            aCoder.encode(self.rawMethods, forKey: "rawMethods")
            aCoder.encode(self.rawSubscripts, forKey: "rawSubscripts")
            aCoder.encode(self.bodyBytesRange, forKey: "bodyBytesRange")
            aCoder.encode(self.completeDeclarationRange, forKey: "completeDeclarationRange")
            aCoder.encode(self.annotations, forKey: "annotations")
            aCoder.encode(self.documentation, forKey: "documentation")
            aCoder.encode(self.inheritedTypes, forKey: "inheritedTypes")
            aCoder.encode(self.based, forKey: "based")
            aCoder.encode(self.basedTypes, forKey: "basedTypes")
            aCoder.encode(self.inherits, forKey: "inherits")
            aCoder.encode(self.implements, forKey: "implements")
            aCoder.encode(self.containedTypes, forKey: "containedTypes")
            aCoder.encode(self.containedType, forKey: "containedType")
            aCoder.encode(self.parentName, forKey: "parentName")
            aCoder.encode(self.parent, forKey: "parent")
            aCoder.encode(self.supertype, forKey: "supertype")
            aCoder.encode(self.attributes, forKey: "attributes")
            aCoder.encode(self.modifiers, forKey: "modifiers")
            aCoder.encode(self.path, forKey: "path")
            aCoder.encode(self.fileName, forKey: "fileName")
        }
// sourcery:end
}

extension Type {

    // sourcery: skipDescription, skipJSExport
    /// :nodoc:
    var isClass: Bool {
        let isNotClass = self is Struct || self is Enum || self is Protocol
        return !isNotClass && !isExtension
    }
}

/// Extends type so that inner types can be accessed via KVC e.g. Parent.Inner.Children
extension Type {
    /// :nodoc:
    override public func value(forUndefinedKey key: String) -> Any? {
        if let innerType = containedTypes.lazy.filter({ $0.localName == key }).first {
            return innerType
        }

        return super.value(forUndefinedKey: key)
    }
}

"""),
    .init(name: "TypeName.swift", content:
"""
//
// Created by Krzysztof Zabłocki on 25/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

/// Describes name of the type used in typed declaration (variable, method parameter or return value etc.)
@objcMembers public final class TypeName: NSObject, SourceryModelWithoutDescription, LosslessStringConvertible {
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
//            description.append("<\\(arguments)>")
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

// sourcery:inline:TypeName.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            self.generic = aDecoder.decode(forKey: "generic")
            self.isProtocolComposition = aDecoder.decode(forKey: "isProtocolComposition")
            self.actualTypeName = aDecoder.decode(forKey: "actualTypeName")
            guard let attributes: AttributeList = aDecoder.decode(forKey: "attributes") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["attributes"])); fatalError() }; self.attributes = attributes
            guard let modifiers: [SourceryModifier] = aDecoder.decode(forKey: "modifiers") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["modifiers"])); fatalError() }; self.modifiers = modifiers
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
            Log.astWarning("Unknown type, please add type attribution to \\(description)")
        } else {
            Log.astWarning("Unknown type, please add type attribution")
        }
        return TypeName(name: "UnknownTypeSoAddTypeAttributionToVariable", attributes: attributes)
    }
}

"""),
    .init(name: "Typealias.swift", content:
"""
import Foundation

// sourcery: skipJSExport
/// :nodoc:
@objcMembers public final class Typealias: NSObject, Typed, SourceryModel {
    // New typealias name
    public let aliasName: String

    // Target name
    public let typeName: TypeName

    // sourcery: skipEquality, skipDescription
    public var type: Type?

    /// module in which this typealias was declared
    public var module: String?

    // sourcery: skipEquality, skipDescription
    public var parent: Type? {
        didSet {
            parentName = parent?.name
        }
    }

    /// Type access level, i.e. `internal`, `private`, `fileprivate`, `public`, `open`
    public let accessLevel: String

    var parentName: String?

    public var name: String {
        if let parentName = parent?.name {
            return "\\(module != nil ? "\\(module!)." : "")\\(parentName).\\(aliasName)"
        } else {
            return "\\(module != nil ? "\\(module!)." : "")\\(aliasName)"
        }
    }

    public init(aliasName: String = "", typeName: TypeName, accessLevel: AccessLevel = .internal, parent: Type? = nil, module: String? = nil) {
        self.aliasName = aliasName
        self.typeName = typeName
        self.accessLevel = accessLevel.rawValue
        self.parent = parent
        self.parentName = parent?.name
        self.module = module
    }

// sourcery:inline:Typealias.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let aliasName: String = aDecoder.decode(forKey: "aliasName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["aliasName"])); fatalError() }; self.aliasName = aliasName
            guard let typeName: TypeName = aDecoder.decode(forKey: "typeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typeName"])); fatalError() }; self.typeName = typeName
            self.type = aDecoder.decode(forKey: "type")
            self.module = aDecoder.decode(forKey: "module")
            self.parent = aDecoder.decode(forKey: "parent")
            guard let accessLevel: String = aDecoder.decode(forKey: "accessLevel") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["accessLevel"])); fatalError() }; self.accessLevel = accessLevel
            self.parentName = aDecoder.decode(forKey: "parentName")
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.aliasName, forKey: "aliasName")
            aCoder.encode(self.typeName, forKey: "typeName")
            aCoder.encode(self.type, forKey: "type")
            aCoder.encode(self.module, forKey: "module")
            aCoder.encode(self.parent, forKey: "parent")
            aCoder.encode(self.accessLevel, forKey: "accessLevel")
            aCoder.encode(self.parentName, forKey: "parentName")
        }
// sourcery:end
}

"""),
    .init(name: "Typed.generated.swift", content:
"""
// Generated using Sourcery 1.8.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable vertical_whitespace


extension AssociatedValue {
    /// Whether type is optional. Shorthand for `typeName.isOptional`
    public var isOptional: Bool { return typeName.isOptional }
    /// Whether type is implicitly unwrapped optional. Shorthand for `typeName.isImplicitlyUnwrappedOptional`
    public var isImplicitlyUnwrappedOptional: Bool { return typeName.isImplicitlyUnwrappedOptional }
    /// Type name without attributes and optional type information. Shorthand for `typeName.unwrappedTypeName`
    public var unwrappedTypeName: String { return typeName.unwrappedTypeName }
    /// Actual type name if declaration uses typealias, otherwise just a `typeName`. Shorthand for `typeName.actualTypeName`
    public var actualTypeName: TypeName? { return typeName.actualTypeName ?? typeName }
    /// Whether type is a tuple. Shorthand for `typeName.isTuple`
    public var isTuple: Bool { return typeName.isTuple }
    /// Whether type is a closure. Shorthand for `typeName.isClosure`
    public var isClosure: Bool { return typeName.isClosure }
    /// Whether type is an array. Shorthand for `typeName.isArray`
    public var isArray: Bool { return typeName.isArray }
    /// Whether type is a dictionary. Shorthand for `typeName.isDictionary`
    public var isDictionary: Bool { return typeName.isDictionary }
}
extension ClosureParameter {
    /// Whether type is optional. Shorthand for `typeName.isOptional`
    public var isOptional: Bool { return typeName.isOptional }
    /// Whether type is implicitly unwrapped optional. Shorthand for `typeName.isImplicitlyUnwrappedOptional`
    public var isImplicitlyUnwrappedOptional: Bool { return typeName.isImplicitlyUnwrappedOptional }
    /// Type name without attributes and optional type information. Shorthand for `typeName.unwrappedTypeName`
    public var unwrappedTypeName: String { return typeName.unwrappedTypeName }
    /// Actual type name if declaration uses typealias, otherwise just a `typeName`. Shorthand for `typeName.actualTypeName`
    public var actualTypeName: TypeName? { return typeName.actualTypeName ?? typeName }
    /// Whether type is a tuple. Shorthand for `typeName.isTuple`
    public var isTuple: Bool { return typeName.isTuple }
    /// Whether type is a closure. Shorthand for `typeName.isClosure`
    public var isClosure: Bool { return typeName.isClosure }
    /// Whether type is an array. Shorthand for `typeName.isArray`
    public var isArray: Bool { return typeName.isArray }
    /// Whether type is a dictionary. Shorthand for `typeName.isDictionary`
    public var isDictionary: Bool { return typeName.isDictionary }
}
extension MethodParameter {
    /// Whether type is optional. Shorthand for `typeName.isOptional`
    public var isOptional: Bool { return typeName.isOptional }
    /// Whether type is implicitly unwrapped optional. Shorthand for `typeName.isImplicitlyUnwrappedOptional`
    public var isImplicitlyUnwrappedOptional: Bool { return typeName.isImplicitlyUnwrappedOptional }
    /// Type name without attributes and optional type information. Shorthand for `typeName.unwrappedTypeName`
    public var unwrappedTypeName: String { return typeName.unwrappedTypeName }
    /// Actual type name if declaration uses typealias, otherwise just a `typeName`. Shorthand for `typeName.actualTypeName`
    public var actualTypeName: TypeName? { return typeName.actualTypeName ?? typeName }
    /// Whether type is a tuple. Shorthand for `typeName.isTuple`
    public var isTuple: Bool { return typeName.isTuple }
    /// Whether type is a closure. Shorthand for `typeName.isClosure`
    public var isClosure: Bool { return typeName.isClosure }
    /// Whether type is an array. Shorthand for `typeName.isArray`
    public var isArray: Bool { return typeName.isArray }
    /// Whether type is a dictionary. Shorthand for `typeName.isDictionary`
    public var isDictionary: Bool { return typeName.isDictionary }
}
extension TupleElement {
    /// Whether type is optional. Shorthand for `typeName.isOptional`
    public var isOptional: Bool { return typeName.isOptional }
    /// Whether type is implicitly unwrapped optional. Shorthand for `typeName.isImplicitlyUnwrappedOptional`
    public var isImplicitlyUnwrappedOptional: Bool { return typeName.isImplicitlyUnwrappedOptional }
    /// Type name without attributes and optional type information. Shorthand for `typeName.unwrappedTypeName`
    public var unwrappedTypeName: String { return typeName.unwrappedTypeName }
    /// Actual type name if declaration uses typealias, otherwise just a `typeName`. Shorthand for `typeName.actualTypeName`
    public var actualTypeName: TypeName? { return typeName.actualTypeName ?? typeName }
    /// Whether type is a tuple. Shorthand for `typeName.isTuple`
    public var isTuple: Bool { return typeName.isTuple }
    /// Whether type is a closure. Shorthand for `typeName.isClosure`
    public var isClosure: Bool { return typeName.isClosure }
    /// Whether type is an array. Shorthand for `typeName.isArray`
    public var isArray: Bool { return typeName.isArray }
    /// Whether type is a dictionary. Shorthand for `typeName.isDictionary`
    public var isDictionary: Bool { return typeName.isDictionary }
}
extension Typealias {
    /// Whether type is optional. Shorthand for `typeName.isOptional`
    public var isOptional: Bool { return typeName.isOptional }
    /// Whether type is implicitly unwrapped optional. Shorthand for `typeName.isImplicitlyUnwrappedOptional`
    public var isImplicitlyUnwrappedOptional: Bool { return typeName.isImplicitlyUnwrappedOptional }
    /// Type name without attributes and optional type information. Shorthand for `typeName.unwrappedTypeName`
    public var unwrappedTypeName: String { return typeName.unwrappedTypeName }
    /// Actual type name if declaration uses typealias, otherwise just a `typeName`. Shorthand for `typeName.actualTypeName`
    public var actualTypeName: TypeName? { return typeName.actualTypeName ?? typeName }
    /// Whether type is a tuple. Shorthand for `typeName.isTuple`
    public var isTuple: Bool { return typeName.isTuple }
    /// Whether type is a closure. Shorthand for `typeName.isClosure`
    public var isClosure: Bool { return typeName.isClosure }
    /// Whether type is an array. Shorthand for `typeName.isArray`
    public var isArray: Bool { return typeName.isArray }
    /// Whether type is a dictionary. Shorthand for `typeName.isDictionary`
    public var isDictionary: Bool { return typeName.isDictionary }
}
extension Variable {
    /// Whether type is optional. Shorthand for `typeName.isOptional`
    public var isOptional: Bool { return typeName.isOptional }
    /// Whether type is implicitly unwrapped optional. Shorthand for `typeName.isImplicitlyUnwrappedOptional`
    public var isImplicitlyUnwrappedOptional: Bool { return typeName.isImplicitlyUnwrappedOptional }
    /// Type name without attributes and optional type information. Shorthand for `typeName.unwrappedTypeName`
    public var unwrappedTypeName: String { return typeName.unwrappedTypeName }
    /// Actual type name if declaration uses typealias, otherwise just a `typeName`. Shorthand for `typeName.actualTypeName`
    public var actualTypeName: TypeName? { return typeName.actualTypeName ?? typeName }
    /// Whether type is a tuple. Shorthand for `typeName.isTuple`
    public var isTuple: Bool { return typeName.isTuple }
    /// Whether type is a closure. Shorthand for `typeName.isClosure`
    public var isClosure: Bool { return typeName.isClosure }
    /// Whether type is an array. Shorthand for `typeName.isArray`
    public var isArray: Bool { return typeName.isArray }
    /// Whether type is a dictionary. Shorthand for `typeName.isDictionary`
    public var isDictionary: Bool { return typeName.isDictionary }
}

"""),
    .init(name: "Typed.swift", content:
"""
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

"""),
    .init(name: "Variable.swift", content:
"""
//
// Created by Krzysztof Zablocki on 13/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

/// :nodoc:
public typealias SourceryVariable = Variable

/// Defines variable
@objcMembers public final class Variable: NSObject, SourceryModel, Typed, Annotated, Documented, Definition {
    /// Variable name
    public let name: String

    /// Variable type name
    public let typeName: TypeName

    // sourcery: skipEquality, skipDescription
    /// Variable type, if known, i.e. if the type is declared in the scanned sources.
    /// For explanation, see <https://cdn.rawgit.com/krzysztofzablocki/Sourcery/master/docs/writing-templates.html#what-are-em-known-em-and-em-unknown-em-types>
    public var type: Type?

    /// Whether variable is computed and not stored
    public let isComputed: Bool
    
    /// Whether variable is async
    public let isAsync: Bool
    
    /// Whether variable throws
    public let `throws`: Bool

    /// Whether variable is static
    public let isStatic: Bool

    /// Variable read access level, i.e. `internal`, `private`, `fileprivate`, `public`, `open`
    public let readAccess: String

    /// Variable write access, i.e. `internal`, `private`, `fileprivate`, `public`, `open`.
    /// For immutable variables this value is empty string
    public let writeAccess: String

    /// composed access level
    /// sourcery: skipJSExport
    public var accessLevel: (read: AccessLevel, write: AccessLevel) {
        (read: AccessLevel(rawValue: readAccess) ?? .none, AccessLevel(rawValue: writeAccess) ?? .none)
    }

    /// Whether variable is mutable or not
    public var isMutable: Bool {
        return writeAccess != AccessLevel.none.rawValue
    }

    /// Variable default value expression
    public var defaultValue: String?

    /// Annotations, that were created with // sourcery: annotation1, other = "annotation value", alterantive = 2
    public var annotations: Annotations = [:]

    public var documentation: Documentation = []

    /// Variable attributes, i.e. `@IBOutlet`, `@IBInspectable`
    public var attributes: AttributeList

    /// Modifiers, i.e. `private`
    public var modifiers: [SourceryModifier]

    /// Whether variable is final or not
    public var isFinal: Bool {
        return modifiers.contains { $0.name == "final" }
    }

    /// Whether variable is lazy or not
    public var isLazy: Bool {
        return modifiers.contains { $0.name == "lazy" }
    }

    /// Reference to type name where the variable is defined,
    /// nil if defined outside of any `enum`, `struct`, `class` etc
    public internal(set) var definedInTypeName: TypeName?

    /// Reference to actual type name where the method is defined if declaration uses typealias, otherwise just a `definedInTypeName`
    public var actualDefinedInTypeName: TypeName? {
        return definedInTypeName?.actualTypeName ?? definedInTypeName
    }

    // sourcery: skipEquality, skipDescription
    /// Reference to actual type where the object is defined,
    /// nil if defined outside of any `enum`, `struct`, `class` etc or type is unknown
    public var definedInType: Type?

    /// :nodoc:
    public init(name: String = "",
                typeName: TypeName,
                type: Type? = nil,
                accessLevel: (read: AccessLevel, write: AccessLevel) = (.internal, .internal),
                isComputed: Bool = false,
                isAsync: Bool = false,
                `throws`: Bool = false,
                isStatic: Bool = false,
                defaultValue: String? = nil,
                attributes: AttributeList = [:],
                modifiers: [SourceryModifier] = [],
                annotations: [String: NSObject] = [:],
                documentation: [String] = [],
                definedInTypeName: TypeName? = nil) {

        self.name = name
        self.typeName = typeName
        self.type = type
        self.isComputed = isComputed
        self.isAsync = isAsync
        self.`throws` = `throws`
        self.isStatic = isStatic
        self.defaultValue = defaultValue
        self.readAccess = accessLevel.read.rawValue
        self.writeAccess = accessLevel.write.rawValue
        self.attributes = attributes
        self.modifiers = modifiers
        self.annotations = annotations
        self.documentation = documentation
        self.definedInTypeName = definedInTypeName
    }

// sourcery:inline:Variable.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let typeName: TypeName = aDecoder.decode(forKey: "typeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typeName"])); fatalError() }; self.typeName = typeName
            self.type = aDecoder.decode(forKey: "type")
            self.isComputed = aDecoder.decode(forKey: "isComputed")
            self.isAsync = aDecoder.decode(forKey: "isAsync")
            self.`throws` = aDecoder.decode(forKey: "`throws`")
            self.isStatic = aDecoder.decode(forKey: "isStatic")
            guard let readAccess: String = aDecoder.decode(forKey: "readAccess") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["readAccess"])); fatalError() }; self.readAccess = readAccess
            guard let writeAccess: String = aDecoder.decode(forKey: "writeAccess") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["writeAccess"])); fatalError() }; self.writeAccess = writeAccess
            self.defaultValue = aDecoder.decode(forKey: "defaultValue")
            guard let annotations: Annotations = aDecoder.decode(forKey: "annotations") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["annotations"])); fatalError() }; self.annotations = annotations
            guard let documentation: Documentation = aDecoder.decode(forKey: "documentation") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["documentation"])); fatalError() }; self.documentation = documentation
            guard let attributes: AttributeList = aDecoder.decode(forKey: "attributes") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["attributes"])); fatalError() }; self.attributes = attributes
            guard let modifiers: [SourceryModifier] = aDecoder.decode(forKey: "modifiers") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["modifiers"])); fatalError() }; self.modifiers = modifiers
            self.definedInTypeName = aDecoder.decode(forKey: "definedInTypeName")
            self.definedInType = aDecoder.decode(forKey: "definedInType")
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.typeName, forKey: "typeName")
            aCoder.encode(self.type, forKey: "type")
            aCoder.encode(self.isComputed, forKey: "isComputed")
            aCoder.encode(self.isAsync, forKey: "isAsync")
            aCoder.encode(self.`throws`, forKey: "`throws`")
            aCoder.encode(self.isStatic, forKey: "isStatic")
            aCoder.encode(self.readAccess, forKey: "readAccess")
            aCoder.encode(self.writeAccess, forKey: "writeAccess")
            aCoder.encode(self.defaultValue, forKey: "defaultValue")
            aCoder.encode(self.annotations, forKey: "annotations")
            aCoder.encode(self.documentation, forKey: "documentation")
            aCoder.encode(self.attributes, forKey: "attributes")
            aCoder.encode(self.modifiers, forKey: "modifiers")
            aCoder.encode(self.definedInTypeName, forKey: "definedInTypeName")
            aCoder.encode(self.definedInType, forKey: "definedInType")
        }
// sourcery:end
}

"""),
]
