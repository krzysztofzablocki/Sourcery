//
// Created by Krzysztof Zablocki on 13/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import PathKit
import Quick

#if SWIFT_PACKAGE
@testable import SourceryLib
#else
@testable import Sourcery
#endif

private class Reference {}

enum Stubs {
    #if SWIFT_PACKAGE
    static let bundle = Bundle.module
    #else
    static let bundle = Bundle(for: Reference.self)
    #endif
    private static let basePath = bundle.resourcePath.flatMap { Path($0) }!
    static let swiftTemplates = basePath + Path("SwiftTemplates/")
    static let jsTemplates = basePath + Path("JavaScriptTemplates/")
#if canImport(ObjectiveC)
    static let sourceDirectory = basePath + Path("Source/")
#else
    static let sourceDirectory = basePath + Path("Source_Linux/")
#endif
    static let sourceForPerformance = basePath + Path("Performance-Code/")
    static let sourceForDryRun = basePath + Path("DryRun-Code/")
    static let resultDirectory = basePath + Path("Result/")
    static let templateDirectory = basePath + Path("Templates")
    static let errorsDirectory = basePath + Path("Errors/")
    static let configs = basePath + Path("Configs/")

    static func cleanTemporarySourceryDir() -> Path {
        return Path.cleanTemporaryDir(name: "Sourcery")
    }
}
