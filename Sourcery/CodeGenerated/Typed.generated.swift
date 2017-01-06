// Generated using Sourcery 0.5.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

extension Enum.Case.AssociatedValue {
    var isOptional: Bool { return typeName.isOptional }
    var isImplicitlyUnwrappedOptional: Bool { return typeName.isImplicitlyUnwrappedOptional }
    var unwrappedTypeName: String { return typeName.unwrappedTypeName }
    var actualTypeName: TypeName? { return typeName.actualTypeName ?? typeName }
    var isTuple: Bool { return typeName.isTuple }
}
extension Method.Parameter {
    var isOptional: Bool { return typeName.isOptional }
    var isImplicitlyUnwrappedOptional: Bool { return typeName.isImplicitlyUnwrappedOptional }
    var unwrappedTypeName: String { return typeName.unwrappedTypeName }
    var actualTypeName: TypeName? { return typeName.actualTypeName ?? typeName }
    var isTuple: Bool { return typeName.isTuple }
}
extension TupleType.Element {
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
