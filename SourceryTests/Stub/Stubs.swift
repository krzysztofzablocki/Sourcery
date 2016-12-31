//
// Created by Krzysztof Zablocki on 13/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import PathKit
import Quick

private class Reference {}

enum Stubs {
    private static let basePath = Bundle(for: Reference.self).resourcePath.flatMap { Path($0) }!
    static let sourceDirectory = basePath + Path("Source/")
    static let sourceForPerformance = basePath + Path("Performance-Code/")
    static let resultDirectory = basePath + Path("Result/")
    static let templateDirectory = basePath + Path("Templates/")

    static func cleanTemporarySourceryDir() -> Path {
        guard let tempDirURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Sourcery") else { fatalError("Unable to get temporary path") }
        _ = try? FileManager.default.removeItem(at: tempDirURL)
        // swiftlint:disable:next force_try
        try! FileManager.default.createDirectory(at: tempDirURL, withIntermediateDirectories: true, attributes: nil)
        return Path(tempDirURL.path)
    }
}
