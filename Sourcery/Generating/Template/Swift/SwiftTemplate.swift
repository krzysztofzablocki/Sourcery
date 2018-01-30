//
//  SwiftTemplate.swift
//  Sourcery
//
//  Created by Krunoslav Zaher on 12/30/16.
//  Copyright © 2016 Pixle. All rights reserved.
//

#if SWIFT_PACKAGE
#else
import Foundation
import SourceryRuntime
import SourcerySwift

extension SwiftTemplate: Template {

    func render(_ context: TemplateContext) throws -> String {
        return try self.render(context as Any)
    }

}
#endif
