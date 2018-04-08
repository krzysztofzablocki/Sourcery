//
//  Xcode.swift
//  SourceKitten
//
//  Created by JP Simard on 7/15/15.
//  Copyright © 2015 SourceKitten. All rights reserved.
//

import Foundation

/**
Run `xcodebuild clean build` along with any passed in build arguments.

- parameter arguments: Arguments to pass to `xcodebuild`.
- parameter path:      Path to run `xcodebuild` from.

- returns: `xcodebuild`'s STDERR+STDOUT output combined.
*/
internal func runXcodeBuild(arguments: [String], inPath path: String) -> String? {
    fputs("Running xcodebuild\n", stderr)

    let task = Process()
    task.launchPath = "/usr/bin/xcodebuild"
    task.currentDirectoryPath = path
    task.arguments = arguments + ["clean", "build", "CODE_SIGN_IDENTITY=", "CODE_SIGNING_REQUIRED=NO"]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe

    task.launch()

    let file = pipe.fileHandleForReading
    defer { file.closeFile() }

    return String(data: file.readDataToEndOfFile(), encoding: .utf8)
}

/**
Parses likely module name from compiler or `xcodebuild` arguments.

Will the following values, in this priority: module name, target name, scheme name.

- parameter arguments: Compiler or `xcodebuild` arguments to parse.

- returns: Module name if successful.
*/
internal func moduleName(fromArguments arguments: [String]) -> String? {
    for flag in ["-module-name", "-target", "-scheme"] {
        if let flagIndex = arguments.index(of: flag), flagIndex + 1 < arguments.count {
            return arguments[flagIndex + 1]
        }
    }
    return nil
}

/**
Partially filters compiler arguments from `xcodebuild` to something that SourceKit/Clang will accept.

- parameter args: Compiler arguments, as parsed from `xcodebuild`.

- returns: A tuple of partially filtered compiler arguments in `.0`, and whether or not there are
          more flags to remove in `.1`.
*/
private func partiallyFilter(arguments args: [String]) -> ([String], Bool) {
    guard let indexOfFlagToRemove = args.index(of: "-output-file-map") else {
        return (args, false)
    }
    var args = args
    args.remove(at: args.index(after: indexOfFlagToRemove))
    args.remove(at: indexOfFlagToRemove)
    return (args, true)
}

/**
Filters compiler arguments from `xcodebuild` to something that SourceKit/Clang will accept.

- parameter args: Compiler arguments, as parsed from `xcodebuild`.

- returns: Filtered compiler arguments.
*/
private func filter(arguments args: [String]) -> [String] {
    var args = args
    args.append(contentsOf: ["-D", "DEBUG"])
    var shouldContinueToFilterArguments = true
    while shouldContinueToFilterArguments {
        (args, shouldContinueToFilterArguments) = partiallyFilter(arguments: args)
    }
    return args.filter {
        ![
            "-parseable-output",
            "-incremental",
            "-serialize-diagnostics",
            "-emit-dependencies"
        ].contains($0)
    }.map {
        if $0 == "-O" {
            return "-Onone"
        } else if $0 == "-DNDEBUG=1" {
            return "-DDEBUG=1"
        }
        return $0
    }
}

/**
Parses the compiler arguments needed to compile the `language` files.

- parameter xcodebuildOutput: Output of `xcodebuild` to be parsed for compiler arguments.
- parameter language:         Language to parse for.
- parameter moduleName:       Name of the Module for which to extract compiler arguments.

- returns: Compiler arguments, filtered for suitable use by SourceKit if `.Swift` or Clang if `.ObjC`.
*/
internal func parseCompilerArguments(xcodebuildOutput: NSString, language: Language, moduleName: String?) -> [String]? {
    let pattern: String
    if language == .objc {
        pattern = "/usr/bin/clang.*"
    } else if let moduleName = moduleName {
        pattern = "/usr/bin/swiftc.*-module-name \(moduleName) .*"
    } else {
        pattern = "/usr/bin/swiftc.*"
    }
    let regex = try! NSRegularExpression(pattern: pattern, options: []) // Safe to force try
    let range = NSRange(location: 0, length: xcodebuildOutput.length)

    guard let regexMatch = regex.firstMatch(in: xcodebuildOutput.bridge(), options: [], range: range) else {
        return nil
    }

    let escapedSpacePlaceholder = "\u{0}"
    let args = filter(arguments: xcodebuildOutput
        .substring(with: regexMatch.range)
        .replacingOccurrences(of: "\\ ", with: escapedSpacePlaceholder)
        .components(separatedBy: " "))

    // Remove first argument (swiftc/clang) and re-add spaces in arguments
    return (args[1..<args.count]).map {
        $0.replacingOccurrences(of: escapedSpacePlaceholder, with: " ")
    }
}

/**
Extracts Objective-C header files and `xcodebuild` arguments from an array of header files followed by `xcodebuild` arguments.

- parameter sourcekittenArguments: Array of Objective-C header files followed by `xcodebuild` arguments.

- returns: Tuple of header files and xcodebuild arguments.
*/
public func parseHeaderFilesAndXcodebuildArguments(sourcekittenArguments: [String]) -> (headerFiles: [String], xcodebuildArguments: [String]) {
    var xcodebuildArguments = sourcekittenArguments
    var headerFiles = [String]()
    while let headerFile = xcodebuildArguments.first, headerFile.bridge().isObjectiveCHeaderFile() {
        headerFiles.append(xcodebuildArguments.remove(at: 0).bridge().absolutePathRepresentation())
    }
    return (headerFiles, xcodebuildArguments)
}

public func sdkPath() -> String {
    #if os(Linux)
    // xcrun does not exist on Linux
    return ""
    #else
    let task = Process()
    task.launchPath = "/usr/bin/xcrun"
    task.arguments = ["--show-sdk-path"]

    let pipe = Pipe()
    task.standardOutput = pipe

    task.launch()

    let file = pipe.fileHandleForReading
    let sdkPath = String(data: file.readDataToEndOfFile(), encoding: .utf8)
    file.closeFile()
    return sdkPath?.replacingOccurrences(of: "\n", with: "") ?? ""
    #endif
}
