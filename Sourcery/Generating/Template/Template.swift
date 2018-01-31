//
// Created by Krzysztof Zablocki on 31/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import PathKit
import SourceryRuntime

/// Generic template that can be used for any of the Sourcery output variants
protocol Template {
    /// Path to template
    var sourcePath: Path { get }

    /// Generate
    ///
    /// - Parameter types: List of types to generate.
    /// - Parameter arguments: List of template arguments.
    /// - Returns: Generated code.
    /// - Throws: `Throws` template errors
    func render(_ context: TemplateContext) throws -> String
}
