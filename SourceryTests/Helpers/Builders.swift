import Foundation
import SourceryRuntime

extension TypeName {
    static func buildArray(of elementType: TypeName, useGenericName: Bool = false) -> TypeName {
        let name = useGenericName ? "Array<\(elementType.asSource)>": "[\(elementType.asSource)]"
        let array = ArrayType(name: name, elementTypeName: elementType)
        return TypeName(name: array.name, array: array, generic: array.asGeneric)
    }

    static func buildSet(of elementType: TypeName) -> TypeName {
        let generic = GenericType(name: "Set", typeParameters: [.init(typeName: elementType)])
        return TypeName(name: generic.asSource, generic: generic)
    }

    static func buildDictionary(key keyTypeName: TypeName, value valueTypeName: TypeName, useGenericName: Bool = false) -> TypeName {
        let name = useGenericName ? "Dictionary<\(keyTypeName.asSource), \(valueTypeName.asSource)>": "[\(keyTypeName.asSource): \(valueTypeName.asSource)]"
        let dictionary = DictionaryType(name: name, valueTypeName: valueTypeName, keyTypeName: keyTypeName)
        return TypeName(name: dictionary.name, dictionary: dictionary, generic: dictionary.asGeneric)
    }

    static func buildTuple(_ elements: TupleElement...) -> TypeName {
        let name = "(\(elements.enumerated().map { "\($1.name == "\($0)" ? $1.typeName.asSource : $1.asSource)" }.joined(separator: ", ")))"
        let tuple = TupleType(name: name, elements: elements)
        return TypeName(name: tuple.name, tuple: tuple)
    }

    static func buildTuple(_ elements: TypeName...) -> TypeName {
        let name = "(\(elements.map { "\($0.asSource)" }.joined(separator: ", ")))"
        let tuple = TupleType(name: name, elements: elements.enumerated().map { TupleElement(name: "\($0)", typeName: $1) })
        return TypeName(name: name, tuple: tuple)
    }

    static func buildClosure(_ returnTypeName: TypeName, attributes: AttributeList = [:]) -> TypeName {
        let closure = ClosureType(name: "() -> \(returnTypeName)", parameters: [], returnTypeName: returnTypeName)
        return TypeName(name: closure.name, attributes: attributes, closure: closure)
    }

    static func buildClosure(_ parameters: ClosureParameter..., returnTypeName: TypeName) -> TypeName {
        let closure = ClosureType(name: "\(parameters.asSource) -> \(returnTypeName)", parameters: parameters, returnTypeName: returnTypeName)
        return TypeName(name: closure.name, closure: closure)
    }

    static func buildClosure(_ parameters: TypeName..., returnTypeName: TypeName) -> TypeName {
        let parameters = parameters.map({ ClosureParameter(typeName: $0) })
        let closure = ClosureType(name: "\(parameters.asSource) -> \(returnTypeName)", parameters: parameters, returnTypeName: returnTypeName)
        return TypeName(name: closure.name, closure: closure)
    }

    var asOptional: TypeName {
        let type = self
        return TypeName(name: type.name,
                        isOptional: true,
                        isImplicitlyUnwrappedOptional: type.isImplicitlyUnwrappedOptional,
                        tuple: type.tuple,
                        array: type.array,
                        dictionary: type.dictionary,
                        closure: type.closure,
                        generic: type.generic
        )
    }

    static var Void: TypeName {
        TypeName(name: "Void")
    }
    
    static var `Any`: TypeName {
        TypeName(name: "Any")
    }

    static var Int: TypeName {
        TypeName(name: "Int")
    }

    static var String: TypeName {
        TypeName(name: "String")
    }

    static var Float: TypeName {
        TypeName(name: "Float")
    }
}
