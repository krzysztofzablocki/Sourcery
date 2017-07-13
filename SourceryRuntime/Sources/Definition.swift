import Foundation

/// Describes that the object is defined in a context of some `Type`
public protocol Definition: class {
    /// Reference to type name where the object is defined, 
    /// nil if defined outside of any `enum`, `struct`, `class` etc
    var definedInTypeName: TypeName? { get }

    /// Reference to actual type where the object is defined, 
    /// nil if defined outside of any `enum`, `struct`, `class` etc or type is unknown
    var definedInType: Type? { get }

    // sourcery: skipJSExport
    /// Reference to actual type name where the method is defined if declaration uses typealias, otherwise just a `definedInTypeName`
    var actualDefinedInTypeName: TypeName? { get }
}
