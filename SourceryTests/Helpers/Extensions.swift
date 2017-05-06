//
// Created by Krzysztof Zablocki on 31/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
@testable import Sourcery
@testable import SourceryRuntime

extension String {
    var withoutWhitespaces: String {
        return components(separatedBy: .whitespacesAndNewlines).joined(separator: "")
    }
}
