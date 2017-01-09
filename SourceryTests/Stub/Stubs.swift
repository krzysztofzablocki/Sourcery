//
// Created by Krzysztof Zablocki on 13/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import PathKit
import Quick

@testable
import Sourcery

private class Reference {}

enum Stubs {
    private static let basePath = Bundle(for: Reference.self).resourcePath.flatMap { Path($0) }!
    static let swiftTemplates = basePath + Path("SwiftTemplates/")
    static let sourceDirectory = basePath + Path("Source/")
    static let sourceForPerformance = basePath + Path("Performance-Code/")
    static let resultDirectory = basePath + Path("Result/")
    static let templateDirectory = basePath + Path("Templates/")

    static func cleanTemporarySourceryDir() -> Path {
        return Path.cleanTemporaryDir(name: "Sourcery")
    }
}
