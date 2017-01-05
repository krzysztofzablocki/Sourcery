//
// Created by Krzysztof Zablocki on 31/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

/// Responsible for composing results of `FileParser`.
struct Composer {
    let verbose: Bool

    init(verbose: Bool = false) {
        self.verbose = verbose
    }

    /// Performs final processing of discovered types:
    /// - extends types with their corresponding extensions;
    /// - replaces typealiases with actual types
    /// - finds actual types for variables and enums raw values
    /// - filters out any private types and extensions
    ///
    /// - Parameter parserResult: Result of parsing source code.
    /// - Returns: Final types and extensions of unknown types.
    func uniqueTypes(_ parserResult: ParserResult) -> [Type] {
        var unique = [String: Type]()
        let types = parserResult.types
        let typealiases = self.typealiasesByNames(parserResult)

        //map all known types to their names
        types
                .filter { $0.isExtension == false}
                .forEach { unique[$0.name] = $0 }

        //replace extensions for type aliases with original types
        types
                .filter { $0.isExtension == true }
                .forEach { $0.localName = typeName(for: $0.name, typealiases: typealiases) ?? $0.localName }

        //extend all types with their extensions
        types.forEach { type in
            type.inheritedTypes = type.inheritedTypes.map { typeName(for: $0, typealiases: typealiases) ?? $0 }

            guard let current = unique[type.name] else {
                //for unknown types we still store their extensions
                unique[type.name] = type

                let inheritanceClause = type.inheritedTypes.isEmpty ? "" :
                        ": \(type.inheritedTypes.joined(separator: ", "))"

                if verbose { print("Found \"extension \(type.name)\(inheritanceClause)\" of type for which we don't have original type definition information") }
                return
            }

            if current == type { return }

            current.extend(type)
            unique[type.name] = current
        }

        let resolveType = { (typeName: TypeName, containingType: Type?) -> Type? in
            let name = self.typeName(for: typeName.unwrappedTypeName, containingType: containingType, typealiases: typealiases)
            typeName.actualTypeName = name.flatMap({ TypeName($0) })
            typeName.tuple = self.parseTupleType(name ?? typeName.name)
            return name.flatMap { unique[$0] } ?? unique[typeName.unwrappedTypeName]
        }

        for (_, type) in unique {
            type.typealiases.forEach { (_, alias) in
                alias.type = resolveType(alias.typeName, type)
            }
            type.variables.forEach {
                resolveVariableTypes($0, of: type, resolve: resolveType)
            }
            type.methods.forEach {
                resolveMethodTypes($0, of: type, resolve: resolveType)
            }

            if let enumeration = type as? Enum {
                resolveEnumTypes(enumeration, types: unique, resolve: resolveType)
            }
        }

        let filteredTypes = unique.values.filter {
            let accessLevel = AccessLevel(rawValue: $0.accessLevel)
            let isPrivate = accessLevel == .private || accessLevel == .fileprivate
            if isPrivate && self.verbose { print("Skipping \($0.kind) \($0.name) as it is private") }
            return !isPrivate
        }.sorted { $0.name < $1.name }

        updateTypeRelationships(types: filteredTypes)
        return filteredTypes
    }

    typealias TypeResolver = (TypeName, Type?) -> Type?

    private func resolveVariableTypes(_ variable: Variable, of type: Type, resolve: TypeResolver) {
        variable.type = resolve(variable.typeName, type)

        variable.typeName.tuple?.elements.forEach({ tuple in
            tuple.type = resolve(tuple.typeName, type)
        })
    }

    private func resolveMethodTypes(_ method: Method, of type: Type, resolve: TypeResolver) {
        method.parameters.enumerated().forEach { (_, parameter) in
            parameter.type = resolve(parameter.typeName, type)
        }

        if !method.returnTypeName.isVoid {
            method.returnType = resolve(method.returnTypeName, type)

            if method.isInitializer {
                method.returnTypeName = TypeName("")
            }
        }
    }

