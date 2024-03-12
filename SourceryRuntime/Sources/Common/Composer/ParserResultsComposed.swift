//
// Created by Krzysztof Zablocki on 31/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

internal struct ParserResultsComposed {
    private(set) var typeMap = [String: Type]()
    private(set) var modules = [String: [String: Type]]()
    private(set) var types = [Type]()

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
            .filter { !$0.isExtension }
            .forEach {
                typeMap[$0.globalName] = $0
                if let module = $0.module {
                    var typesByModules = modules[module, default: [:]]
                    typesByModules[$0.name] = $0
                    modules[module] = typesByModules
                }
            }

        /// Resolve typealiases
        let typealiases = Array(unresolvedTypealiases.values)
        typealiases.forEach { alias in
            alias.type = resolveType(typeName: alias.typeName, containingType: alias.parent)
        }

        types = unifyTypes()
    }

    private func resolveExtensionOfNestedType(_ type: Type) {
        var components = type.localName.components(separatedBy: ".")
        let rootName = type.module ?? components.removeFirst() // Module/parent name
        if let moduleTypes = modules[rootName], let baseType = moduleTypes[components.joined(separator: ".")] ?? moduleTypes[type.localName] {
            type.localName = baseType.localName
            type.module = baseType.module
            type.parent = baseType.parent
        } else {
            for _import in type.imports {
                let parentKey = "\(rootName).\(components.joined(separator: "."))"
                let parentKeyFull = "\(_import.moduleName).\(parentKey)"
                if let moduleTypes = modules[_import.moduleName], let baseType = moduleTypes[parentKey] ?? moduleTypes[parentKeyFull] {
                    type.localName = baseType.localName
                    type.module = baseType.module
                    type.parent = baseType.parent
                    return
                }
            }
        }
    }

    // if it had contained types, they might have been fully defined and so their name has to be noted in uniques
    private mutating func rewriteChildren(of type: Type) {
        // child is never an extension so no need to check
        for child in type.containedTypes {
            typeMap[child.globalName] = child
            rewriteChildren(of: child)
        }
    }

    private mutating func unifyTypes() -> [Type] {
        /// Resolve actual names of extensions, as they could have been done on typealias and note updated child names in uniques if needed
        parsedTypes
            .filter { $0.isExtension }
            .forEach { (type: Type) in
                let oldName = type.globalName

                let hasDotInLocalName = type.localName.contains(".") as Bool
                if let _ = type.parent, hasDotInLocalName {
                    resolveExtensionOfNestedType(type)
                }

                if let resolved = resolveGlobalName(for: oldName, containingType: type.parent, unique: typeMap, modules: modules, typealiases: resolvedTypealiases)?.name {
                    var moduleName: String = ""
                    if let module = type.module {
                        moduleName = "\(module)."
                    }
                    type.localName = resolved.replacingOccurrences(of: moduleName, with: "")
                } else {
                    return
                }

                // nothing left to do
                guard oldName != type.globalName else {
                    return
                }
                rewriteChildren(of: type)
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
                assert(type.isExtension, "Type \(type.globalName) should be extension")

                // for unknown types we still store their extensions but mark them as unknown
                type.isUnknownExtension = true
                if let existingType = typeMap[type.globalName] {
                    existingType.extend(type)
                    typeMap[type.globalName] = existingType
                } else {
                    typeMap[type.globalName] = type
                }

                let inheritanceClause = type.inheritedTypes.isEmpty ? "" :
                    ": \(type.inheritedTypes.joined(separator: ", "))"

                Log.astWarning("Found \"extension \(type.name)\(inheritanceClause)\" of type for which there is no original type declaration information.")
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
                if let name = resolveGlobalName(for: "\(parentName).\(type)", containingType: nil, unique: unique, modules: modules, typealiases: typealiases) {
                    return name
                }

                currentContainer = currentContainer?.parent
            }

//            if let name = resolveGlobalName(for: "\(containingType.globalName).\(type)", containingType: containingType.parent, unique: unique, modules: modules, typealiases: typealiases) {
//                return name
//            }

//             last check it's via module
//            if let module = containingType.module, let name = resolveGlobalName(for: "\(module).\(type)", containingType: nil, unique: unique, modules: modules, typealiases: typealiases) {
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
            "\(module).\(typeIdentifier)"
        }

        func type(for module: String) -> Type? {
            return modules[module]?[typeIdentifier]
        }

        func ambiguousErrorMessage(from types: [Type]) -> String? {
            Log.astWarning("Ambiguous type \(typeIdentifier), found \(types.map { $0.globalName }.joined(separator: ", ")). Specify module name at declaration site to disambiguate.")
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

    func resolveType(typeName: TypeName, containingType: Type?, method: Method? = nil) -> Type? {
        let resolveTypeWithName = { (typeName: TypeName) -> Type? in
            return self.resolveType(typeName: typeName, containingType: containingType)
        }

        let unique = typeMap

        if let name = typeName.actualTypeName {
            let resolvedIdentifier = name.generic?.name ?? name.unwrappedTypeName
            return unique[resolvedIdentifier]
        }

        let retrievedName = actualTypeName(for: typeName, containingType: containingType)
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
                                                   set: lookupName.set,
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
                                                   set: lookupName.set,
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
                                                   set: lookupName.set,
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
                                                   set: lookupName.set,
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

                typeName.actualTypeName = TypeName(name: "\(generic.name)<\(params)>",
                                                   isOptional: typeName.isOptional,
                                                   isImplicitlyUnwrappedOptional: typeName.isImplicitlyUnwrappedOptional,
                                                   tuple: lookupName.tuple,
                                                   array: lookupName.array, // TODO: asArray
                                                   dictionary: lookupName.dictionary, // TODO: asDictionary
                                                   closure: lookupName.closure,
                                                   set: lookupName.set,
                                                   generic: generic
                )
            }
        }

        if let aliasedName = (typeName.actualTypeName ?? retrievedName), aliasedName.unwrappedTypeName != typeName.unwrappedTypeName {
            typeName.actualTypeName = aliasedName
        }

        let hasGenericRequirements = containingType?.genericRequirements.isEmpty == false
        || (method != nil && method?.genericRequirements.isEmpty == false)

        if hasGenericRequirements {
            // we should consider if we are looking up return type of a method with generic constraints
            // where `typeName` passed would include `... where ...` suffix
            let typeNameForLookup = typeName.name.split(separator: " ").first!
            let genericRequirements: [GenericRequirement]
            if let requirements = containingType?.genericRequirements, !requirements.isEmpty {
                genericRequirements = requirements
            } else {
                genericRequirements = method?.genericRequirements ?? []
            }
            let relevantRequirements = genericRequirements.filter {
                // matched type against a generic requirement name
                // thus type should be replaced with a protocol composition
                $0.leftType.name == typeNameForLookup
            }
            if relevantRequirements.count > 1 {
                // compose protocols into `ProtocolComposition` and generate TypeName
                var implements: [String: Type] = [:]
                relevantRequirements.forEach {
                    implements[$0.rightType.typeName.name] = $0.rightType.type
                }
                let composedProtocols = ProtocolComposition(
                    inheritedTypes: relevantRequirements.map { $0.rightType.typeName.unwrappedTypeName },
                    isGeneric: true,
                    composedTypes: relevantRequirements.compactMap { $0.rightType.type },
                    implements: implements
                )
                typeName.actualTypeName = TypeName(name: "(\(relevantRequirements.map { $0.rightType.typeName.unwrappedTypeName }.joined(separator: " & ")))", isProtocolComposition: true)
                return composedProtocols
            } else if let protocolRequirement = relevantRequirements.first {
                // create TypeName off a single generic's protocol requirement
                typeName.actualTypeName = TypeName(name: "(\(protocolRequirement.rightType.typeName))")
                return protocolRequirement.rightType.type
            }
        }

        // try to peek into typealias, maybe part of the typeName is a composed identifier from a type and typealias
        // i.e.
        // enum Module {
        //   typealias ID = MyView
        // }
        // class MyView {
        //   class ID: String {}
        // }
        //
        // let variable: Module.ID.ID // should be resolved as MyView.ID type
        let finalLookup = typeName.actualTypeName ?? typeName
        var resolvedIdentifier = finalLookup.generic?.name ?? finalLookup.unwrappedTypeName
        for alias in resolvedTypealiases {
            /// iteratively replace all typealiases from the resolvedIdentifier to get to the actual type name requested
            if resolvedIdentifier.contains(alias.value.name), let range = resolvedIdentifier.range(of: alias.value.name) {
                resolvedIdentifier = resolvedIdentifier.replacingCharacters(in: range, with: alias.value.typeName.name)
            }
        }
        // should we cache resolved typenames?
        if unique[resolvedIdentifier] == nil {
            // peek into typealiases, if any of them contain the same typeName
            // this is done after the initial attempt in order to prioritise local (recognized) types first
            // before even trying to substitute the requested type with any typealias
            for alias in resolvedTypealiases {
                /// iteratively replace all typealiases from the resolvedIdentifier to get to the actual type name requested,
                /// ignoring namespacing
                if resolvedIdentifier == alias.value.aliasName {
                    resolvedIdentifier = alias.value.typeName.name
                    typeName.actualTypeName = alias.value.typeName
                    break
                }
            }
        }

        return unique[resolvedIdentifier]
    }

    private func actualTypeName(for typeName: TypeName,
                                       containingType: Type? = nil) -> TypeName? {
        let unique = typeMap
        let typealiases = resolvedTypealiases

        var unwrapped = typeName.unwrappedTypeName
        if let generic = typeName.generic {
            unwrapped = generic.name
        }

        guard let aliased = resolveGlobalName(for: unwrapped, containingType: containingType, unique: unique, modules: modules, typealiases: typealiases) else {
            return nil
        }

        /// TODO: verify
        let generic = typeName.generic.map { GenericType(name: $0.name, typeParameters: $0.typeParameters) }
        generic?.name = aliased.name
        let dictionary = typeName.dictionary.map { DictionaryType(name: $0.name, valueTypeName: $0.valueTypeName, valueType: $0.valueType, keyTypeName: $0.keyTypeName, keyType: $0.keyType) }
        dictionary?.name = aliased.name
        let array = typeName.array.map { ArrayType(name: $0.name, elementTypeName: $0.elementTypeName, elementType: $0.elementType) }
        array?.name = aliased.name
        let set = typeName.set.map { SetType(name: $0.name, elementTypeName: $0.elementTypeName, elementType: $0.elementType) }
        set?.name = aliased.name

        return TypeName(name: aliased.name,
                        isOptional: typeName.isOptional,
                        isImplicitlyUnwrappedOptional: typeName.isImplicitlyUnwrappedOptional,
                        tuple: aliased.typealias?.typeName.tuple ?? typeName.tuple, // TODO: verify
                        array: aliased.typealias?.typeName.array ?? array,
                        dictionary: aliased.typealias?.typeName.dictionary ?? dictionary,
                        closure: aliased.typealias?.typeName.closure ?? typeName.closure,
                        set: aliased.typealias?.typeName.set ?? set,
                        generic: aliased.typealias?.typeName.generic ?? generic
        )
    }

}
