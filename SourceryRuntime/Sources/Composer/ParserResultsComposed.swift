//
// Created by Krzysztof Zablocki on 31/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

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
            .forEach {
                guard !$0.isExtension else { return }

                typeMap[$0.globalName] = $0
                if let module = $0.module {
                    var typesByModules = modules[module, default: [:]]
                    typesByModules[$0.name] = $0
                    modules[module] = typesByModules
                }
            }
    }

    private func resolveExtensionOfNestedType(_ type: Type) {
        var components = type.localName.components(separatedBy: ".")
        let rootName = components.removeFirst() // Module/parent name
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

    func unifyTypes() -> [Type] {
        /// Resolve actual names of extensions, as they could have been done on typealias and note updated child names in uniques if needed
        parsedTypes
            .forEach {
                guard $0.isExtension else { return }

                let oldName = $0.globalName

                if $0.parent == nil, $0.localName.contains(".") {
                    resolveExtensionOfNestedType($0)
                }

                if let resolved = resolveGlobalName(for: oldName, containingType: $0.parent, unique: typeMap, modules: modules, typealiases: resolvedTypealiases)?.name {
                    $0.localName = resolved.components(separatedBy: ".").last!
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
}
