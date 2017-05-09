//
// Created by Krzysztof Zablocki on 31/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import SourceryRuntime

/// Extends type so that inner types can be accessed via KVC e.g. Parent.Inner.Children
extension Type {
    /// :nodoc:
    override public func value(forUndefinedKey key: String) -> Any? {
        if let innerType = containedTypes.lazy.filter({ $0.localName == key }).first {
            return innerType
        }

        return super.value(forUndefinedKey: key)
    }
}
