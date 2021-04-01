//
// Created by Krzysztof Zablocki on 31/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
#if SWIFT_PACKAGE
@testable import SourceryLib
#else
@testable import Sourcery
#endif
@testable import SourceryRuntime

extension String {
    var withoutWhitespaces: String {
        return components(separatedBy: .whitespacesAndNewlines).joined(separator: "")
    }
}

extension Type {
    public func asUnknownException() -> Self {
        isUnknownExtension = true
        return self
    }
}
