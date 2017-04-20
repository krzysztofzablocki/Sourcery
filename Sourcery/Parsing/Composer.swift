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
    func uniqueTypes(_ parserResult: FileParserResult) -> [Type] {
        var unique = [String: Type]()
        var modules = [String: [String: Type]]()
        let types = parserResult.types
        let typealiases = self.typealiasesByNames(parserResult)

        //map all known types to their names
        types
            .filter { $0.isExtension == false}
            .forEach {
                unique[$0.name] = $0
                if let module = $0.module {
                    var typesByModules = modules[module] ?? [:]
                    typesByModules[$0.name] = $0
                    modules[module] = typesByModules
                }
        }

        //replace extensions for type aliases with original types
        types
            .filter { $0.isExtension == true }
            .forEach { $0.localName = actualTypeName(for: TypeName($0.name), typealiases: typealiases) ?? $0.localName }

        //extend all types with their extensions
        types.forEach { type in
            type.inheritedTypes = type.inheritedTypes.map { actualTypeName(for: TypeName($0), typealiases: typealiases) ?? $0 }

            let uniqueType = unique[type.name] ?? typeFromModule(type.name, modules: modules)

            guard let current = uniqueType else {
                //for unknown types we still store their extensions
                unique[type.name] = type

                let inheritanceClause = type.inheritedTypes.isEmpty ? "" :
                        ": \(type.inheritedTypes.joined(separator: ", "))"

                if verbose { print("Found \"extension \(type.name)\(inheritanceClause)\" of type for which we don't have original type definition information") }
                return
            }

            if current == type { return }

            current.extend(type)
            unique[current.name] = current
        }

        let resolveType = { (typeName: TypeName, containingType: Type?) -> Type? in
            return self.resolveType(typeName: typeName, containingType: containingType, unique: unique, modules: modules, typealiases: typealiases)
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

        updateTypeRelationships(types: Array(unique.values))
        return unique.values.sorted { $0.name < $1.name }
    }

    private func resolveType(typeName: TypeName, containingType: Type?, unique: [String: Type], modules: [String: [String: Type]], typealiases: [String: Typealias]) -> Type? {
        let actualTypeName = self.actualTypeName(for: typeName, containingType: containingType, unique: unique, typealiases: typealiases)
        if let actualTypeName = actualTypeName, actualTypeName != typeName.unwrappedTypeName {
            typeName.actualTypeName = TypeName(actualTypeName)
        }

        let lookupName = typeName.actualTypeName ?? typeName
        
        if lookupName.generic == nil && lookupName.isGeneric {
            let genericSplit = lookupName.unwrappedTypeName.characters.split(separator: "<")
            
            guard genericSplit.count == 2 else {
                return nil
            }
            
            let typeCharacters = genericSplit[0]
            var genericCharacters = genericSplit[1]
            
            guard genericCharacters.count > 1, genericCharacters.removeLast() == ">" else {
                return nil
            }
            
            let genericTypeStrings = genericCharacters.split(separator: ",").map { characters in
                return String(characters).trimmingCharacters(in: [" "])
            }
            
            let genericTypeNames = genericTypeStrings.flatMap { genericTypeName in
                return TypeName(genericTypeName)
            }
            
            let genericTypes = genericTypeStrings.flatMap { genericTypeName in
                return unique[genericTypeName]
            }
            
            lookupName.generic = GenericType(name: String(typeCharacters), referencedTypes: genericTypes, referencedTypeNames: genericTypeNames)
        }
        
        if let array = parseArrayType(lookupName) {
            typeName.array = array
            array.elementType = resolveType(typeName: array.elementTypeName, containingType: containingType, unique: unique, modules: modules, typealiases: typealiases)
        } else if let dictionary = parseDictionaryType(lookupName) {
            typeName.dictionary = dictionary
            dictionary.valueType = resolveType(typeName: dictionary.valueTypeName, containingType: containingType, unique: unique, modules: modules, typealiases: typealiases)
            dictionary.keyType = resolveType(typeName: dictionary.keyTypeName, containingType: containingType, unique: unique, modules: modules, typealiases: typealiases)
        } else if let tuple = parseTupleType(lookupName) {
            typeName.tuple = tuple
            // recursively resolve type of each tuple element
            tuple.elements.forEach { tupleElement in
                tupleElement.type = resolveType(typeName: tupleElement.typeName, containingType: containingType, unique: unique, modules: modules, typealiases: typealiases)
            }
        }
        
        return unique[lookupName.unwrappedTypeName] ?? unique[lookupName.generic?.name ?? ""] ?? typeFromModule(lookupName.unwrappedTypeName, modules: modules)
    }

    typealias TypeResolver = (TypeName, Type?) -> Type?

    private func resolveVariableTypes(_ variable: Variable, of type: Type, resolve: TypeResolver) {
        variable.type = resolve(variable.typeName, type)
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
    private func typealiasesByNames(_ parserResult: FileParserResult) -> [String: Typealias] {
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
    private func actualTypeName(for typeName: TypeName, containingType: Type? = nil, unique: [String: Type]? = nil, typealiases: [String: Typealias]) -> String? {
        let optionalPrefix = typeName.isOptional ? "?" : typeName.isImplicitlyUnwrappedOptional ? "!" : ""
        let unwrappedTypeName = typeName.unwrappedTypeName
        var actualTypeName: String?

        // first try global typealiases
        if let name = typealiases[unwrappedTypeName]?.typeName.name {
            actualTypeName = name
        }

        if let containingType = containingType {
            //check if typealias is for one of contained types
            if let possibleTypeName = typealiases["\(containingType.name).\(unwrappedTypeName)"]?.typeName.name {
                let containedType = containingType.containedTypes.first(where: {
                    $0.name == "\(containingType.name).\(possibleTypeName)" || $0.name == possibleTypeName
                })

                actualTypeName = containedType?.name ?? possibleTypeName
            } else {
                if let name = unique?["\(containingType.name).\(unwrappedTypeName)"]?.name {
                    //check contained types first
                    actualTypeName = name
                } else {
                    //otherwise go up contained types chain to find a type
                    let parentTypes = containingType.parentTypes
                    while let parent = parentTypes.next() {
                        if let name = unique?["\(parent.name).\(unwrappedTypeName)"]?.name {
                            actualTypeName = name
                            break
                        }
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
                        let valueName = self.actualTypeName(for: TypeName(nameAndValue[0]), containingType: containingType, unique: unique, typealiases: typealiases)
                        actualElements.append(valueName ?? nameAndValue[0])
                    } else {
                        let valueName = self.actualTypeName(for: TypeName(nameAndValue[1]), containingType: containingType, unique: unique, typealiases: typealiases)
                        actualElements.append("\(nameAndValue[0]): \(valueName ?? nameAndValue[1])")
                    }
                }
                actualTypeName = "(\(actualElements.joined(separator: ", ")))"
            } else if unwrappedTypeName.characters.first == "[", unwrappedTypeName.characters.last == "]" {
                let types = unwrappedTypeName.dropFirstAndLast()
                    .colonSeparated()
                    .map({ $0.trimmingCharacters(in: .whitespaces) })
                if types.count == 1 {
                    //array literal
                    let name = self.actualTypeName(for: TypeName(types[0]), containingType: containingType, unique: unique, typealiases: typealiases)
                    actualTypeName = "[\(name ?? types[0])]"
                } else {
                    //dictionary literal
                    let keyName = self.actualTypeName(for: TypeName(types[0]), containingType: containingType, unique: unique, typealiases: typealiases)
                    let valueName = self.actualTypeName(for: TypeName(types[1]), containingType: containingType, unique: unique, typealiases: typealiases)
                    actualTypeName = "[\(keyName ?? types[0]): \(valueName ?? types[1])]"
                }
            }
            return actualTypeName + optionalPrefix
        } else {
            return nil
        }
    }

    private func typeFromModule(_ name: String, modules: [String: [String: Type]]) -> Type? {
        guard name.contains(".") else { return nil }
        let nameComponents = name.components(separatedBy: ".")
        let moduleName = nameComponents[0]
        let typeName = nameComponents.suffix(from: 1).joined(separator: ".")
        return modules[moduleName]?[typeName]
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

    fileprivate func parseArrayType(_ typeName: TypeName) -> ArrayType? {
        let name = typeName.unwrappedTypeName
        guard name.isValidArrayName() else { return nil }
        return ArrayType(name: typeName.name, elementTypeName: parseArrayElementType(typeName))
    }

    fileprivate func parseArrayElementType(_ typeName: TypeName) -> TypeName {
        let name = typeName.unwrappedTypeName
        if name.hasPrefix("Array<") {
            return TypeName(name.drop(first: 6, last: 1))
        } else {
            return TypeName(name.dropFirstAndLast())
        }
    }

    fileprivate func parseDictionaryType(_ typeName: TypeName) -> DictionaryType? {
        let name = typeName.unwrappedTypeName
        guard name.isValidDictionaryName() else { return nil }
        let keyValueType: (keyType: TypeName, valueType: TypeName) = parseDictionaryKeyValueType(typeName)
        return DictionaryType(name: typeName.name, valueTypeName: keyValueType.valueType, keyTypeName: keyValueType.keyType)
    }

    fileprivate func parseDictionaryKeyValueType(_ typeName: TypeName) -> (keyType: TypeName, valueType: TypeName) {
        let name = typeName.unwrappedTypeName
        if name.hasPrefix("Dictionary<") {
            let types = name.drop(first: 11, last: 1).commaSeparated()
            return (TypeName(types[0].stripped()), TypeName(types[1].stripped()))
        } else {
            let types = name.dropFirstAndLast().colonSeparated()
            return (TypeName(types[0].stripped()), TypeName(types[1].stripped()))
        }
    }

    fileprivate func parseTupleType(_ typeName: TypeName) -> TupleType? {
        let name = typeName.unwrappedTypeName
        guard name.isValidTupleName() else { return nil }
        return TupleType(name: typeName.name, elements: parseTupleElements(typeName))
    }

    fileprivate func parseTupleElements(_ typeName: TypeName) -> [TupleElement] {
        let name = typeName.unwrappedTypeName
        let trimmedBracketsName = name.dropFirstAndLast()
        return trimmedBracketsName
            .commaSeparated()
            .map({ $0.trimmingCharacters(in: .whitespaces) })
            .enumerated()
            .map {
                let nameAndType = $1.colonSeparated().map({ $0.trimmingCharacters(in: .whitespaces) })

                guard nameAndType.count == 2 else {
                    let typeName = TypeName($1)
                    return TupleElement(name: "\($0)", typeName: typeName)
                }
                guard nameAndType[0] != "_" else {
                    let typeName = TypeName(nameAndType[1])
                    return TupleElement(name: "\($0)", typeName: typeName)
                }
                let typeName = TypeName(nameAndType[1])
                return TupleElement(name: nameAndType[0], typeName: typeName)
        }
    }

}
