import Foundation

/// Describes annotated declaration, i.e. type, method, variable, enum case
public protocol Annotated {
    /// Annotations, that were created with // sourcery: annotation1, other = "annotation value", alterantive = 2
    var annotations: [String: NSObject] { get }
}
