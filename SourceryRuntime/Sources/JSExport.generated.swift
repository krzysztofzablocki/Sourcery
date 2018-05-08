// Generated using Sourcery 0.13.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable vertical_whitespace trailing_newline

import JavaScriptCore

@objc protocol ArrayTypeAutoJSExport: JSExport {
    var name: String { get }
    var elementTypeName: TypeName { get }
    var elementType: Type? { get }
}

extension ArrayType: ArrayTypeAutoJSExport {}

@objc protocol AssociatedValueAutoJSExport: JSExport {
    var localName: String? { get }
    var externalName: String? { get }
    var typeName: TypeName { get }
    var type: Type? { get }
    var annotations: [String: NSObject] { get }
    var isOptional: Bool { get }
    var isImplicitlyUnwrappedOptional: Bool { get }
    var unwrappedTypeName: String { get }
}

extension AssociatedValue: AssociatedValueAutoJSExport {}

@objc protocol AttributeAutoJSExport: JSExport {
    var name: String { get }
    var arguments: [String: NSObject] { get }
    var description: String { get }
}

extension Attribute: AttributeAutoJSExport {}

@objc protocol BytesRangeAutoJSExport: JSExport {
    var offset: Int64 { get }
    var length: Int64 { get }
}

extension BytesRange: BytesRangeAutoJSExport {}

@objc protocol ClassAutoJSExport: JSExport {
    var kind: String { get }
    var isFinal: Bool { get }
    var module: String? { get }
    var accessLevel: String { get }
    var name: String { get }
    var globalName: String { get }
    var isGeneric: Bool { get }
    var localName: String { get }
    var variables: [Variable] { get }
    var allVariables: [Variable] { get }
    var methods: [Method] { get }
    var allMethods: [Method] { get }
    var subscripts: [Subscript] { get }
    var allSubscripts: [Subscript] { get }
    var initializers: [Method] { get }
    var annotations: [String: NSObject] { get }
    var staticVariables: [Variable] { get }
    var staticMethods: [Method] { get }
    var classMethods: [Method] { get }
    var instanceVariables: [Variable] { get }
    var instanceMethods: [Method] { get }
    var computedVariables: [Variable] { get }
    var storedVariables: [Variable] { get }
    var inheritedTypes: [String] { get }
    var based: [String: String] { get }
    var inherits: [String: Type] { get }
    var implements: [String: Type] { get }
    var containedTypes: [Type] { get }
    var containedType: [String: Type] { get }
    var parentName: String? { get }
    var parent: Type? { get }
    var supertype: Type? { get }
    var attributes: [String: Attribute] { get }
}

extension Class: ClassAutoJSExport {}

@objc protocol ClosureTypeAutoJSExport: JSExport {
    var name: String { get }
    var parameters: [MethodParameter] { get }
    var returnTypeName: TypeName { get }
    var actualReturnTypeName: TypeName { get }
    var returnType: Type? { get }
    var isOptionalReturnType: Bool { get }
    var isImplicitlyUnwrappedOptionalReturnType: Bool { get }
    var unwrappedReturnTypeName: String { get }
    var `throws`: Bool { get }
}

extension ClosureType: ClosureTypeAutoJSExport {}

@objc protocol DictionaryTypeAutoJSExport: JSExport {
    var name: String { get }
    var valueTypeName: TypeName { get }
    var valueType: Type? { get }
    var keyTypeName: TypeName { get }
    var keyType: Type? { get }
}

extension DictionaryType: DictionaryTypeAutoJSExport {}

@objc protocol EnumAutoJSExport: JSExport {
    var kind: String { get }
    var cases: [EnumCase] { get }
    var rawTypeName: TypeName? { get }
    var hasRawType: Bool { get }
    var rawType: Type? { get }
    var based: [String: String] { get }
    var hasAssociatedValues: Bool { get }
    var module: String? { get }
    var accessLevel: String { get }
    var name: String { get }
    var globalName: String { get }
    var isGeneric: Bool { get }
    var localName: String { get }
    var variables: [Variable] { get }
    var allVariables: [Variable] { get }
    var methods: [Method] { get }
    var allMethods: [Method] { get }
    var subscripts: [Subscript] { get }
    var allSubscripts: [Subscript] { get }
    var initializers: [Method] { get }
    var annotations: [String: NSObject] { get }
    var staticVariables: [Variable] { get }
    var staticMethods: [Method] { get }
    var classMethods: [Method] { get }
    var instanceVariables: [Variable] { get }
    var instanceMethods: [Method] { get }
    var computedVariables: [Variable] { get }
    var storedVariables: [Variable] { get }
    var inheritedTypes: [String] { get }
    var inherits: [String: Type] { get }
    var implements: [String: Type] { get }
    var containedTypes: [Type] { get }
    var containedType: [String: Type] { get }
    var parentName: String? { get }
    var parent: Type? { get }
    var supertype: Type? { get }
    var attributes: [String: Attribute] { get }
}

extension Enum: EnumAutoJSExport {}

