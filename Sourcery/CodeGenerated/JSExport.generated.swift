// Generated using Sourcery 0.5.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

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

@objc protocol ClassAutoJSExport: JSExport {
    var kind: String { get }
    var accessLevel: String { get }
    var name: String { get }
    var isGeneric: Bool { get }
    var localName: String { get }
    var variables: [Variable] { get }
    var allVariables: [Variable] { get }
    var allMethods: [Method] { get }
    var methods: [Method] { get }
    var initializers: [Method] { get }
    var annotations: [String: NSObject] { get }
    var staticVariables: [Variable] { get }
    var instanceVariables: [Variable] { get }
    var computedVariables: [Variable] { get }
    var storedVariables: [Variable] { get }
    var inheritedTypes: [String] { get }
    var based: [String: String] { get }
    var inherits: [String: Type] { get }
    var implements: [String: Type] { get }
    var containedTypes: [Type] { get }
    var parentName: String? { get }
    var parent: Type? { get }
    var supertype: Type? { get }
    var attributes: [String: Attribute] { get }
}

extension Class: ClassAutoJSExport {}

@objc protocol EnumAutoJSExport: JSExport {
    var kind: String { get }
    var cases: [EnumCase] { get }
    var rawTypeName: TypeName? { get }
    var hasRawType: Bool { get }
    var rawType: Type? { get }
    var based: [String : String] { get }
    var hasAssociatedValues: Bool { get }
    var accessLevel: String { get }
    var name: String { get }
    var isGeneric: Bool { get }
    var localName: String { get }
    var variables: [Variable] { get }
    var allVariables: [Variable] { get }
    var allMethods: [Method] { get }
    var methods: [Method] { get }
    var initializers: [Method] { get }
    var annotations: [String: NSObject] { get }
    var staticVariables: [Variable] { get }
    var instanceVariables: [Variable] { get }
    var computedVariables: [Variable] { get }
    var storedVariables: [Variable] { get }
    var inheritedTypes: [String] { get }
    var inherits: [String: Type] { get }
    var implements: [String: Type] { get }
    var containedTypes: [Type] { get }
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

@objc protocol MethodAutoJSExport: JSExport {
    var name: String { get }
    var selectorName: String { get }
    var parameters: [MethodParameter] { get }
    var shortName: String { get }
    var returnTypeName: TypeName { get }
    var actualReturnTypeName: TypeName { get }
    var returnType: Type? { get }
    var isOptionalReturnType: Bool { get }
    var isImplicitlyUnwrappedOptionalReturnType: Bool { get }
    var unwrappedReturnTypeName: String { get }
    var `throws`: Bool { get }
    var accessLevel: String { get }
    var isStatic: Bool { get }
    var isClass: Bool { get }
    var isInitializer: Bool { get }
    var isFailableInitializer: Bool { get }
    var annotations: [String: NSObject] { get }
    var attributes: [String: Attribute] { get }
}

extension Method: MethodAutoJSExport {}

@objc protocol MethodParameterAutoJSExport: JSExport {
    var argumentLabel: String? { get }
    var name: String { get }
    var typeName: TypeName { get }
    var type: Type? { get }
    var typeAttributes: [String: Attribute] { get }
    var isOptional: Bool { get }
    var isImplicitlyUnwrappedOptional: Bool { get }
    var unwrappedTypeName: String { get }
}

extension MethodParameter: MethodParameterAutoJSExport {}

@objc protocol ProtocolAutoJSExport: JSExport {
    var kind: String { get }
    var accessLevel: String { get }
    var name: String { get }
    var isGeneric: Bool { get }
    var localName: String { get }
    var variables: [Variable] { get }
    var allVariables: [Variable] { get }
    var allMethods: [Method] { get }
    var methods: [Method] { get }
    var initializers: [Method] { get }
    var annotations: [String: NSObject] { get }
    var staticVariables: [Variable] { get }
    var instanceVariables: [Variable] { get }
    var computedVariables: [Variable] { get }
    var storedVariables: [Variable] { get }
    var inheritedTypes: [String] { get }
    var based: [String: String] { get }
    var inherits: [String: Type] { get }
    var implements: [String: Type] { get }
    var containedTypes: [Type] { get }
    var parentName: String? { get }
    var parent: Type? { get }
    var supertype: Type? { get }
    var attributes: [String: Attribute] { get }
}

extension Protocol: ProtocolAutoJSExport {}

@objc protocol StructAutoJSExport: JSExport {
    var kind: String { get }
    var accessLevel: String { get }
    var name: String { get }
    var isGeneric: Bool { get }
    var localName: String { get }
    var variables: [Variable] { get }
    var allVariables: [Variable] { get }
    var allMethods: [Method] { get }
    var methods: [Method] { get }
    var initializers: [Method] { get }
    var annotations: [String: NSObject] { get }
    var staticVariables: [Variable] { get }
    var instanceVariables: [Variable] { get }
    var computedVariables: [Variable] { get }
    var storedVariables: [Variable] { get }
    var inheritedTypes: [String] { get }
    var based: [String: String] { get }
    var inherits: [String: Type] { get }
    var implements: [String: Type] { get }
    var containedTypes: [Type] { get }
    var parentName: String? { get }
    var parent: Type? { get }
    var supertype: Type? { get }
    var attributes: [String: Attribute] { get }
}

extension Struct: StructAutoJSExport {}

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
    var kind: String { get }
    var accessLevel: String { get }
    var name: String { get }
    var isGeneric: Bool { get }
    var localName: String { get }
    var variables: [Variable] { get }
    var allVariables: [Variable] { get }
    var allMethods: [Method] { get }
    var methods: [Method] { get }
    var initializers: [Method] { get }
    var annotations: [String: NSObject] { get }
    var staticVariables: [Variable] { get }
    var instanceVariables: [Variable] { get }
    var computedVariables: [Variable] { get }
    var storedVariables: [Variable] { get }
    var inheritedTypes: [String] { get }
    var based: [String: String] { get }
    var inherits: [String: Type] { get }
    var implements: [String: Type] { get }
    var containedTypes: [Type] { get }
    var parentName: String? { get }
    var parent: Type? { get }
    var supertype: Type? { get }
    var attributes: [String: Attribute] { get }
}

extension Type: TypeAutoJSExport {}

@objc protocol TypeNameAutoJSExport: JSExport {
    var name: String { get }
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
    var isClosure: Bool { get }
    var description: String { get }
}

extension TypeName: TypeNameAutoJSExport {}

@objc protocol VariableAutoJSExport: JSExport {
    var name: String { get }
    var typeName: TypeName { get }
    var type: Type? { get }
    var isComputed: Bool { get }
    var isStatic: Bool { get }
    var readAccess: String { get }
    var writeAccess: String { get }
    var annotations: [String: NSObject] { get }
    var attributes: [String: Attribute] { get }
    var isOptional: Bool { get }
    var isImplicitlyUnwrappedOptional: Bool { get }
    var unwrappedTypeName: String { get }
}

extension Variable: VariableAutoJSExport {}
