//
// Created by Krzysztof Zablocki on 31/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import SourceryRuntime
import SourceryUtils

/// Responsible for composing results of `FileParser`.
public enum Composer {

    /// Performs final processing of discovered types:
    /// - extends types with their corresponding extensions;
    /// - replaces typealiases with actual types
    /// - finds actual types for variables and enums raw values
    /// - filters out any private types and extensions
    ///
    /// - Parameter parserResult: Result of parsing source code.
    /// - Returns: Final types and extensions of unknown types.
    public static func uniqueTypesAndFunctions(_ parserResult: FileParserResult) -> (types: [Type], functions: [SourceryMethod], typealiases: [Typealias]) {
        var unique = [String: Type]()
        var modules = [String: [String: Type]]()
        let parsedTypes = parserResult.types
        let functions = parserResult.functions
        let (resolvedTypealiases, unresolvedTypealiases) = self.typealiases(parserResult)

        //set definedInType for all methods and variables
        parsedTypes
            .forEach { type in
                type.variables.forEach { $0.definedInType = type }
                type.methods.forEach { $0.definedInType = type }
                type.subscripts.forEach { $0.definedInType = type }
            }

        //map all known types to their names
        parsedTypes
            .filter { $0.isExtension == false}
            .forEach {
                unique[$0.globalName] = $0
                if let module = $0.module {
                    var typesByModules = modules[module, default: [:]]
                    typesByModules[$0.name] = $0
                    modules[module] = typesByModules
                }
            }

        //replace extensions for type aliases with original types
        //extract all methods and variables from extensions
        parsedTypes
            .filter { $0.isExtension == true }
            .forEach {
                $0.localName = actualTypeName(for: TypeName($0.name), modules: modules, typealiases: resolvedTypealiases) ?? $0.localName
            }

        //extend all types with their extensions
        parsedTypes.forEach { type in
            type.inheritedTypes = type.inheritedTypes.map { actualTypeName(for: TypeName($0), modules: modules, typealiases: resolvedTypealiases) ?? $0 }

            let uniqueType = unique[type.globalName] ??
                typeFromModule(type.name, modules: modules) ??
                type.imports.lazy.compactMap { modules[$0.moduleName]?[type.name] }.first

            guard let current = uniqueType else {
                // for unknown types we still store their extensions but mark them as unknown
                type.isUnknownExtension = true
                unique[type.globalName] = type

                let inheritanceClause = type.inheritedTypes.isEmpty ? "" :
                    ": \(type.inheritedTypes.joined(separator: ", "))"

                Log.astWarning("Found \"extension \(type.name)\(inheritanceClause)\" of type for which there is no original type declaration information.")
                return
            }

            if current == type { return }

            current.extend(type)
            unique[current.globalName] = current
        }

        let resolutionStart = currentTimestamp()

        let resolveType = { (typeName: TypeName, containingType: Type?) -> Type? in
            return self.resolveType(typeName: typeName, containingType: containingType, unique: unique, modules: modules, typealiases: resolvedTypealiases)
        }

        let types = Array(unique.values)
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
                resolveEnumTypes(enumeration, types: unique, resolve: resolveType)
            }

            if let composition = type as? ProtocolComposition {
                resolveProtocolCompositionTypes(composition, resolve: resolveType)
            }

