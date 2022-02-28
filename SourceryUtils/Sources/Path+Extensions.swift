//
//  Path+Extensions.swift
//  Sourcery
//
//  Created by Krunoslav Zaher on 1/6/17.
//  Copyright © 2017 Pixle. All rights reserved.
//

import Foundation
import PathKit

public typealias Path = PathKit.Path

extension Path {
    public var modifiedDate: Date? {
        (try? FileManager.default.attributesOfItem(atPath: string)[.modificationDate]) as? Date
    }

    public static func cleanTemporaryDir(name: String) -> Path {
        guard let tempDirURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Sourcery.\(name)") else { fatalError("Unable to get temporary path") }
        _ = try? FileManager.default.removeItem(at: tempDirURL)
        // swiftlint:disable:next force_try
        try! FileManager.default.createDirectory(at: tempDirURL, withIntermediateDirectories: true, attributes: nil)
        return Path(tempDirURL.path)
    }

    /// - returns: The `.cachesDirectory` search path in the user domain, as a `Path`.
    public static var defaultBaseCachePath: Path {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
        let path = paths[0]
        return Path(path)
    }

    /// - parameter _basePath: The value of the `--cachePath` command line parameter, if any.
    /// - note: This function does not consider the `--disableCache` command line parameter.
    ///         It is considered programmer error to call this function when `--disableCache` is specified.
    public static func cachesDir(sourcePath: Path, basePath _basePath: Path?, createIfMissing: Bool = true) -> Path {
        let basePath = _basePath ?? defaultBaseCachePath
        let path = basePath + "Sourcery" + sourcePath.lastComponent
        if !path.exists && createIfMissing {
            // swiftlint:disable:next force_try
            try! FileManager.default.createDirectory(at: path.url, withIntermediateDirectories: true, attributes: nil)
        }
        return path
    }

    public var isTemplateFile: Bool {
        return self.extension == "stencil" ||
            self.extension == "swifttemplate" ||
            self.extension == "ejs" ||
            self.extension == "sourcerytemplate"
    }

    public var isSwiftSourceFile: Bool {
        return !self.isDirectory && (self.extension == "swift" || self.extension == "swiftinterface")
    }

    public func hasExtension(as string: String) -> Bool {
        let extensionString = ".\(string)."
        return self.string.contains(extensionString)
    }

    public init(_ string: String, relativeTo relativePath: Path) {
        var path = Path(string)
        if !path.isAbsolute {
            path = (relativePath + path).absolute()
        }
        self.init(path.string)
    }

    public var allPaths: [Path] {
        if isDirectory {
            return (try? recursiveChildren()) ?? []
        } else {
            return [self]
        }
    }

}
