//
//  SwiftDeclarationAttributeKind.swift
//  SourceKittenFramework
//
//  Created by Daniel.Metzing on 2018-04-04.
//  Copyright © 2018 SourceKitten. All rights reserved.
//

import Foundation

/// Swift declaration attribute kinds.
/// Found in `strings SourceKitService | grep source.decl.attribute.`.
public enum SwiftDeclarationAttributeKind: String {
    case ibaction = "source.decl.attribute.ibaction"
    case iboutlet = "source.decl.attribute.iboutlet"
    case ibdesignable = "source.decl.attribute.ibdesignable"
    case ibinspectable = "source.decl.attribute.ibinspectable"
    case gkinspectable = "source.decl.attribute.gkinspectable"
    case objc = "source.decl.attribute.objc"
    case objcName = "source.decl.attribute.objc.name"
    case silgenName = "source.decl.attribute._silgen_name"
    case available = "source.decl.attribute.available"
    case `final` = "source.decl.attribute.final"
    case `required` = "source.decl.attribute.required"
    case `optional` = "source.decl.attribute.optional"
    case noreturn = "source.decl.attribute.noreturn"
    case epxorted = "source.decl.attribute._exported"
    case nsCopying = "source.decl.attribute.NSCopying"
    case nsManaged = "source.decl.attribute.NSManaged"
    case `lazy` = "source.decl.attribute.lazy"
    case lldbDebuggerFunction = "source.decl.attribute.LLDBDebuggerFunction"
    case uiApplicationMain = "source.decl.attribute.UIApplicationMain"
    case unsafeNoObjcTaggedPointer = "source.decl.attribute.unsafe_no_objc_tagged_pointer"
    case inline = "source.decl.attribute.inline"
    case semantics = "source.decl.attribute._semantics"
    case dynamic = "source.decl.attribute.dynamic"
    case infix = "source.decl.attribute.infix"
    case prefix = "source.decl.attribute.prefix"
    case postfix = "source.decl.attribute.postfix"
    case transparent = "source.decl.attribute._transparent"
    case requiresStoredProperyInits = "source.decl.attribute.requires_stored_property_inits"
    case nonobjc = "source.decl.attribute.nonobjc"
    case fixedLayout = "source.decl.attribute._fixed_layout"
    case inlineable = "source.decl.attribute._inlineable"
    case specialize = "source.decl.attribute._specialize"
    case objcMembers = "source.decl.attribute.objcMembers"
    case mutating = "source.decl.attribute.mutating"
    case nonmutating = "source.decl.attribute.nonmutating"
    case convenience = "source.decl.attribute.convenience"
    case `override` = "source.decl.attribute.override"
    case silSorted = "source.decl.attribute.sil_stored"
    case `weak` = "source.decl.attribute.weak"
    case effects = "source.decl.attribute.effects"
    case objcBriged = "source.decl.attribute.__objc_bridged"
    case nsApplicationMain = "source.decl.attribute.NSApplicationMain"
    case objcNonLazyRealization = "source.decl.attribute.objc_non_lazy_realization"
    case synthesizedProtocol = "source.decl.attribute.__synthesized_protocol"
    case testable = "source.decl.attribute.testable"
    case alignment = "source.decl.attribute._alignment"
    case `rethrows` = "source.decl.attribute.rethrows"
    case swiftNativeObjcRuntimeBase = "source.decl.attribute._swift_native_objc_runtime_base"
    case indirect = "source.decl.attribute.indirect"
    case warnUnqualifiedAccess = "source.decl.attribute.warn_unqualified_access"
    case cdecl = "source.decl.attribute._cdecl"
    case versioned = "source.decl.attribute._versioned"
    case discardableResult = "source.decl.attribute.discardableResult"
    case implements = "source.decl.attribute._implements"
    case objcRuntimeName = "source.decl.attribute._objcRuntimeName"
    case staticInitializeObjCMetadata = "source.decl.attribute._staticInitializeObjCMetadata"
    case restatedObjCConformance = "source.decl.attribute._restatedObjCConformance"

    #if (swift(>=4.1) || (swift(>=3.3) && !swift(>=4.0)))
    case `private` = "source.decl.attribute.private"
    case `fileprivate` = "source.decl.attribute.fileprivate"
    case `internal` = "source.decl.attribute.internal"
    case `public` = "source.decl.attribute.public"
    case `open` = "source.decl.attribute.open"
    case setterPrivate = "source.decl.attribute.setter_access.private"
    case setterFilePrivate = "source.decl.attribute.setter_access.fileprivate"
    case setterInternal = "source.decl.attribute.setter_access.internal"
    case setterPublic = "source.decl.attribute.setter_access.public"
    case setterOpen = "source.decl.attribute.setter_access.open"
    case optimize = "source.decl.attribute._optimize"
    case consuming = "source.decl.attribute.__consuming"
    case implicitlyUnwrappedOptional = "source.decl.attribute._implicitly_unwrapped_optional"
    #else
    case autoclosure = "source.decl.attribute.autoclosure"
    case noescape = "source.decl.attribute.noescape"
    #endif
}
