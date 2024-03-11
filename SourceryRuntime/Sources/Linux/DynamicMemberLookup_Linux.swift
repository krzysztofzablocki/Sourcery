//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

/// Marker protocol so we can know which types support `@dynamicMemberLookup`. Add this to your own types that support
/// lookup by String.
public protocol DynamicMemberLookup {
  /// Get a value for a given `String` key
  subscript(dynamicMember member: String) -> Any? { get }
}

public extension DynamicMemberLookup where Self: RawRepresentable {
  /// Get a value for a given `String` key
  subscript(dynamicMember member: String) -> Any? {
    switch member {
    case "rawValue":
      return rawValue
    default:
      return nil
    }
  }
}
