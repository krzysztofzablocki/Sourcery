//
// Created by Krzysztof Zablocki on 13/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

/// Defines the Access Level
enum AccessLevel: String {
    case `internal`
    case `private`
    case `fileprivate`
    case `public`
    case `open`
    case none

    var rawValue: String {
        switch self {
        case .internal:
            return "internal"
        case .private:
            return "private"
        case .fileprivate:
            return "fileprivate"
        case .public:
            return "public"
        case .open:
            return "open"
        case .none:
            return ""
        }
    }
}
