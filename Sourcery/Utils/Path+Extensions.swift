//
//  Path+Extensions.swift
//  Sourcery
//
//  Created by Krunoslav Zaher on 1/6/17.
//  Copyright © 2017 Pixle. All rights reserved.
//

import Foundation
import PathKit

extension Path {
    static func cleanTemporaryDir(name: String) -> Path {
        guard let tempDirURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Sourcery.\(name)") else { fatalError("Unable to get temporary path") }
        _ = try? FileManager.default.removeItem(at: tempDirURL)
        // swiftlint:disable:next force_try
        try! FileManager.default.createDirectory(at: tempDirURL, withIntermediateDirectories: true, attributes: nil)
        return Path(tempDirURL.path)
    }
}
