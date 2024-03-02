import Foundation
import SourceryRuntime

extension String {
    private static let optionalTypeName: TypeName = {
        let t = TypeName(name: "Optional", isOptional: true)
        t.name = "Optional"
        return t
    }()
    
    /// infers type or return self as type if it's a single word
    private var inferElementType: TypeName? {
        if let inferred = inferType {
            return inferred
        }
        
        let trimmed = self.trimmed
        if trimmed.rangeOfCharacter(from: .whitespacesAndNewlines) == nil {
            return TypeName(trimmed)
        }
        
        return nil
    }
    
    /// Infers type from input string
    internal var inferType: TypeName? {
        let string = self
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .strippingComments()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // probably lazy property or default value with closure,
        // we expect explicit type, as we don't know return type
        guard !(string.hasPrefix("{") && string.hasSuffix(")")) else {
            let body = String(string.dropFirst())
            guard !body.contains("return") else {
                return nil
            }
            
            // if there is no return statement it means the return value is the first expression
            let components = body.components(separatedBy: "(", excludingDelimiterBetween: ("<[(", ")]>"))
            if let first = components.first {
                return (first + "()").inferType
            }
            return nil
        }
        
        var inferredType: String
        if string == "nil" {
            // TODO: add generic
            return Self.optionalTypeName
        } else if string.first == "\"" {
            return TypeName(name: "String")
        } else if Bool(string) != nil {
            return TypeName(name: "Bool")
        } else if Int(string) != nil {
            return TypeName(name: "Int")
        } else if Double(string) != nil {
            return TypeName(name: "Double")
        } else if string.isValidTupleName() {
            //tuple
            let string = string.dropFirstAndLast()
            let elements = string.commaSeparated()
            
            var types = [TupleElement]()
            var keys = [String?]()
            for (idx, element) in elements.enumerated() {
                let nameAndValue = element.colonSeparated()
                if nameAndValue.count == 1 {
                    guard let type = element.inferType else { return nil }
                    keys.append(nil)
                    types.append(TupleElement(name: "\(idx)", typeName: type))
                } else {
                    guard let type = nameAndValue[1].inferElementType else { return nil }
                    let name = nameAndValue[0]
                        .replacingOccurrences(of: "_", with: "")
                        .trimmingCharacters(in: .whitespaces)
                    if name.isEmpty {
                        keys.append(nil)
                        types.append(TupleElement(name: "\(idx)", typeName: type))
                    } else {
                        keys.append(name)
                        types.append(TupleElement(name: name, typeName: type))
                    }
                }
            }
            let body = zip(keys, types).map { key, element in
                if let key = key {
                    return "\(key): \(element.typeName.asSource)"
                } else {
                    return element.typeName.asSource
                }
            }.joined(separator: ", ")
            let name = "(\(body))"
            
            let tuple = TupleType(name: name, elements: types)
            return TypeName(name: name, tuple: tuple)
        } else if string.first == "[", string.last == "]" {
            //collection
            let string = string.dropFirstAndLast()
            let items = string
                .commaSeparated()
                .map {
                    $0
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .strippingComments()
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                }
            
            func genericType(from itemsTypes: [TypeName]) -> TypeName {
                var unique = Set(itemsTypes)
                
                if unique.count == 1, let type = unique.first {
                    return type
                } else if unique.count == 2, unique.remove(Self.optionalTypeName) != nil, let type = unique.first {
                    return TypeName(name: type.name,
                                    isOptional: true,
                                    isImplicitlyUnwrappedOptional: false,
                                    tuple: type.tuple,
                                    array: type.array,
                                    dictionary: type.dictionary,
                                    closure: type.closure,
                                    set: type.set,
                                    generic: type.generic
                    )
                }
                
                return TypeName(name: "Any")
            }
            
            if items[0].colonSeparated().count == 1 {
                var itemsTypes = [TypeName]()
                for item in items {
                    guard let type = item.inferElementType else {
                        return nil
                    }
                    itemsTypes.append(type)
                }
                let elementType = genericType(from: itemsTypes)
                let arrayType = ArrayType(name: "[\(elementType.asSource)]", elementTypeName: elementType)
                return TypeName(name: arrayType.name, array: arrayType, generic: arrayType.asGeneric)
            } else {
                var keysTypes = [TypeName]()
                var valuesTypes = [TypeName]()
                for items in items {
                    let keyAndValue = items.colonSeparated()
                    guard keyAndValue.count == 2,
                          let keyType = keyAndValue[0].inferElementType,
                          let valueType = keyAndValue[1].inferElementType
                    else {
                        return nil
                    }
                    
                    keysTypes.append(keyType)
                    valuesTypes.append(valueType)
                }
                let keyType = genericType(from: keysTypes)
                let valueType = genericType(from: valuesTypes)
                
                let dictionaryType = DictionaryType(name: "[\(keyType.asSource): \(valueType.asSource)]", valueTypeName: valueType, keyTypeName: keyType)
                return TypeName(name: dictionaryType.name, dictionary: dictionaryType, generic: dictionaryType.asGeneric)
            }
        } else if let generic = string.genericType() {
            return TypeName(name: generic.asSource, generic: generic)
        } else {
            // Enums, i.e. `Optional.some(...)` or `Optional.none` should be inferred to `Optional`
            // Contained types, i.e. `Foo.Bar()` should be inferred to `Foo.Bar`
            // This also supports initializers i.e. `MyType.SubType.init()`
            // But rarely enum cases can also start with capital letters, so we still may wrongly infer them as a type
            func possibleEnumType(_ string: String) -> String? {
                let components = string.components(separatedBy: ".", excludingDelimiterBetween: ("<[(", ")]>"))
                if components.count > 1, let lastComponentFirstLetter = components.last?.first.map(String.init) {
                    if lastComponentFirstLetter.lowercased() == lastComponentFirstLetter {
                        return components
                            .dropLast()
                            .joined(separator: ".")
                    }
                }
                return nil
            }
            
            // get everything before `(`
            let components = string.components(separatedBy: "(", excludingDelimiterBetween: ("<[(", ")]>"))
            
            // scenario for '}' is for property setter / getter logic
            // scenario for ! is for unwrapped optional
            let unwrappedOptional = string.last == "!"
            if components.count > 1 && (string.last == ")" || string.last == "}" || unwrappedOptional) {
                //initializer without `init`
                inferredType = components[0]
                let name = possibleEnumType(inferredType) ?? inferredType
                return name.inferType ?? TypeName(name + (unwrappedOptional ? "!" : ""))
            } else {
                return possibleEnumType(string).map { TypeName($0) }
            }
        }
    }
    
