//
//  SwiftDeclarationKind.swift
//  SourceKitten
//
//  Created by JP Simard on 2015-01-05.
//  Copyright (c) 2015 SourceKitten. All rights reserved.
//

/// Swift declaration kinds.
/// Found in `strings SourceKitService | grep source.lang.swift.decl.`.
public enum SwiftDeclarationKind: String {
    /// `associatedtype`.
    case `associatedtype` = "source.lang.swift.decl.associatedtype"
    /// `class`.
    case `class` = "source.lang.swift.decl.class"
    /// `enum`.
    case `enum` = "source.lang.swift.decl.enum"
    /// `enumcase`.
    case enumcase = "source.lang.swift.decl.enumcase"
    /// `enumelement`.
    case enumelement = "source.lang.swift.decl.enumelement"
    /// `extension`.
    case `extension` = "source.lang.swift.decl.extension"
    /// `extension.class`.
    case extensionClass = "source.lang.swift.decl.extension.class"
    /// `extension.enum`.
    case extensionEnum = "source.lang.swift.decl.extension.enum"
    /// `extension.protocol`.
    case extensionProtocol = "source.lang.swift.decl.extension.protocol"
    /// `extension.struct`.
    case extensionStruct = "source.lang.swift.decl.extension.struct"
    /// `function.accessor.address`.
    case functionAccessorAddress = "source.lang.swift.decl.function.accessor.address"
    /// `function.accessor.didset`.
    case functionAccessorDidset = "source.lang.swift.decl.function.accessor.didset"
    /// `function.accessor.getter`.
    case functionAccessorGetter = "source.lang.swift.decl.function.accessor.getter"
    /// `function.accessor.mutableaddress`.
    case functionAccessorMutableaddress = "source.lang.swift.decl.function.accessor.mutableaddress"
    /// `function.accessor.setter`.
    case functionAccessorSetter = "source.lang.swift.decl.function.accessor.setter"
    /// `function.accessor.willset`.
    case functionAccessorWillset = "source.lang.swift.decl.function.accessor.willset"
    /// `function.constructor`.
    case functionConstructor = "source.lang.swift.decl.function.constructor"
    /// `function.destructor`.
    case functionDestructor = "source.lang.swift.decl.function.destructor"
    /// `function.free`.
    case functionFree = "source.lang.swift.decl.function.free"
    /// `function.method.class`.
    case functionMethodClass = "source.lang.swift.decl.function.method.class"
    /// `function.method.instance`.
    case functionMethodInstance = "source.lang.swift.decl.function.method.instance"
    /// `function.method.static`.
    case functionMethodStatic = "source.lang.swift.decl.function.method.static"
    /// `function.operator`.
    case functionOperator = "source.lang.swift.decl.function.operator"
    /// `function.operator.infix`.
    case functionOperatorInfix = "source.lang.swift.decl.function.operator.infix"
    /// `function.operator.postfix`.
    case functionOperatorPostfix = "source.lang.swift.decl.function.operator.postfix"
    /// `function.operator.prefix`.
    case functionOperatorPrefix = "source.lang.swift.decl.function.operator.prefix"
    /// `function.subscript`.
    case functionSubscript = "source.lang.swift.decl.function.subscript"
    /// `generic_type_param`.
    case genericTypeParam = "source.lang.swift.decl.generic_type_param"
    /// `module`.
    case module = "source.lang.swift.decl.module"
    /// `precedencegroup`.
    case precedenceGroup = "source.lang.swift.decl.precedencegroup"
    /// `protocol`.
    case `protocol` = "source.lang.swift.decl.protocol"
    /// `struct`.
    case `struct` = "source.lang.swift.decl.struct"
    /// `typealias`.
    case `typealias` = "source.lang.swift.decl.typealias"
    /// `var.class`.
    case varClass = "source.lang.swift.decl.var.class"
    /// `var.global`.
    case varGlobal = "source.lang.swift.decl.var.global"
    /// `var.instance`.
    case varInstance = "source.lang.swift.decl.var.instance"
    /// `var.local`.
    case varLocal = "source.lang.swift.decl.var.local"
    /// `var.parameter`.
    case varParameter = "source.lang.swift.decl.var.parameter"
    /// `var.static`.
    case varStatic = "source.lang.swift.decl.var.static"
}
