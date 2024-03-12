//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

#if !canImport(ObjectiveC)
#if canImport(Stencil)
import Stencil
#else
// This is not supposed to work at all, since in Stencil there is a protocol conformance check against `DynamicMemberLookup`,
// and, of course, a substitute with the "same name" but in `Sourcery` will never satisfy that check.
// Here, we are just mimicking `Stencil.DynamicMemberLookup` to showcase what is happening within the `Sourcery` during runtime.

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
#endif

public protocol SourceryDynamicMemberLookup: DynamicMemberLookup {}

#endif
