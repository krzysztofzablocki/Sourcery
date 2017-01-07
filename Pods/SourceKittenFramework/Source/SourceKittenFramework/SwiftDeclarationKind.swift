//
//  SwiftDeclarationKind.swift
//  SourceKitten
//
//  Created by JP Simard on 2015-01-05.
//  Copyright (c) 2015 SourceKitten. All rights reserved.
//

/// Swift declaration kinds.
/// Found in `strings SourceKitService | grep source.lang.swift.decl.`.
public enum SwiftDeclarationKind: String, SwiftLangSyntax {
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

// MARK: - migration support
extension SwiftDeclarationKind {
    @available(*, unavailable, renamed: "associatedtype")
    public static var Associatedtype: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "class")
    public static var Class: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "enum")
    public static var Enum: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "enumcase")
    public static var Enumcase: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "enumelement")
    public static var Enumelement: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "extension")
    public static var Extension: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "extensionClass")
    public static var ExtensionClass: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "extensionEnum")
    public static var ExtensionEnum: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "extensionProtocol")
    public static var ExtensionProtocol: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "extensionStruct")
    public static var ExtensionStruct: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "functionAccessorAddress")
    public static var FunctionAccessorAddress: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "functionAccessorDidset")
    public static var FunctionAccessorDidset: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "functionAccessorGetter")
    public static var FunctionAccessorGetter: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "functionAccessorMutableaddress")
    public static var FunctionAccessorMutableaddress: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "functionAccessorSetter")
    public static var FunctionAccessorSetter: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "functionAccessorWillset")
    public static var FunctionAccessorWillset: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "functionConstructor")
    public static var FunctionConstructor: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "functionDestructor")
    public static var FunctionDestructor: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "functionFree")
    public static var FunctionFree: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "functionMethodClass")
    public static var FunctionMethodClass: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "functionMethodInstance")
    public static var FunctionMethodInstance: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "functionMethodStatic")
    public static var FunctionMethodStatic: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "functionOperator")
    public static var FunctionOperator: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "functionOperatorInfix")
    public static var FunctionOperatorInfix: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "functionOperatorPostfix")
    public static var FunctionOperatorPostfix: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "functionOperatorPrefix")
    public static var FunctionOperatorPrefix: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "functionSubscript")
    public static var FunctionSubscript: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "genericTypeParam")
    public static var GenericTypeParam: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "module")
    public static var Module: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "precedenceGroup")
    public static var PrecedenceGroup: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "protocol")
    public static var `Protocol`: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "struct")
    public static var Struct: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "typealias")
    public static var Typealias: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "varClass")
    public static var VarClass: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "varGlobal")
    public static var VarGlobal: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "varInstance")
    public static var VarInstance: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "varLocal")
    public static var VarLocal: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "varParameter")
    public static var VarParameter: SwiftDeclarationKind { fatalError() }

    @available(*, unavailable, renamed: "varStatic")
    public static var VarStatic: SwiftDeclarationKind { fatalError() }
}
