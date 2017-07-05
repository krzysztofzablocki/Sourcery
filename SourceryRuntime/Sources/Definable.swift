import Foundation

/// Describes that the object is defined in a context of some `Type`
public protocol Definable: class {
    /// Reference to type name where the object is defined, 
    /// nil if defined outside of any `enum`, `struct`, `class` etc
    var definedInTypeName: TypeName? { get }

    /// Reference to actual type where the object is defined, 
    /// nil if defined outside of any `enum`, `struct`, `class` etc or type is unknown
    var definedInType: Type? { get }
}
