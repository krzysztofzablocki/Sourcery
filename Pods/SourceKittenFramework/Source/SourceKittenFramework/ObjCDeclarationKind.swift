//
//  ObjCDeclarationKind.swift
//  SourceKitten
//
//  Created by JP Simard on 7/15/15.
//  Copyright © 2015 SourceKitten. All rights reserved.
//

#if !os(Linux)

#if SWIFT_PACKAGE
import Clang_C
#endif

/**
Objective-C declaration kinds.
More or less equivalent to `SwiftDeclarationKind`, but with made up values because there's no such
thing as SourceKit for Objective-C.
*/
public enum ObjCDeclarationKind: String {
    /// `category`.
    case category = "sourcekitten.source.lang.objc.decl.category"
    /// `class`.
    case `class` = "sourcekitten.source.lang.objc.decl.class"
    /// `constant`.
    case constant = "sourcekitten.source.lang.objc.decl.constant"
    /// `enum`.
    case `enum` = "sourcekitten.source.lang.objc.decl.enum"
    /// `enumcase`.
    case enumcase = "sourcekitten.source.lang.objc.decl.enumcase"
    /// `initializer`.
    case initializer = "sourcekitten.source.lang.objc.decl.initializer"
    /// `method.class`.
    case methodClass = "sourcekitten.source.lang.objc.decl.method.class"
    /// `method.instance`.
    case methodInstance = "sourcekitten.source.lang.objc.decl.method.instance"
    /// `property`.
    case property = "sourcekitten.source.lang.objc.decl.property"
    /// `protocol`.
    case `protocol` = "sourcekitten.source.lang.objc.decl.protocol"
    /// `typedef`.
    case typedef = "sourcekitten.source.lang.objc.decl.typedef"
    /// `function`.
    case function = "sourcekitten.source.lang.objc.decl.function"
    /// `mark`.
    case mark = "sourcekitten.source.lang.objc.mark"
    /// `struct`
    case `struct` = "sourcekitten.source.lang.objc.decl.struct"
    /// `field`
    case field = "sourcekitten.source.lang.objc.decl.field"
    /// `ivar`
    case ivar = "sourcekitten.source.lang.objc.decl.ivar"
    /// `ModuleImport`
    case moduleImport = "sourcekitten.source.lang.objc.module.import"
    /// `UnexposedDecl`
    case unexposedDecl = "sourcekitten.source.lang.objc.decl.unexposed"

    // swiftlint:disable:next cyclomatic_complexity
    public init(_ cursorKind: CXCursorKind) {
        switch cursorKind {
        case CXCursor_ObjCCategoryDecl: self = .category
        case CXCursor_ObjCInterfaceDecl: self = .class
        case CXCursor_EnumDecl: self = .enum
        case CXCursor_EnumConstantDecl: self = .enumcase
        case CXCursor_ObjCClassMethodDecl: self = .methodClass
        case CXCursor_ObjCInstanceMethodDecl: self = .methodInstance
        case CXCursor_ObjCPropertyDecl: self = .property
        case CXCursor_ObjCProtocolDecl: self = .protocol
        case CXCursor_TypedefDecl: self = .typedef
        case CXCursor_VarDecl: self = .constant
        case CXCursor_FunctionDecl: self = .function
        case CXCursor_StructDecl: self = .struct
        case CXCursor_FieldDecl: self = .field
        case CXCursor_ObjCIvarDecl: self = .ivar
        case CXCursor_ModuleImportDecl: self = .moduleImport
        case CXCursor_UnexposedDecl: self = .unexposedDecl
        default: fatalError("Unsupported CXCursorKind: \(clang_getCursorKindSpelling(cursorKind))")
        }
    }
}
#endif
