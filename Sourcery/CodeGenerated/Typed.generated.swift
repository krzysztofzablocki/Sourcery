// Generated using Sourcery 0.5.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

extension AssociatedValue {
    var isOptional: Bool { return typeName.isOptional }
    var isImplicitlyUnwrappedOptional: Bool { return typeName.isImplicitlyUnwrappedOptional }
    var unwrappedTypeName: String { return typeName.unwrappedTypeName }
    var actualTypeName: TypeName? { return typeName.actualTypeName ?? typeName }
    var isTuple: Bool { return typeName.isTuple }
}
extension MethodParameter {
    var isOptional: Bool { return typeName.isOptional }
    var isImplicitlyUnwrappedOptional: Bool { return typeName.isImplicitlyUnwrappedOptional }
    var unwrappedTypeName: String { return typeName.unwrappedTypeName }
    var actualTypeName: TypeName? { return typeName.actualTypeName ?? typeName }
    var isTuple: Bool { return typeName.isTuple }
}
extension TupleElement {
    var isOptional: Bool { return typeName.isOptional }
    var isImplicitlyUnwrappedOptional: Bool { return typeName.isImplicitlyUnwrappedOptional }
    var unwrappedTypeName: String { return typeName.unwrappedTypeName }
    var actualTypeName: TypeName? { return typeName.actualTypeName ?? typeName }
    var isTuple: Bool { return typeName.isTuple }
}
extension Typealias {
    var isOptional: Bool { return typeName.isOptional }
    var isImplicitlyUnwrappedOptional: Bool { return typeName.isImplicitlyUnwrappedOptional }
    var unwrappedTypeName: String { return typeName.unwrappedTypeName }
    var actualTypeName: TypeName? { return typeName.actualTypeName ?? typeName }
    var isTuple: Bool { return typeName.isTuple }
}
extension Variable {
    var isOptional: Bool { return typeName.isOptional }
    var isImplicitlyUnwrappedOptional: Bool { return typeName.isImplicitlyUnwrappedOptional }
    var unwrappedTypeName: String { return typeName.unwrappedTypeName }
    var actualTypeName: TypeName? { return typeName.actualTypeName ?? typeName }
    var isTuple: Bool { return typeName.isTuple }
}
