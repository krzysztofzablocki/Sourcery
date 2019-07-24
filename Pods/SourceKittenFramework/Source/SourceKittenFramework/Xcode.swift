//
//  Xcode.swift
//  SourceKitten
//
//  Created by JP Simard on 7/15/15.
//  Copyright © 2015 SourceKitten. All rights reserved.
//

import Foundation
import Yams

internal enum XcodeBuild {
    /**
    Run `xcodebuild clean build` along with any passed in build arguments.

    - parameter arguments: Arguments to pass to `xcodebuild`.
    - parameter path:      Path to run `xcodebuild` from.

    - returns: `xcodebuild`'s STDERR+STDOUT output combined.
    */
    internal static func cleanBuild(arguments: [String], inPath path: String) -> String? {
        let arguments = arguments + ["clean",
                                     "build",
                                     "CODE_SIGN_IDENTITY=",
                                     "CODE_SIGNING_REQUIRED=NO",
                                     "CODE_SIGNING_ALLOWED=NO"]
        fputs("Running xcodebuild\n", stderr)
        return run(arguments: arguments, inPath: path)
    }

    /**
    Run `xcodebuild` along with any passed in build arguments.

    - parameter arguments: Arguments to pass to `xcodebuild`.
    - parameter path:      Path to run `xcodebuild` from.

    - returns: `xcodebuild`'s STDERR+STDOUT output combined.
    */
    internal static func run(arguments: [String], inPath path: String) -> String? {
        return String(data: launch(arguments: arguments, inPath: path, pipingStandardError: true), encoding: .utf8)
    }

    /**
     Launch `xcodebuild` along with any passed in build arguments.

     - parameter arguments:           Arguments to pass to `xcodebuild`.
     - parameter path:                Path to run `xcodebuild` from.
     - parameter pipingStandardError: Whether to pipe the standard error output. The default value is `true`.

     - returns: `xcodebuild`'s STDOUT output and, optionally, both STDERR+STDOUT output combined.
     */
    internal static func launch(arguments: [String], inPath path: String, pipingStandardError: Bool = true) -> Data {
        let task = Process()
        let pathOfXcodebuild = "/usr/bin/xcodebuild"
        task.arguments = arguments

        let pipe = Pipe()
        task.standardOutput = pipe

        if pipingStandardError {
            task.standardError = pipe
        }

        do {
        #if canImport(Darwin)
            if #available(macOS 10.13, *) {
                task.executableURL = URL(fileURLWithPath: pathOfXcodebuild)
                task.currentDirectoryURL = URL(fileURLWithPath: path)
                try task.run()
            } else {
                task.launchPath = pathOfXcodebuild
                task.currentDirectoryPath = path
                task.launch()
            }
        #elseif compiler(>=5)
            task.executableURL = URL(fileURLWithPath: pathOfXcodebuild)
            task.currentDirectoryURL = URL(fileURLWithPath: path)
            try task.run()
        #else
            task.launchPath = pathOfXcodebuild
            task.currentDirectoryPath = path
            task.launch()
        #endif
        } catch {
            return Data()
        }

        let file = pipe.fileHandleForReading
        defer { file.closeFile() }

        return file.readDataToEndOfFile()
    }

    /**
     Runs `xcodebuild -showBuildSettings` along with any passed in build arguments.

     - parameter arguments: Arguments to pass to `xcodebuild`.
     - parameter path:      Path to run `xcodebuild` from.

     - returns: An array of `XcodeBuildSetting`s.
     */
    internal static func showBuildSettings(arguments xcodeBuildArguments: [String],
                                           inPath: String) -> [XcodeBuildSetting]? {
        let arguments = xcodeBuildArguments + ["-showBuildSettings", "-json"]
        let outputData = XcodeBuild.launch(arguments: arguments, inPath: inPath, pipingStandardError: false)
        return try? JSONDecoder().decode([XcodeBuildSetting].self, from: outputData)
    }
}

