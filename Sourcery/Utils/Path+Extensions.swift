//
//  Path+Extensions.swift
//  Sourcery
//
//  Created by Krunoslav Zaher on 1/6/17.
//  Copyright © 2017 Pixle. All rights reserved.
//

import Foundation
import PathKit

typealias Path = PathKit.Path

extension Path {
    static func cleanTemporaryDir(name: String) -> Path {
        guard let tempDirURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Sourcery.\(name)") else { fatalError("Unable to get temporary path") }
        _ = try? FileManager.default.removeItem(at: tempDirURL)
        // swiftlint:disable:next force_try
        try! FileManager.default.createDirectory(at: tempDirURL, withIntermediateDirectories: true, attributes: nil)
        return Path(tempDirURL.path)
    }

    static func cachesDir(sourcePath: Path, createIfMissing: Bool = true) -> Path {
        var paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
        let path = Path(paths[0]) + "Sourcery" + sourcePath.lastComponent
        if !path.exists && createIfMissing {
            // swiftlint:disable:next force_try
            try! FileManager.default.createDirectory(at: path.url, withIntermediateDirectories: true, attributes: nil)
        }
        return path
    }

    var isTemplateFile: Bool {
        return self.extension == "stencil" ||
            self.extension == "swifttemplate" ||
            self.extension == "ejs"
    }

    var isSwiftSourceFile: Bool {
        return !self.isDirectory && self.extension == "swift"
    }

    func hasExtension(as string: String) -> Bool {
        let extensionString = ".\(string)."
        return self.string.contains(extensionString)
    }

    init(_ string: String, relativeTo relativePath: Path) {
        var path = Path(string)
        if !path.isAbsolute {
            path = (relativePath + path).absolute()
        }
        self.init(path.string)
    }

    var allPaths: [Path] {
        if isDirectory {
            return (try? recursiveChildren()) ?? []
        } else {
            return [self]
        }
    }

}
