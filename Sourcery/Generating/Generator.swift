//
// Created by Krzysztof Zablocki on 13/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import Stencil

enum Generator {
    static func generate(_ types: Types, template: Template, arguments: [String: NSObject] = [:]) throws -> String {
        Log.info("Rendering template \(template.sourcePath)")
        return try template.render(types: types, arguments: arguments)
    }
}
