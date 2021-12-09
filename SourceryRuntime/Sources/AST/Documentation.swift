import Foundation

public typealias Documentation = [String]

/// Describes a declaration with documentation, i.e. type, method, variable, enum case
public protocol Documented {
    var documentation: Documentation { get }
}
