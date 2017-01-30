// Generated using Sourcery 0.5.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

extension AssociatedValue {
    var isOptional: Bool { return typeName.isOptional }
    var isImplicitlyUnwrappedOptional: Bool { return typeName.isImplicitlyUnwrappedOptional }
    var unwrappedTypeName: String { return typeName.unwrappedTypeName }
    var actualTypeName: TypeName? { return typeName.actualTypeName ?? typeName }
    var isTuple: Bool { return typeName.isTuple }
    var isClosure: Bool { return typeName.isClosure }
}
extension MethodParameter {
    var isOptional: Bool { return typeName.isOptional }
    var isImplicitlyUnwrappedOptional: Bool { return typeName.isImplicitlyUnwrappedOptional }
    var unwrappedTypeName: String { return typeName.unwrappedTypeName }
    var actualTypeName: TypeName? { return typeName.actualTypeName ?? typeName }
    var isTuple: Bool { return typeName.isTuple }
    var isClosure: Bool { return typeName.isClosure }
}
extension TupleElement {
    var isOptional: Bool { return typeName.isOptional }
    var isImplicitlyUnwrappedOptional: Bool { return typeName.isImplicitlyUnwrappedOptional }
    var unwrappedTypeName: String { return typeName.unwrappedTypeName }
    var actualTypeName: TypeName? { return typeName.actualTypeName ?? typeName }
    var isTuple: Bool { return typeName.isTuple }
    var isClosure: Bool { return typeName.isClosure }
}
extension Typealias {
    var isOptional: Bool { return typeName.isOptional }
    var isImplicitlyUnwrappedOptional: Bool { return typeName.isImplicitlyUnwrappedOptional }
    var unwrappedTypeName: String { return typeName.unwrappedTypeName }
    var actualTypeName: TypeName? { return typeName.actualTypeName ?? typeName }
    var isTuple: Bool { return typeName.isTuple }
    var isClosure: Bool { return typeName.isClosure }
}
extension Variable {
    var isOptional: Bool { return typeName.isOptional }
    var isImplicitlyUnwrappedOptional: Bool { return typeName.isImplicitlyUnwrappedOptional }
    var unwrappedTypeName: String { return typeName.unwrappedTypeName }
    var actualTypeName: TypeName? { return typeName.actualTypeName ?? typeName }
    var isTuple: Bool { return typeName.isTuple }
    var isClosure: Bool { return typeName.isClosure }
}
