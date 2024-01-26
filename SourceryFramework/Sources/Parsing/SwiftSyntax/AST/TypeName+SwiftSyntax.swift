import Foundation
import SourceryRuntime
import SwiftSyntax

extension SyntaxProtocol {
    @inlinable
    var sourcerySafeTypeIdentifier: String {
        let content = description
        return String(content[content.utf8.index(content.startIndex, offsetBy: leadingTriviaLength.utf8Length)..<content.utf8.index(content.endIndex, offsetBy: -trailingTriviaLength.utf8Length)])

        // TBR: we only need this because we are trying to fit into old AST naming
        // TODO: there is a bug in syntax that sometimes crashes with unexpected nil when removing trivia

//        if trailingTriviaLength.utf8Length != 0 || leadingTriviaLength.utf8Length != 0 {
////            return withoutTrivia().description.trimmed
//        } else {
//            return description.trimmed
//        }
    }
}

extension TypeName {
    convenience init(_ node: TypeSyntax) {
        /* TODO: redesign what `TypeName` represents, it can represent all those different variants
         Furthermore if `TypeName` was used to store Type the whole composer process could probably be simplified / optimized?
         */
        if let typeIdentifier = node.as(SimpleTypeIdentifierSyntax.self) {
            let name = typeIdentifier.name.text.trimmed // TODO: typeIdentifier.sourcerySafeTypeIdentifier ?
            let generic = typeIdentifier.genericArgumentClause.map { GenericType(name: typeIdentifier.name.text, node: $0) }

            // optional gets special treatment
            if name == "Optional", let unwrappedTypeName = generic?.typeParameters.first?.typeName.name, generic?.typeParameters.count == 1 {
                // TODO: TBR
                self.init(name: typeIdentifier.sourcerySafeTypeIdentifier, isOptional: true, generic: nil)
                self.unwrappedTypeName = unwrappedTypeName
            } else {
                // special treatment for spelled out literals
                switch (name, generic?.typeParameters.count) {
                case ("Array", 1?):
                    let elementTypeName = generic!.typeParameters[0].typeName
                    let array = ArrayType(name: "Array<\(elementTypeName.asSource)>", elementTypeName: elementTypeName)
                    self.init(name: array.name, array: array, generic: array.asGeneric)
                case ("Dictionary", 2?):
                    let keyTypeName = generic!.typeParameters[0].typeName
                    let valueTypeName = generic!.typeParameters[1].typeName
                    let dictionary = DictionaryType(name: "Dictionary<\(keyTypeName.asSource), \(valueTypeName.asSource)>", valueTypeName: valueTypeName, keyTypeName: keyTypeName)
                    self.init(name: dictionary.name, dictionary: dictionary, generic: dictionary.asGeneric)
                default:
                    self.init(name: typeIdentifier.sourcerySafeTypeIdentifier, generic: generic)
                }
            }
        } else if let typeIdentifier = node.as(MemberTypeIdentifierSyntax.self) {
            let base = TypeName(typeIdentifier.baseType) // TODO: VERIFY IF THIS SHOULD FULLY WRAP
            let fullName = "\(base.name).\(typeIdentifier.name.text.trimmed)"
            let generic = typeIdentifier.genericArgumentClause.map { GenericType(name: fullName, node: $0) }
            if let genericComponent = generic?.typeParameters.map({ $0.typeName.asSource }).joined(separator: ", ") {
                self.init(name: "\(fullName)<\(genericComponent)>", generic: generic)
            } else {
                self.init(name: fullName, generic: generic)
            }
        } else if let typeIdentifier = node.as(CompositionTypeSyntax.self) {
            let types = typeIdentifier.elements.map { TypeName($0.type) }
            let name = types.map({ $0.name }).joined(separator:" & ")
            self.init(name: name, isProtocolComposition: true)
        } else if let typeIdentifier = node.as(OptionalTypeSyntax.self) {
            let type = TypeName(typeIdentifier.wrappedType)
            let needsWrapping = type.isClosure || type.isProtocolComposition
            self.init(name: needsWrapping ? "(\(type.asSource))" : type.name,
                      isOptional: true,
                      isImplicitlyUnwrappedOptional: false,
                      tuple: type.tuple,
                      array: type.array,
                      dictionary: type.dictionary,
                      closure: type.closure,
                      generic: type.generic,
                      isProtocolComposition: type.isProtocolComposition
            )
        } else if let typeIdentifier = node.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
            let type = TypeName(typeIdentifier.wrappedType)
            let needsWrapping = type.isClosure || type.isProtocolComposition
            self.init(name: needsWrapping ? "(\(type.asSource))" : type.name,
                      isOptional: false,
                      isImplicitlyUnwrappedOptional: true,
                      tuple: type.tuple,
                      array: type.array,
                      dictionary: type.dictionary,
                      closure: type.closure,
                      generic: type.generic,
                      isProtocolComposition: type.isProtocolComposition
            )
        } else if let typeIdentifier = node.as(ArrayTypeSyntax.self) {
            let elementType = TypeName(typeIdentifier.elementType)
            let name = typeIdentifier.sourcerySafeTypeIdentifier
            let array = ArrayType(name: name, elementTypeName: elementType)
            self.init(name: name, array: array, generic: array.asGeneric)
        } else if let typeIdentifier = node.as(DictionaryTypeSyntax.self) {
            let keyType = TypeName(typeIdentifier.keyType)
            let valueType = TypeName(typeIdentifier.valueType)
            let name = typeIdentifier.sourcerySafeTypeIdentifier
            let dictionary = DictionaryType(name: name, valueTypeName: valueType, keyTypeName: keyType)
            self.init(name: name, dictionary: dictionary, generic: dictionary.asGeneric)
        } else if let typeIdentifier = node.as(TupleTypeSyntax.self) {
            let elements = typeIdentifier.elements.enumerated().map { idx, element -> TupleElement in
                var firstName = element.name?.text.trimmed
                let secondName = element.secondName?.text.trimmed

                if firstName?.nilIfNotValidParameterName == nil, secondName == nil {
                    firstName = "\(idx)"
                }

                return TupleElement(name: firstName, typeName: TypeName(element.type))
            }
            let name = typeIdentifier.sourcerySafeTypeIdentifier

            // TODO: TBR
            if elements.count == 1, let type = elements.first?.typeName {
                self.init(name: type.name,
                          attributes: type.attributes,
                          isOptional: type.isOptional,
                          isImplicitlyUnwrappedOptional: type.isImplicitlyUnwrappedOptional,
                          tuple: type.tuple,
                          array: type.array,
                          dictionary: type.dictionary,
                          closure: type.closure,
                          generic: type.generic,
                          isProtocolComposition: type.isProtocolComposition
                )
            } else if elements.count == 0 { // Void
                self.init(name: "()")
            } else {
                self.init(name: name, tuple: TupleType(name: name, elements: elements))
            }
        } else if let typeIdentifier = node.as(FunctionTypeSyntax.self) {
            let elements = typeIdentifier.arguments.map { node -> ClosureParameter in
                let firstName = node.name?.text.trimmed.nilIfNotValidParameterName
                let typeName = TypeName(node.type)
                let specifiers = TypeName.specifiers(from: node.type)
                
                return ClosureParameter(
                  argumentLabel: firstName,
                  name: node.secondName?.text.trimmed ?? firstName,
                  typeName: typeName,
                  isInout: specifiers.isInOut,
                  isVariadic: node.type.as(PackExpansionTypeSyntax.self)?.ellipsis != nil
                )
            }
            let returnTypeName = TypeName(typeIdentifier.returnType)
            let asyncKeyword = typeIdentifier.fixedAsyncKeyword.map { $0.text.trimmed }
            let throwsOrRethrows = typeIdentifier.fixedThrowsOrRethrowsKeyword.map { $0.text.trimmed }
            let name = "\(elements.asSource)\(asyncKeyword != nil ? " \(asyncKeyword!)" : "")\(throwsOrRethrows != nil ? " \(throwsOrRethrows!)" : "") -> \(returnTypeName.asSource)"
            self.init(
                name: name,
                closure: ClosureType(
                    name: name,
                    parameters: elements,
                    returnTypeName: returnTypeName,
                    asyncKeyword: asyncKeyword,
                    throwsOrRethrowsKeyword: throwsOrRethrows)
            )
        } else if let typeIdentifier = node.as(AttributedTypeSyntax.self) {
            let type = TypeName(typeIdentifier.baseType) // TODO: add test for nested type with attributes at multiple level?
            let attributes = Attribute.from(typeIdentifier.attributes)

            self.init(name: type.name,
                      attributes: attributes,
                      isOptional: type.isOptional,
                      isImplicitlyUnwrappedOptional: type.isImplicitlyUnwrappedOptional,
                      tuple: type.tuple,
                      array: type.array,
                      dictionary: type.dictionary,
                      closure: type.closure,
                      generic: type.generic,
                      isProtocolComposition: type.isProtocolComposition
            )
        } else if node.as(ClassRestrictionTypeSyntax.self) != nil {
            self.init(name: "AnyObject")
        } else if let typeIdentifier = node.as(PackExpansionTypeSyntax.self) {
            self.init(typeIdentifier.patternType)
        } else {
//            assertionFailure("This is unexpected \(node)")
            self.init(node.sourcerySafeTypeIdentifier)
        }
    }
}