@objc protocol EnumCaseAutoJSExport: JSExport {
    var name: String { get }
    var rawValue: String? { get }
    var associatedValues: [AssociatedValue] { get }
    var annotations: [String: NSObject] { get }
    var hasAssociatedValue: Bool { get }
}

extension EnumCase: EnumCaseAutoJSExport {}


@objc protocol GenericTypeAutoJSExport: JSExport {
    var name: String { get }
    var typeParameters: [GenericTypeParameter] { get }
}

extension GenericType: GenericTypeAutoJSExport {}

@objc protocol GenericTypeParameterAutoJSExport: JSExport {
    var typeName: TypeName { get }
    var type: Type? { get }
}

extension GenericTypeParameter: GenericTypeParameterAutoJSExport {}

@objc protocol MethodAutoJSExport: JSExport {
    var name: String { get }
    var selectorName: String { get }
    var shortName: String { get }
    var callName: String { get }
    var parameters: [MethodParameter] { get }
    var returnTypeName: TypeName { get }
    var actualReturnTypeName: TypeName { get }
    var returnType: Type? { get }
    var isOptionalReturnType: Bool { get }
    var isImplicitlyUnwrappedOptionalReturnType: Bool { get }
    var unwrappedReturnTypeName: String { get }
    var `throws`: Bool { get }
    var `rethrows`: Bool { get }
    var accessLevel: String { get }
    var isStatic: Bool { get }
    var isClass: Bool { get }
    var isInitializer: Bool { get }
    var isDeinitializer: Bool { get }
    var isFailableInitializer: Bool { get }
    var isConvenienceInitializer: Bool { get }
    var isRequired: Bool { get }
    var isFinal: Bool { get }
    var isMutating: Bool { get }
    var isGeneric: Bool { get }
    var annotations: [String: NSObject] { get }
    var definedInTypeName: TypeName? { get }
    var actualDefinedInTypeName: TypeName? { get }
    var definedInType: Type? { get }
    var attributes: [String: Attribute] { get }
}

extension Method: MethodAutoJSExport {}

@objc protocol MethodParameterAutoJSExport: JSExport {
    var argumentLabel: String? { get }
    var name: String { get }
    var typeName: TypeName { get }
    var `inout`: Bool { get }
    var type: Type? { get }
    var typeAttributes: [String: Attribute] { get }
    var defaultValue: String? { get }
    var annotations: [String: NSObject] { get }
    var isOptional: Bool { get }
    var isImplicitlyUnwrappedOptional: Bool { get }
    var unwrappedTypeName: String { get }
}

extension MethodParameter: MethodParameterAutoJSExport {}

@objc protocol ProtocolAutoJSExport: JSExport {
    var kind: String { get }
    var module: String? { get }
    var accessLevel: String { get }
    var name: String { get }
    var globalName: String { get }
    var isGeneric: Bool { get }
    var localName: String { get }
    var variables: [Variable] { get }
    var allVariables: [Variable] { get }
    var methods: [Method] { get }
    var allMethods: [Method] { get }
    var subscripts: [Subscript] { get }
    var allSubscripts: [Subscript] { get }
    var initializers: [Method] { get }
    var annotations: [String: NSObject] { get }
    var staticVariables: [Variable] { get }
    var staticMethods: [Method] { get }
    var classMethods: [Method] { get }
    var instanceVariables: [Variable] { get }
    var instanceMethods: [Method] { get }
    var computedVariables: [Variable] { get }
    var storedVariables: [Variable] { get }
    var inheritedTypes: [String] { get }
    var based: [String: String] { get }
    var inherits: [String: Type] { get }
    var implements: [String: Type] { get }
    var containedTypes: [Type] { get }
    var containedType: [String: Type] { get }
    var parentName: String? { get }
    var parent: Type? { get }
    var supertype: Type? { get }
    var attributes: [String: Attribute] { get }
}

extension Protocol: ProtocolAutoJSExport {}


@objc protocol StructAutoJSExport: JSExport {
    var kind: String { get }
    var module: String? { get }
    var accessLevel: String { get }
    var name: String { get }
    var globalName: String { get }
    var isGeneric: Bool { get }
    var localName: String { get }
    var variables: [Variable] { get }
    var allVariables: [Variable] { get }
    var methods: [Method] { get }
    var allMethods: [Method] { get }
    var subscripts: [Subscript] { get }
    var allSubscripts: [Subscript] { get }
    var initializers: [Method] { get }
    var annotations: [String: NSObject] { get }
    var staticVariables: [Variable] { get }
    var staticMethods: [Method] { get }
    var classMethods: [Method] { get }
    var instanceVariables: [Variable] { get }
    var instanceMethods: [Method] { get }
    var computedVariables: [Variable] { get }
    var storedVariables: [Variable] { get }
    var inheritedTypes: [String] { get }
    var based: [String: String] { get }
    var inherits: [String: Type] { get }
    var implements: [String: Type] { get }
    var containedTypes: [Type] { get }
    var containedType: [String: Type] { get }
    var parentName: String? { get }
    var parent: Type? { get }
    var supertype: Type? { get }
    var attributes: [String: Attribute] { get }
}

