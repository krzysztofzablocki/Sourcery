#if SWIFT_PACKAGE

import PathKit
import Foundation

// MARK: Conversion
extension Path {
  public var string: String {
    return self.description
  }

  public var url: URL {
    return URL(fileURLWithPath: self.description)
  }
}

import Stencil
extension Template {
  /// Render the given template
  open func render(_ dictionary: [String: Any]? = nil) throws -> String {
    return try render(Context(dictionary: dictionary))
  }
}

#endif
