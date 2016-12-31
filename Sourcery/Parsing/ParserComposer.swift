//
// Created by Krzysztof Zablocki on 31/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

struct ParserComposer {
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

        let resolveType = { (unwrappedTypeName: String, containingType: Type?, typealiases: [String: Typealias]) in
            return self.typeName(for: unwrappedTypeName, containingType: containingType, typealiases: typealiases)
                    .flatMap { unique[$0] } ?? unique[unwrappedTypeName]
        }

        for (_, type) in unique {
            // find actual variables types
            type.variables.forEach {
                $0.type = resolveType($0.unwrappedTypeName, type, typealiases)
            }

            // find actual methods parameters types and their argument labels
            for method in type.methods {
                let argumentLabels: [String]
                if let labels = method.selectorName.range(of: "(")
                        .map({ method.selectorName.substring(from: $0.upperBound) })?
                        .trimmingCharacters(in: CharacterSet(charactersIn: ")"))
                        .components(separatedBy: ":")
                        .dropLast() {
                    argumentLabels = Array(labels)
                } else {
                    argumentLabels = []
                }

                for (index, parameter) in method.parameters.enumerated() {
                    if index < argumentLabels.count {
                        parameter.argumentLabel = argumentLabels[index]
                    }

                    parameter.type = resolveType(parameter.unwrappedTypeName, type, typealiases)
                }

                if !method.returnTypeName.isVoid {
                    method.returnType = resolveType(method.unwrappedReturnTypeName, type, typealiases)

                    if method.isInitializer {
                        method.returnTypeName = TypeName("")
                    }
                }
            }

            //find enums rawValue types
            if let enumeration = type as? Enum, enumeration.rawType == nil {
                enumeration.cases.forEach { enumCase in
                    enumCase.associatedValues.forEach { associatedValue in
                        associatedValue.type = resolveType(associatedValue.unwrappedTypeName, type, typealiases)
                    }
                }

                guard enumeration.hasRawType, let rawTypeName = enumeration.inheritedTypes.first else { continue }
                if let rawTypeCandidate = unique[rawTypeName] {
                    if !(rawTypeCandidate is Protocol) {
                        enumeration.rawType = rawTypeCandidate.name
                    }
                } else {
                    enumeration.rawType = rawTypeName
                }
            }
        }

        let filteredTypes = unique.values.filter {
            let isPrivate = AccessLevel(rawValue: $0.accessLevel) == .private || AccessLevel(rawValue: $0.accessLevel) == .fileprivate
            if isPrivate && self.verbose { print("Skipping \($0.kind) \($0.name) as it is private") }
            return !isPrivate
        }.sorted { $0.name < $1.name }

        updateTypeRelationships(types: filteredTypes)
        return filteredTypes
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
            while let targetAlias = typealiasesByNames[finalAlias.typeName] {
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
        if let name = typealiases[alias]?.typeName {
            return name
        }

        guard let containingType = containingType,
              let possibleTypeName = typealiases["\(containingType.name).\(alias)"]?.typeName else {
            return nil
        }

        //check if typealias is for one of contained types
        let containedType = containingType
                .containedTypes
                .filter {
            $0.name == "\(containingType.name).\(possibleTypeName)" ||
                    $0.name == possibleTypeName
        }
                .first

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

            baseType.based.keys.forEach {  type.based[$0] = $0 }
            baseType.inherits.forEach {  type.inherits[$0.key] = $0.value }
            baseType.implements.forEach {  type.implements[$0.key] = $0.value }

            if baseType is Class {
                type.inherits[name] = baseType
            } else if baseType is Protocol {
                type.implements[name] = baseType
            }
        }
    }
}
