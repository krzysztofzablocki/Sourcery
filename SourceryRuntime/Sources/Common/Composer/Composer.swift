//
// Created by Krzysztof Zablocki on 31/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

private func currentTimestamp() -> TimeInterval {
    return Date().timeIntervalSince1970
}

/// Responsible for composing results of `FileParser`.
public enum Composer {

    /// Performs final processing of discovered types:
    /// - extends types with their corresponding extensions;
    /// - replaces typealiases with actual types
    /// - finds actual types for variables and enums raw values
    /// - filters out any private types and extensions
    ///
    /// - Parameter parserResult: Result of parsing source code.
    /// - Parameter serial: Whether to process results serially instead of concurrently
    /// - Returns: Final types and extensions of unknown types.
    public static func uniqueTypesAndFunctions(_ parserResult: FileParserResult, serial: Bool = false) -> (types: [Type], functions: [SourceryMethod], typealiases: [Typealias]) {
        let composed = ParserResultsComposed(parserResult: parserResult)

        let resolveType = { (typeName: TypeName, containingType: Type?) -> Type? in
            return composed.resolveType(typeName: typeName, containingType: containingType)
        }

        let methodResolveType = { (typeName: TypeName, containingType: Type?, method: Method) -> Type? in
            return composed.resolveType(typeName: typeName, containingType: containingType, method: method)
        }

        let processType = { (type: Type) in
            type.variables.forEach {
                resolveVariableTypes($0, of: type, resolve: resolveType)
            }
            type.methods.forEach {
                resolveMethodTypes($0, of: type, resolve: methodResolveType)
            }
            type.subscripts.forEach {
                resolveSubscriptTypes($0, of: type, resolve: resolveType)
            }

            if let enumeration = type as? Enum {
                resolveEnumTypes(enumeration, types: composed.typeMap, resolve: resolveType)
            }

            if let composition = type as? ProtocolComposition {
                resolveProtocolCompositionTypes(composition, resolve: resolveType)
            }

            if let sourceryProtocol = type as? SourceryProtocol {
                resolveProtocolTypes(sourceryProtocol, resolve: resolveType)
            }
        }

        let processFunction = { (function: SourceryMethod) in
            resolveMethodTypes(function, of: nil, resolve: methodResolveType)
        }

        if serial {
            composed.types.forEach(processType)
            composed.functions.forEach(processFunction)
        } else {
            composed.types.parallelPerform(processType)
            composed.functions.parallelPerform(processFunction)
        }

        updateTypeRelationships(types: composed.types)

        return (
            types: composed.types.sorted { $0.globalName < $1.globalName },
            functions: composed.functions.sorted { $0.name < $1.name },
            typealiases: composed.unresolvedTypealiases.values.sorted(by: { $0.name < $1.name })
        )
    }

    typealias TypeResolver = (TypeName, Type?) -> Type?
    typealias MethodArgumentTypeResolver = (TypeName, Type?, Method) -> Type?

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

    private static func resolveMethodTypes(_ method: SourceryMethod, of type: Type?, resolve: MethodArgumentTypeResolver) {
        method.parameters.forEach { parameter in
            parameter.type = resolve(parameter.typeName, type, method)
        }

        /// The actual `definedInType` is assigned in `uniqueTypes` but we still
        /// need to resolve the type to correctly parse typealiases
        /// @see https://github.com/krzysztofzablocki/Sourcery/pull/374
        var definedInType: Type?
        if let definedInTypeName = method.definedInTypeName {
            definedInType = resolve(definedInTypeName, type, method)
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
                        set: type.set,
                        generic: type.generic,
                        isProtocolComposition: type.isProtocolComposition
                    )
                } else if method.isInitializer {
                    method.returnTypeName = type
                }
            }
        } else {
            method.returnType = resolve(method.returnTypeName, type, method)
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
        // special case to check if the type is based on one of the recognized types
        // and the superclass has a generic constraint in `name` part of the `TypeName`
        var name = name
        if name.contains("<") && name.contains(">") {
            let parts = name.split(separator: "<")
            name = String(parts.first!)
        }
        if let baseType = typesByName[name] {
            return baseType
        }
        if let module = type.module, let baseType = typesByName["\(module).\(name)"] {
            return baseType
        }
        for importModule in type.imports {
            if let baseType = typesByName["\(importModule).\(name)"] {
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
