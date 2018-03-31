//
// Created by Krzysztof Zablocki on 31/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import SourceryRuntime

/// Responsible for composing results of `FileParser`.
struct Composer {

    init() {}

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

        //set definedInType for all methods and variables
        types
            .forEach { type in
                type.variables.forEach { $0.definedInType = type }
                type.methods.forEach { $0.definedInType = type }
                type.subscripts.forEach { $0.definedInType = type }
        }

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
        //extract all methods and variables from extensions
        types
            .filter { $0.isExtension == true }
            .forEach {
                $0.localName = actualTypeName(for: TypeName($0.name), typealiases: typealiases) ?? $0.localName
            }

        //extend all types with their extensions
        types.forEach { type in
            type.inheritedTypes = type.inheritedTypes.map { actualTypeName(for: TypeName($0), typealiases: typealiases) ?? $0 }

            let uniqueType = unique[type.name] ?? typeFromModule(type.name, modules: modules)

            guard let current = uniqueType else {
                //for unknown types we still store their extensions
                unique[type.name] = type

                let inheritanceClause = type.inheritedTypes.isEmpty ? "" :
                        ": \(type.inheritedTypes.joined(separator: ", "))"

                Log.verbose("Found \"extension \(type.name)\(inheritanceClause)\" of type for which there is no original type declaration information.")
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
            type.subscripts.forEach {
                resolveSubscriptTypes($0, of: type, resolve: resolveType)
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

        let resolveTypeWithName = { (typeName: TypeName) -> Type? in
            return self.resolveType(typeName: typeName, containingType: containingType, unique: unique, modules: modules, typealiases: typealiases)
        }

        // should we also set these types on lookupName?
        if let array = parseArrayType(lookupName) {
            lookupName.array = array
            array.elementType = resolveTypeWithName(array.elementTypeName)
            lookupName.generic = GenericType(name: lookupName.name, typeParameters: [
                GenericTypeParameter(typeName: array.elementTypeName, type: array.elementType)
                ])
        } else if let dictionary = parseDictionaryType(lookupName) {
            lookupName.dictionary = dictionary
            dictionary.valueType = resolveTypeWithName(dictionary.valueTypeName)
            dictionary.keyType = resolveTypeWithName(dictionary.keyTypeName)
            lookupName.generic = GenericType(name: lookupName.name, typeParameters: [
                GenericTypeParameter(typeName: dictionary.keyTypeName, type: dictionary.keyType),
                GenericTypeParameter(typeName: dictionary.valueTypeName, type: dictionary.valueType)
                ])
        } else if let tuple = parseTupleType(lookupName) {
            lookupName.tuple = tuple
            tuple.elements.forEach { tupleElement in
                tupleElement.type = resolveTypeWithName(tupleElement.typeName)
            }
        } else if let closure = parseClosureType(lookupName) {
            lookupName.closure = closure
            closure.returnType = resolveTypeWithName(closure.returnTypeName)
            closure.parameters.forEach({ parameter in
                parameter.type = resolveTypeWithName(parameter.typeName)
            })
        } else if let generic = parseGenericType(lookupName) {
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

    private func resolveVariableTypes(_ variable: Variable, of type: Type, resolve: TypeResolver) {
        variable.type = resolve(variable.typeName, type)

        /// The actual `definedInType` is assigned in `uniqueTypes` but we still
        /// need to resolve the type to correctly parse typealiases
        /// @see https://github.com/krzysztofzablocki/Sourcery/pull/374
        if let definedInTypeName = variable.definedInTypeName {
            _ = resolve(definedInTypeName, type)
        }
    }

    private func resolveSubscriptTypes(_ subscript: Subscript, of type: Type, resolve: TypeResolver) {
        `subscript`.parameters.forEach { (parameter) in
            parameter.type = resolve(parameter.typeName, type)
        }

        `subscript`.returnType = resolve(`subscript`.returnTypeName, type)
        if let definedInTypeName = `subscript`.definedInTypeName {
            _ = resolve(definedInTypeName, type)
        }
    }

    private func resolveMethodTypes(_ method: SourceryMethod, of type: Type, resolve: TypeResolver) {
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
                if !(rawTypeCandidate is SourceryProtocol) {
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
            } else if unwrappedTypeName.first == "[", unwrappedTypeName.last == "]" {
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
            } else if let genericStartIndex = unwrappedTypeName.index(of: "<"), unwrappedTypeName.last == ">" {
                let genericTypeNameString = String(unwrappedTypeName.prefix(upTo: genericStartIndex))
                let genericTypeName = self.actualTypeName(for: TypeName(genericTypeNameString), containingType: containingType, unique: unique, typealiases: typealiases)

                let typeParametersString = unwrappedTypeName.suffix(from: genericStartIndex).dropFirst().dropLast()
                let typeParameters = String(typeParametersString).commaSeparated()
                var actualTypeParameters = [String]()
                for typeParameter in typeParameters {
                    if let typeName = self.actualTypeName(for: TypeName(typeParameter), containingType: containingType, unique: unique, typealiases: typealiases) {
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
            } else if baseType is SourceryProtocol {
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

    fileprivate func parseClosureType(_ typeName: TypeName) -> ClosureType? {
        let name = typeName.unwrappedTypeName
        guard name.isValidClosureName() else { return nil }

        let closureTypeComponents = name.components(separatedBy: "->", excludingDelimiterBetween: ("(", ")"))

        let returnType = closureTypeComponents.suffix(from: 1)
            .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            .joined(separator: " -> ")
        let returnTypeName = TypeName(returnType)

        var parametersString = closureTypeComponents[0].trimmingCharacters(in: .whitespacesAndNewlines)

        let `throws` = parametersString.trimSuffix("throws")
        parametersString = parametersString.trimmingCharacters(in: .whitespacesAndNewlines)
        if parametersString.trimPrefix("(") { parametersString.trimSuffix(")") }
        parametersString = parametersString.trimmingCharacters(in: .whitespacesAndNewlines)
        let parameters = parseClosureParameters(parametersString)

        let composedName = "(\(parametersString))\(`throws` ? " throws" : "") -> \(returnType)"
        return ClosureType(name: composedName, parameters: parameters, returnTypeName: returnTypeName, throws: `throws`)
    }

    fileprivate func parseClosureParameters(_ parametersString: String) -> [MethodParameter] {
        guard !parametersString.isEmpty else {
            return []
        }

        let parameters = parametersString
            .commaSeparated()
            .compactMap({ parameter -> MethodParameter? in
                let components = parameter.trimmingCharacters(in: .whitespacesAndNewlines)
                    .colonSeparated()
                    .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })

                if components.count == 1 {
                    return MethodParameter(argumentLabel: nil, typeName: TypeName(components[0]))
                } else {
                    let name = components[0].trimmingPrefix("_").stripped()
                    let typeName = components[1]
                    return MethodParameter(argumentLabel: nil, name: name, typeName: TypeName(typeName))
                }
            })

        if parameters.count == 1 && parameters[0].typeName.isVoid {
            return []
        } else {
            return parameters
        }
    }

    fileprivate func parseGenericType(_ typeName: TypeName) -> GenericType? {
        let genericComponents = typeName.unwrappedTypeName
            .split(separator: "<", maxSplits: 1)
            .map({ String($0).stripped() })

        guard genericComponents.count == 2 else {
            return nil
        }

        let name = genericComponents[0]
        let typeParametersString = String(genericComponents[1].dropLast())
        return GenericType(name: name, typeParameters: parseGenericTypeParameters(typeParametersString))
    }

    fileprivate func parseGenericTypeParameters(_ typeParametersString: String) -> [GenericTypeParameter] {
        return typeParametersString
            .commaSeparated()
            .map({ GenericTypeParameter(typeName: TypeName($0.stripped())) })
    }

}