extension Struct: StructAutoJSExport {}

@objc protocol SubscriptAutoJSExport: JSExport {
    var parameters: [MethodParameter] { get }
    var returnTypeName: TypeName { get }
    var actualReturnTypeName: TypeName { get }
    var returnType: Type? { get }
    var isOptionalReturnType: Bool { get }
    var isImplicitlyUnwrappedOptionalReturnType: Bool { get }
    var unwrappedReturnTypeName: String { get }
    var isFinal: Bool { get }
    var readAccess: String { get }
    var writeAccess: String { get }
    var isMutable: Bool { get }
    var annotations: [String: NSObject] { get }
    var definedInTypeName: TypeName? { get }
    var actualDefinedInTypeName: TypeName? { get }
    var definedInType: Type? { get }
    var attributes: [String: Attribute] { get }
}

extension Subscript: SubscriptAutoJSExport {}

@objc protocol TemplateContextAutoJSExport: JSExport {
    var types: Types { get }
    var arguments: [String: NSObject] { get }
    var type: [String: Type] { get }
    var stencilContext: [String: Any] { get }
    var jsContext: [String: Any] { get }
}

extension TemplateContext: TemplateContextAutoJSExport {}

@objc protocol TupleElementAutoJSExport: JSExport {
    var name: String { get }
    var typeName: TypeName { get }
    var type: Type? { get }
    var isOptional: Bool { get }
    var isImplicitlyUnwrappedOptional: Bool { get }
    var unwrappedTypeName: String { get }
}

extension TupleElement: TupleElementAutoJSExport {}

@objc protocol TupleTypeAutoJSExport: JSExport {
    var name: String { get }
    var elements: [TupleElement] { get }
}

extension TupleType: TupleTypeAutoJSExport {}

@objc protocol TypeAutoJSExport: JSExport {
    var module: String? { get }
    var kind: String { get }
    var accessLevel: String { get }
    var name: String { get }
    var globalName: String { get }
    var isGeneric: Bool { get }
    var localName: String { get }
    var variables: [Variable] { get }
    var allVariables: [Variable] { get }
    var methods: [Method] { get }
    var allMethods: [Method] { get }
    var subscripts: [Subscript] { get }
    var allSubscripts: [Subscript] { get }
    var initializers: [Method] { get }
    var annotations: [String: NSObject] { get }
    var staticVariables: [Variable] { get }
    var staticMethods: [Method] { get }
    var classMethods: [Method] { get }
    var instanceVariables: [Variable] { get }
    var instanceMethods: [Method] { get }
    var computedVariables: [Variable] { get }
    var storedVariables: [Variable] { get }
    var inheritedTypes: [String] { get }
    var based: [String: String] { get }
    var inherits: [String: Type] { get }
    var implements: [String: Type] { get }
    var containedTypes: [Type] { get }
    var containedType: [String: Type] { get }
    var parentName: String? { get }
    var parent: Type? { get }
    var supertype: Type? { get }
    var attributes: [String: Attribute] { get }
}

extension Type: TypeAutoJSExport {}

@objc protocol TypeNameAutoJSExport: JSExport {
    var name: String { get }
    var generic: GenericType? { get }
    var isGeneric: Bool { get }
    var actualTypeName: TypeName? { get }
    var attributes: [String: Attribute] { get }
    var isOptional: Bool { get }
    var isImplicitlyUnwrappedOptional: Bool { get }
    var unwrappedTypeName: String { get }
    var isVoid: Bool { get }
    var isTuple: Bool { get }
    var tuple: TupleType? { get }
    var isArray: Bool { get }
    var array: ArrayType? { get }
    var isDictionary: Bool { get }
    var dictionary: DictionaryType? { get }
    var isClosure: Bool { get }
    var closure: ClosureType? { get }
    var description: String { get }
    var debugDescription: String { get }
}

extension TypeName: TypeNameAutoJSExport {}



@objc protocol TypesCollectionAutoJSExport: JSExport {
}

extension TypesCollection: TypesCollectionAutoJSExport {}

@objc protocol VariableAutoJSExport: JSExport {
    var name: String { get }
    var typeName: TypeName { get }
    var type: Type? { get }
    var isComputed: Bool { get }
    var isStatic: Bool { get }
    var readAccess: String { get }
    var writeAccess: String { get }
    var isMutable: Bool { get }
    var defaultValue: String? { get }
    var annotations: [String: NSObject] { get }
    var attributes: [String: Attribute] { get }
    var isFinal: Bool { get }
    var definedInTypeName: TypeName? { get }
    var actualDefinedInTypeName: TypeName? { get }
    var definedInType: Type? { get }
    var isOptional: Bool { get }
    var isImplicitlyUnwrappedOptional: Bool { get }
    var unwrappedTypeName: String { get }
}

extension Variable: VariableAutoJSExport {}