            if let sourceryProtocol = type as? SourceryProtocol {
                resolveProtocolTypes(sourceryProtocol, resolve: resolveType)
            }
        }

        functions.parallelPerform { function in
            resolveMethodTypes(function, of: nil, resolve: resolveType)
        }

        let typealiases = Array(unresolvedTypealiases.values)
        typealiases.parallelPerform { alias in
            alias.type = resolveType(alias.typeName, nil)
        }

        Log.benchmark("\tresolution took \(currentTimestamp() - resolutionStart)")

        updateTypeRelationships(types: types)
        return (
            types: types.sorted { $0.globalName < $1.globalName },
            functions: functions.sorted { $0.name < $1.name },
            typealiases: typealiases.sorted(by: { $0.name < $1.name })
        )
    }

    private static func resolveType(typeName: TypeName, containingType: Type?, unique: [String: Type], modules: [String: [String: Type]], typealiases: [String: Typealias]) -> Type? {
        let actualTypeName = self.actualTypeName(for: typeName, containingType: containingType, unique: unique, modules: modules, typealiases: typealiases)
        if let actualTypeName = actualTypeName, actualTypeName != typeName.unwrappedTypeName {
            typeName.actualTypeName = TypeName(actualTypeName)
        }

        let lookupName = typeName.actualTypeName ?? typeName

        let resolveTypeWithName = { (typeName: TypeName) -> Type? in
            return self.resolveType(typeName: typeName, containingType: containingType, unique: unique, modules: modules, typealiases: typealiases)
        }

        // should we also set these types on lookupName?
        if let array = lookupName.arrayType {
            lookupName.array = array
            array.elementType = resolveTypeWithName(array.elementTypeName)
            lookupName.generic = GenericType(name: "Array", typeParameters: [
                GenericTypeParameter(typeName: array.elementTypeName, type: array.elementType)
                ])
        } else if let dictionary = lookupName.dictionaryType {
            lookupName.dictionary = dictionary
            dictionary.valueType = resolveTypeWithName(dictionary.valueTypeName)
            dictionary.keyType = resolveTypeWithName(dictionary.keyTypeName)
            lookupName.generic = GenericType(name: "Dictionary", typeParameters: [
                GenericTypeParameter(typeName: dictionary.keyTypeName, type: dictionary.keyType),
                GenericTypeParameter(typeName: dictionary.valueTypeName, type: dictionary.valueType)
                ])
        } else if let tuple = lookupName.tupleType {
            lookupName.tuple = tuple
            tuple.elements.forEach { tupleElement in
                tupleElement.type = resolveTypeWithName(tupleElement.typeName)
            }
        } else if let closure = lookupName.closureType {
            lookupName.closure = closure
            closure.returnType = resolveTypeWithName(closure.returnTypeName)
            closure.parameters.forEach({ parameter in
                parameter.type = resolveTypeWithName(parameter.typeName)
            })
        } else if let generic = lookupName.genericType {
            // should also set generic data for optional types
            lookupName.generic = generic
            generic.typeParameters.forEach {typeParameter in
                typeParameter.type = resolveTypeWithName(typeParameter.typeName)
            }
        }

        typeName.array = lookupName.array
        typeName.dictionary = lookupName.dictionary
        typeName.tuple = lookupName.tuple
        typeName.closure = lookupName.closure
        typeName.generic = lookupName.generic

        let resolvedTypeName = lookupName.generic?.name ?? lookupName.unwrappedTypeName
        return unique[resolvedTypeName] ?? typeFromModule(resolvedTypeName, modules: modules)
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
            if let actualDefinedInTypeName = method.actualDefinedInTypeName {
                if method.isFailableInitializer {
                    method.returnTypeName = TypeName("\(actualDefinedInTypeName.name)?")
                } else if method.isInitializer {
                    method.returnTypeName = actualDefinedInTypeName
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

    

    /// returns typealiases map to their full names, with `resolved` removing intermediate
    /// typealises and `unresolved` including typealiases that reference other typealiases.
    private static func typealiases(_ parserResult: FileParserResult) -> (resolved: [String: Typealias], unresolved: [String: Typealias]) {
        var typealiasesByNames = [String: Typealias]()
        parserResult.typealiases.forEach { typealiasesByNames[$0.name] = $0 }
        parserResult.types.forEach { type in
            type.typealiases.forEach({ (_, alias) in
                typealiasesByNames[alias.name] = alias
            })
        }

        let unresolved = typealiasesByNames

        //! if a typealias leads to another typealias, follow through and replace with final type
        typealiasesByNames.forEach { _, alias in
            var aliasNamesToReplace = [alias.name]
            var finalAlias = alias
            while let targetAlias = typealiasesByNames[finalAlias.typeName.name] {
                aliasNamesToReplace.append(targetAlias.name)
                finalAlias = targetAlias
            }

            //! replace all keys
            aliasNamesToReplace.forEach { typealiasesByNames[$0] = finalAlias }
        }

        return (resolved: typealiasesByNames, unresolved: unresolved)
    }

    /// returns actual type name for type alias
    private static func actualTypeName(for typeName: TypeName, containingType: Type? = nil, unique: [String: Type]? = nil, modules: [String: [String: Type]], typealiases: [String: Typealias]) -> String? {
        let optionalPrefix = typeName.isOptional ? "?" : typeName.isImplicitlyUnwrappedOptional ? "!" : ""
        let unwrappedTypeName = typeName.unwrappedTypeName
        var actualTypeName: String?

        // first try global typealiases
        if let name = typealiases[unwrappedTypeName]?.typeName.name {
            actualTypeName = name
        }

        if let containingType = containingType {
            // check if self
            if typeName.unwrappedTypeName == "Self" {
                actualTypeName = containingType.globalName
            }
            // check if typealias is for one of contained types
            else if let possibleTypeName = typealiases["\(containingType.globalName).\(unwrappedTypeName)"]?.typeName.name {
                let containedType = containingType.containedTypes.first(where: {
                    $0.name == "\(containingType.name).\(possibleTypeName)" || $0.name == possibleTypeName
                })

                actualTypeName = containedType?.name ?? possibleTypeName
            } else {
                if let name = unique?["\(containingType.globalName).\(unwrappedTypeName)"]?.globalName {
                    //check contained types first
                    actualTypeName = name
                } else {
                    //otherwise go up contained types chain to find a type
                    let parentTypes = containingType.parentTypes
                    while let parent = parentTypes.next() {
                        if let name = unique?["\(parent.globalName).\(unwrappedTypeName)"]?.globalName {
                            actualTypeName = name
                            break
                        }
                    }

                    if actualTypeName == nil {
                        actualTypeName = inferActualTypename(from: typeName, containedInType: containingType, uniqueTypes: unique ?? [:], modules: modules)
                    }
                    actualTypeName = actualTypeName ?? unwrappedTypeName
                }
            }
        }

        if var actualTypeName = actualTypeName {
            if unwrappedTypeName.isValidTupleName() {
                let elements = typeName.unwrappedTypeName.dropFirstAndLast().commaSeparated()
                var actualElements = [String]()
                for element in elements {
                    let nameAndValue = element.colonSeparated().map({ $0.trimmingCharacters(in: .whitespaces) })
                    if nameAndValue.count == 1 {
                        let valueName = self.actualTypeName(for: TypeName(nameAndValue[0]), containingType: containingType, unique: unique, modules: modules, typealiases: typealiases)
                        actualElements.append(valueName ?? nameAndValue[0])
                    } else {
                        let valueName = self.actualTypeName(for: TypeName(nameAndValue[1]), containingType: containingType, unique: unique, modules: modules, typealiases: typealiases)
                        actualElements.append("\(nameAndValue[0]): \(valueName ?? nameAndValue[1])")
                    }
                }
                actualTypeName = "(\(actualElements.joined(separator: ", ")))"
            } else if unwrappedTypeName.first == "[", unwrappedTypeName.last == "]" {
                let types = unwrappedTypeName.dropFirstAndLast()
                    .colonSeparated()
                    .map({ $0.trimmingCharacters(in: .whitespaces) })
                if types.count == 1 {
                    //array literal
                    let name = self.actualTypeName(for: TypeName(types[0]), containingType: containingType, unique: unique, modules: modules, typealiases: typealiases)
                    actualTypeName = "[\(name ?? types[0])]"
                } else {
                    //dictionary literal
                    let keyName = self.actualTypeName(for: TypeName(types[0]), containingType: containingType, unique: unique, modules: modules, typealiases: typealiases)
                    let valueName = self.actualTypeName(for: TypeName(types[1]), containingType: containingType, unique: unique, modules: modules, typealiases: typealiases)
                    actualTypeName = "[\(keyName ?? types[0]): \(valueName ?? types[1])]"
                }
            } else if let genericStartIndex = unwrappedTypeName.firstIndex(of: "<"), unwrappedTypeName.last == ">" {
                let genericTypeNameString = String(unwrappedTypeName.prefix(upTo: genericStartIndex))
                let genericTypeName = self.actualTypeName(for: TypeName(genericTypeNameString), containingType: containingType, unique: unique, modules: modules, typealiases: typealiases)

                let typeParametersString = unwrappedTypeName.suffix(from: genericStartIndex).dropFirst().dropLast()
                let typeParameters = String(typeParametersString).commaSeparated()
                var actualTypeParameters = [String]()
                for typeParameter in typeParameters {
                    if let typeName = self.actualTypeName(for: TypeName(typeParameter), containingType: containingType, unique: unique, modules: modules, typealiases: typealiases) {
                        actualTypeParameters.append(typeName)
                    } else {
                        actualTypeParameters.append(typeParameter)
                    }
                }
                actualTypeName = "\(genericTypeName ?? genericTypeNameString)<\(actualTypeParameters.joined(separator: ", "))>"
            }
            return actualTypeName + optionalPrefix
        } else {
            return nil
        }
    }

    private static func inferActualTypename(from typename: TypeName, containedInType: Type?, uniqueTypes: [String: Type], modules: [String: [String: Type]]) -> String? {
        let unwrappedTypeName = typename.unwrappedTypeName

        func fullName(for module: String) -> String {
            "\(module).\(unwrappedTypeName)"
        }

        func type(for module: String) -> Type? {
            return modules[module]?[unwrappedTypeName]
        }

        func ambiguousErrorMessage(from types: [Type]) -> String? {
            Log.astWarning("Ambiguous type \(typename), found \(types.map { $0.globalName }.joined(separator: ", ")). Specify module name at declaration site to disambiguate.")
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
        let moduleSetsToCheck: [Array<String>] = [
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
                type.implements[globalName] = baseType
            }
        }
    }

    static func typeFromModule(_ name: String, modules: [String: [String: Type]]) -> Type? {
        guard name.contains(".") else { return nil }
        let nameComponents = name.components(separatedBy: ".")
        let moduleName = nameComponents[0]
        let typeName = nameComponents.suffix(from: 1).joined(separator: ".")
        return modules[moduleName]?[typeName]
    }

    /// Extracts list of type names from composition e.g. `ProtocolA & ProtocolB`
    internal static func extractComposedTypeNames(from value: String, trimmingCharacterSet: CharacterSet? = nil) -> [TypeName]? {
        guard case let components = value.components(separatedBy: CharacterSet(charactersIn: "&")),
              components.count > 1 else { return nil }

        var characterSet: CharacterSet = .whitespacesAndNewlines
        if let trimmingCharacterSet = trimmingCharacterSet {
            characterSet = characterSet.union(trimmingCharacterSet)
        }

        let suffixes = components.map { source in
            source.trimmingCharacters(in: characterSet)
        }
        return suffixes.map { TypeName($0) }
    }
}