    func strippingComments() -> String {
        var finished: Bool
        var stripped = self
        repeat {
            finished = true
            let lines = StringView(stripped).lines
            if lines.count > 1 {
                stripped = lines.lazy
                    .filter({ line in !line.content.hasPrefix("//") })
                    .map(\.content)
                    .joined(separator: "\n")
            }
            if let annotationStart = stripped.range(of: "/*")?.lowerBound, let annotationEnd = stripped.range(of: "*/")?.upperBound {
                stripped = stripped.replacingCharacters(in: annotationStart ..< annotationEnd, with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                finished = false
            }
        } while !finished
        
        return stripped
    }
    
    func strippingDefaultValues() -> String {
        if let defaultValueRange = self.range(of: "=") {
            return String(self[self.startIndex ..< defaultValueRange.lowerBound]).trimmingCharacters(in: .whitespaces)
        } else {
            return self
        }
    }
    
    fileprivate func genericType() -> GenericType? {
        var trimmed = self.trimmed
        
        guard let initializerCall = trimmed.lastIndex(of: "(") else {
            return nil
        }
        
        trimmed = String(trimmed[..<initializerCall])
        trimmed.trimSuffix(".init")
        
        guard let start = trimmed.firstIndex(of: "<"),
              trimmed.last == ">",
              start > trimmed.startIndex else {
            return nil
        }
        
        let body = trimmed[trimmed.index(after: start)..<trimmed.index(before: trimmed.endIndex)]
        return GenericType(name: String(trimmed[..<start]), typeParameters: String(body).commaSeparated().map({ value in
            let stripped = value.stripped()
            return GenericTypeParameter(typeName: stripped.inferType ?? TypeName(stripped))
        }))
    }
}