    private func resolveEnumTypes(_ enumeration: Enum, types: [String: Type], resolve: TypeResolver) {
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
                if !(rawTypeCandidate is Protocol) {
                    enumeration.rawTypeName = TypeName(rawTypeName)
                    enumeration.rawType = rawTypeCandidate
                }
            } else {
                enumeration.rawTypeName = TypeName(rawTypeName)
            }
        }
    }

    /// returns typealiases map to their full names
    private func typealiasesByNames(_ parserResult: ParserResult) -> [String: Typealias] {
        var typealiasesByNames = [String: Typealias]()
        parserResult.typealiases.forEach { typealiasesByNames[$0.name] = $0 }
        parserResult.types.forEach { type in
            type.typealiases.forEach({ (_, alias) in
                typealiasesByNames[alias.name] = alias
            })
        }

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
        return typealiasesByNames
    }

    /// returns actual type name for type alias
    private func typeName(for alias: String, containingType: Type? = nil, typealiases: [String: Typealias]) -> String? {
        // first try global typealiases
        if let name = typealiases[alias]?.typeName.name {
            return name
        }

        guard let containingType = containingType,
              let possibleTypeName = typealiases["\(containingType.name).\(alias)"]?.typeName.name else {
            return nil
        }

        //check if typealias is for one of contained types
        let containedType = containingType
            .containedTypes
            .filter {
                $0.name == "\(containingType.name).\(possibleTypeName)" ||
                    $0.name == possibleTypeName
            }.first

        return containedType?.name ?? possibleTypeName
    }

    private func updateTypeRelationships(types: [Type]) {
        var typesByName = [String: Type]()
        types.forEach { typesByName[$0.name] = $0 }

        var processed = [String: Bool]()
        types.forEach { type in
            if let type = type as? Class, let supertype = type.inheritedTypes.first.flatMap({ typesByName[$0] }) as? Class {
                type.supertype = supertype
            }
            processed[type.name] = true
            updateTypeRelationship(for: type, typesByName: typesByName, processed: &processed)
        }
    }

    private func updateTypeRelationship(for type: Type, typesByName: [String: Type], processed: inout [String: Bool]) {
        type.based.keys.forEach { name in
            guard let baseType = typesByName[name] else { return }
            if processed[name] != true {
                processed[name] = true
                updateTypeRelationship(for: baseType, typesByName: typesByName, processed: &processed)
            }

            baseType.based.keys.forEach { type.based[$0] = $0 }
            baseType.inherits.forEach { type.inherits[$0.key] = $0.value }
            baseType.implements.forEach { type.implements[$0.key] = $0.value }

            if baseType is Class {
                type.inherits[name] = baseType
            } else if baseType is Protocol {
                type.implements[name] = baseType
            }
        }
    }

    fileprivate func parseTupleType(_ name: String) -> TupleType? {
        guard name.isValidTupleName() else { return nil }
        return TupleType(name: name, elements: parseTupleElements(name))
    }

    fileprivate func parseTupleElements(_ name: String) -> [TupleType.Element] {
        let trimmedBracketsName = String(name.characters.dropFirst().dropLast())
        return trimmedBracketsName
            .commaSeparated()
            .map({ $0.trimmingCharacters(in: .whitespaces) })
            .enumerated()
            .map {
                let nameAndType = $1.colonSeparated().map({ $0.trimmingCharacters(in: .whitespaces) })

                guard nameAndType.count == 2 else {
                    let typeName = TypeName($1)
                    return TupleType.Element(name: "\($0)", typeName: typeName)
                }
                guard nameAndType[0] != "_" else {
                    let typeName = TypeName(nameAndType[1])
                    return TupleType.Element(name: "\($0)", typeName: typeName)
                }
                let typeName = TypeName(nameAndType[1])
                return TupleType.Element(name: nameAndType[0], typeName: typeName)
        }
    }

}
