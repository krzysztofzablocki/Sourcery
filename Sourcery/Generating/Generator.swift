//
// Created by Krzysztof Zablocki on 13/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import SourceryRuntime

enum Generator {
    static func generate(_ types: Types, template: Template, arguments: [String: NSObject] = [:]) throws -> String {
        Log.verbose("Rendering template \(template.sourcePath)")
        return try template.render(TemplateContext(types: types, arguments: arguments))
    }
}
