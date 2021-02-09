//
// StencilSwiftKit
// Copyright © 2021 SwiftGen
// MIT Licence
//

import Foundation
import Stencil

public extension Filters {
  enum Numbers {
    public static func hexToInt(_ value: Any?) throws -> Any? {
      guard let value = value as? String else { throw Filters.Error.invalidInputType }
      return Int(value, radix: 16)
    }

    public static func int255toFloat(_ value: Any?) throws -> Any? {
      guard let value = value as? Int else { throw Filters.Error.invalidInputType }
      return Float(value) / Float(255.0)
    }

    public static func percent(_ value: Any?) throws -> Any? {
      guard let value = value as? Float else { throw Filters.Error.invalidInputType }

      let percent = Int(value * 100.0)
      return "\(percent)%"
    }
  }
}
