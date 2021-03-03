import Foundation
import SourceryRuntime

extension TypeName {

    var arrayType: ArrayType? {
        Self.parseArrayType(self)
    }

    fileprivate static func parseArrayType(_ typeName: TypeName) -> ArrayType? {
        let name = typeName.unwrappedTypeName
        guard name.isValidArrayName() else { return nil }
        return ArrayType(name: typeName.name, elementTypeName: parseArrayElementType(typeName))
    }

    fileprivate static func parseArrayElementType(_ typeName: TypeName) -> TypeName {
        let name = typeName.unwrappedTypeName
        if name.hasPrefix("Array<") {
            return TypeName(name.drop(first: 6, last: 1))
        } else {
            return TypeName(name.dropFirstAndLast())
        }
    }

    var dictionaryType: DictionaryType? {
        Self.parseDictionaryType(self)
    }

    fileprivate static func parseDictionaryType(_ typeName: TypeName) -> DictionaryType? {
        let name = typeName.unwrappedTypeName
        guard name.isValidDictionaryName() else { return nil }
        let keyValueType: (keyType: TypeName, valueType: TypeName) = parseDictionaryKeyValueType(typeName)
        return DictionaryType(name: typeName.name, valueTypeName: keyValueType.valueType, keyTypeName: keyValueType.keyType)
    }

    fileprivate static func parseDictionaryKeyValueType(_ typeName: TypeName) -> (keyType: TypeName, valueType: TypeName) {
        let name = typeName.unwrappedTypeName
        if name.hasPrefix("Dictionary<") {
            let types = name.drop(first: 11, last: 1).commaSeparated()
            return (TypeName(types[0].stripped()), TypeName(types[1].stripped()))
        } else {
            let types = name.dropFirstAndLast().colonSeparated()
            return (TypeName(types[0].stripped()), TypeName(types[1].stripped()))
        }
    }
    var tupleType: TupleType? {
        Self.parseTupleType(self)
    }

    fileprivate static func parseTupleType(_ typeName: TypeName) -> TupleType? {
        let name = typeName.unwrappedTypeName
        guard name.isValidTupleName() else { return nil }
        return TupleType(name: typeName.name, elements: parseTupleElements(typeName))
    }

    fileprivate static func parseTupleElements(_ typeName: TypeName) -> [TupleElement] {
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

    var closureType: ClosureType? {
        Self.parseClosureType(self)
    }

    fileprivate static func parseClosureType(_ typeName: TypeName) -> ClosureType? {
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
        return ClosureType(name: composedName, parameters: parameters, returnTypeName: returnTypeName, throwsOrRethrowsKeyword: `throws` ? "throws" : nil)
    }

    fileprivate static func parseClosureParameters(_ parametersString: String) -> [ClosureParameter] {
        guard !parametersString.isEmpty else {
            return []
        }
        
        let parameters = parametersString
            .commaSeparated()
            .compactMap({ parameter -> ClosureParameter? in
                let components = parameter.trimmingCharacters(in: .whitespacesAndNewlines)
                    .colonSeparated()
                    .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
                
                if components.count == 1 {
                    return ClosureParameter(typeName: TypeName(components[0]))
                } else {
                    let name = components[0].trimmingPrefix("_").stripped()
                    let typeName = components[1]
                    return ClosureParameter(name: name, typeName: TypeName(typeName))
                }
            })
        
        return parameters
    }

    var genericType: GenericType? {
        Self.parseGenericType(self)
    }

    fileprivate static func parseGenericType(_ typeName: TypeName) -> GenericType? {
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

    fileprivate static func parseGenericTypeParameters(_ typeParametersString: String) -> [GenericTypeParameter] {
        return typeParametersString
            .commaSeparated()
            .map({ GenericTypeParameter(typeName: TypeName($0.stripped())) })
    }
}