/**
Parses likely module name from compiler or `xcodebuild` arguments.

Will use the following values, in this priority: module name, target name, scheme name.

- parameter arguments: Compiler or `xcodebuild` arguments to parse.

- returns: Module name if successful.
*/
internal func moduleName(fromArguments arguments: [String]) -> String? {
    for flag in ["-module-name", "-target", "-scheme"] {
        if let flagIndex = arguments.firstIndex(of: flag), flagIndex + 1 < arguments.count {
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
    guard let indexOfFlagToRemove = args.firstIndex(of: "-output-file-map") else {
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
internal func parseCompilerArguments(xcodebuildOutput: String, language: Language, moduleName: String?) -> [String]? {
    let pattern: String
    if language == .objc {
        pattern = "/usr/bin/clang.*"
    } else if let moduleName = moduleName {
        pattern = "/usr/bin/swiftc.*-module-name \(moduleName) .*"
    } else {
        pattern = "/usr/bin/swiftc.*"
    }
    let regex = try! NSRegularExpression(pattern: pattern, options: []) // Safe to force try
    let range = NSRange(xcodebuildOutput.startIndex..<xcodebuildOutput.endIndex, in: xcodebuildOutput)

    guard let regexMatch = regex.firstMatch(in: xcodebuildOutput, range: range),
        let matchRange = Range(regexMatch.range, in: xcodebuildOutput) else {
            return nil
    }

    let escapedSpacePlaceholder = "\u{0}"
    let args = filter(arguments: String(xcodebuildOutput[matchRange])
        .replacingOccurrences(of: "\\ ", with: escapedSpacePlaceholder)
        .unescaped
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
    let pathOfXcrun = "/usr/bin/xcrun"
    task.arguments = ["--show-sdk-path", "--sdk", "macosx"]

    let pipe = Pipe()
    task.standardOutput = pipe

    do {
    #if canImport(Darwin)
        if #available(macOS 10.13, *) {
            task.executableURL = URL(fileURLWithPath: pathOfXcrun)
            try task.run()
        } else {
            task.launchPath = pathOfXcrun
            task.launch()
        }
    #elseif compiler(>=5)
        task.executableURL = URL(fileURLWithPath: pathOfXcrun)
        try task.run()
    #else
        task.launchPath = pathOfXcrun
        task.launch()
    #endif
    } catch {
        return ""
    }

    let file = pipe.fileHandleForReading
    let sdkPath = String(data: file.readDataToEndOfFile(), encoding: .utf8)
    file.closeFile()
    return sdkPath?.replacingOccurrences(of: "\n", with: "") ?? ""
#endif
}

/**
Extracts compilerArguments by parsing `${PROJECT_TEMP_ROOT}/XCBuildData/ *-manifest.xcbuild`
as `llbuild` manifest file used by New Build System.
```
${PROJECT_TEMP_ROOT}
├── XCBuildData
│   ├── 0a834e06ba44b3930a452b71c1425ef7-desc.xcbuild
│   ├── 0a834e06ba44b3930a452b71c1425ef7-manifest.xcbuild
│   ├── 0f0e5da56188a83852ce7539aad77821-desc.xcbuild
│   ├── 0f0e5da56188a83852ce7539aad77821-manifest.xcbuild
```

- parameter projectTempRoot:   Path.
- parameter moduleName:        Name of the Module for which to extract compiler arguments.

- returns: Compiler arguments, filtered for suitable use by SourceKit.
*/
internal func checkNewBuildSystem(in projectTempRoot: String, moduleName: String? = nil) -> [String]? {
    let xcbuildDataURL = URL(fileURLWithPath: projectTempRoot).appendingPathComponent("XCBuildData")

    do {
        // Find manifests in `PROJECT_TEMP_ROOT`
        let fileURLs = try FileManager.default.contentsOfDirectory(at: xcbuildDataURL, includingPropertiesForKeys: [.fileSizeKey])
        let manifestURLs = try fileURLs.filter { $0.path.hasSuffix("-manifest.xcbuild") }
            .map { (url: $0, size: try $0.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0) }
            .sorted { $0.size < $1.size }
            .map { $0.url }
        let result = manifestURLs.lazy.compactMap { manifestURL -> [String]? in
            guard let contents = try? String(contentsOf: manifestURL),
                let yaml = try? Yams.compose(yaml: contents),
                let commands = (yaml as Node?)?["commands"]?.mapping?.values else {
                    return nil
            }
            for command in commands where command["description"]?.string?.hasSuffix("com.apple.xcode.tools.swift.compiler") ?? false {
                if let args = command["args"]?.sequence,
                    let index = args.firstIndex(of: "-module-name"),
                    moduleName != nil ? args[args.index(after: index)].string == moduleName : true {
                    let fullArgs = args.compactMap { $0.string }
                    let swiftCIndex = fullArgs.firstIndex(of: "--").flatMap(fullArgs.index(after:)) ?? fullArgs.startIndex
                    return Array(fullArgs.suffix(from: fullArgs.index(after: swiftCIndex)))
                }
            }
            return nil
        }.first.map { filter(arguments: $0) }

        if result != nil {
            fputs("Assuming New Build System is used.\n", stderr)
        }
        return result
    } catch {
        return nil
    }
}