extension TypeName {
    static func specifiers(from type: TypeSyntax?) -> (isInOut: Bool, unused: Bool) {
        guard let type = type else {
            return (false, false)
        }

        var isInOut = false
        if let typeIdentifier = type.as(AttributedTypeSyntax.self), let specifier = typeIdentifier.specifier {
            if specifier.tokenKind == .inoutKeyword {
                isInOut = true
            } else {
                assertionFailure("Unhandled specifier")
            }
        }
        
        return (isInOut, false)
    }
}

// TODO: when I don't need to adapt to old formats
//import Foundation
//import SourceryRuntime
//import SwiftSyntax
//
//extension TypeName {
//    convenience init(_ node: TypeSyntax) {
//        /* TODO: redesign what `TypeName` represents, it can represent all those different variants
//         Furthermore if `TypeName` was used to store Type the whole composer process could probably be simplified / optimized?
//         */
//        if let typeIdentifier = node.as(SimpleTypeIdentifierSyntax.self) {
//            let name = typeIdentifier.name.text.trimmed
//            let generic = typeIdentifier.genericArgumentClause.map { GenericType(name: typeIdentifier.name.text, node: $0) }
//
//            // optional gets special treatment
//            if name == "Optional", let wrappedTypeName = generic?.typeParameters.first?.typeName.name, generic?.typeParameters.count == 1 {
//                self.init(name: wrappedTypeName, isOptional: true, generic: generic)
//            } else {
//                self.init(name: name, generic: generic)
//            }
//        } else if let typeIdentifier = node.as(MemberTypeIdentifierSyntax.self) {
//            let base = TypeName(typeIdentifier.baseType) // TODO: VERIFY IF THIS SHOULD FULLY WRAP
//            self.init(name: "\(base.name).\(typeIdentifier.name.text.trimmed)")
//        } else if let typeIdentifier = node.as(CompositionTypeSyntax.self) {
//            let types = typeIdentifier.elements.map { TypeName($0.type) }
//            let name = types.map({ $0.name }).joined(separator:" & ")
//            self.init(name: name)
//        } else if let typeIdentifier = node.as(OptionalTypeSyntax.self) {
//            let type = TypeName(typeIdentifier.wrappedType)
//            self.init(name: type.name,
//                      isOptional: true,
//                      isImplicitlyUnwrappedOptional: type.isImplicitlyUnwrappedOptional,
//                      tuple: type.tuple,
//                      array: type.array,
//                      dictionary: type.dictionary,
//                      closure: type.closure,
//                      generic: type.generic
//            )
//        } else if let typeIdentifier = node.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
//            let type = TypeName(typeIdentifier.wrappedType)
//            self.init(name: type.name,
//                      isOptional: type.isOptional,
//                      isImplicitlyUnwrappedOptional: true,
//                      tuple: type.tuple,
//                      array: type.array,
//                      dictionary: type.dictionary,
//                      closure: type.closure,
//                      generic: type.generic
//            )
//        } else if let typeIdentifier = node.as(ArrayTypeSyntax.self) {
//            let elementType = TypeName(typeIdentifier.elementType)
//            let name = typeIdentifier.description.trimmed
//            let array = ArrayType(name: name, elementTypeName: elementType)
//            self.init(name: name, array: array, generic: array.asGeneric)
//        } else if let typeIdentifier = node.as(DictionaryTypeSyntax.self) {
//            let keyType = TypeName(typeIdentifier.keyType)
//            let valueType = TypeName(typeIdentifier.valueType)
//            let name = typeIdentifier.description.trimmed
//            let dictionary = DictionaryType(name: name, valueTypeName: valueType, keyTypeName: keyType)
//            self.init(name: name, dictionary: dictionary, generic: dictionary.asGeneric)
//        } else if let typeIdentifier = node.as(TupleTypeSyntax.self) {
//            let elements = typeIdentifier.elements.map { TupleElement(name: $0.name?.text.trimmed, secondName: $0.secondName?.text.trimmed, typeName: TypeName($0.type)) }
//            let name = typeIdentifier.description.trimmed
//            self.init(name: name, tuple: TupleType(name: name, elements: elements))
//        } else if let typeIdentifier = node.as(FunctionTypeSyntax.self) {
//            let name = typeIdentifier.description.trimmed
//            let elements = typeIdentifier.arguments.map { TupleElement(name: $0.name?.text.trimmed, secondName: $0.secondName?.text.trimmed, typeName: TypeName($0.type)) }
//            self.init(name: name, closure: ClosureType(name: name, parameters: elements, returnTypeName: TypeName(typeIdentifier.returnType)))
//        } else if let typeIdentifier = node.as(AttributedTypeSyntax.self) {
//            let type = TypeName(typeIdentifier.baseType) // TODO: add test for nested type with attributes at multiple level?
//            let attributes = Attribute.from(typeIdentifier.attributes)
//            self.init(name: type.name,
//                      attributes: attributes,
//                      isOptional: type.isOptional,
//                      isImplicitlyUnwrappedOptional: type.isImplicitlyUnwrappedOptional,
//                      tuple: type.tuple,
//                      array: type.array,
//                      dictionary: type.dictionary,
//                      closure: type.closure,
//                      generic: type.generic
//            )
//        } else if node.as(ClassRestrictionTypeSyntax.self) != nil {
//            self.init(name: "AnyObject")
//        } else {
//            assertionFailure("This is unexpected \(node)")
//            self.init(node.description.trimmed)
//        }
//    }
//}
