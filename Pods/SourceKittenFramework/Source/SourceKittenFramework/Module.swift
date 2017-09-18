//
//  Module.swift
//  SourceKitten
//
//  Created by JP Simard on 2015-01-07.
//  Copyright (c) 2015 SourceKitten. All rights reserved.
//

import Foundation
import Yams

/// Represents source module to be documented.
public struct Module {
    /// Module Name.
    public let name: String
    /// Compiler arguments required by SourceKit to process the source files in this Module.
    public let compilerArguments: [String]
    /// Source files to be documented in this Module.
    public let sourceFiles: [String]

    /// Documentation for this Module. Typically expensive computed property.
    public var docs: [SwiftDocs] {
        var fileIndex = 1
        let sourceFilesCount = sourceFiles.count
        return sourceFiles.flatMap {
            let filename = $0.bridge().lastPathComponent
            if let file = File(path: $0) {
                fputs("Parsing \(filename) (\(fileIndex)/\(sourceFilesCount))\n", stderr)
                fileIndex += 1
                return SwiftDocs(file: file, arguments: compilerArguments)
            }
            fputs("Could not parse `\(filename)`. Please open an issue at https://github.com/jpsim/SourceKitten/issues with the file contents.\n", stderr)
            return nil
        }
    }

    public init?(spmName: String) {
        let yamlPath = ".build/debug.yaml"
        guard let yaml = try? Yams.compose(yaml: String(contentsOfFile: yamlPath, encoding: .utf8)),
            let commands = yaml?["commands"]?.mapping?.values else {
            fatalError("SPM build manifest does not exist at `\(yamlPath)` or does not match expected format.")
        }
        guard let moduleCommand = commands.first(where: { $0["module-name"]?.string == spmName }) else {
            fputs("Could not find SPM module '\(spmName)'. Here are the modules available:\n", stderr)
            let availableModules = commands.flatMap({ $0["module-name"]?.string })
            fputs("\(availableModules.map({ "  - " + $0 }).joined(separator: "\n"))\n", stderr)
            return nil
        }
        guard let imports = moduleCommand["import-paths"]?.array(of: String.self),
              let otherArguments = moduleCommand["other-args"]?.array(of: String.self),
              let sources = moduleCommand["sources"]?.array(of: String.self) else {
                fatalError("SPM build manifest does not match expected format.")
        }
        name = spmName
        compilerArguments = {
            var arguments = sources
            arguments.append(contentsOf: ["-module-name", spmName])
            arguments.append(contentsOf: otherArguments)
            arguments.append(contentsOf: ["-I"])
            arguments.append(contentsOf: imports)
            return arguments
        }()
        sourceFiles = sources
    }

    /**
    Failable initializer to create a Module by the arguments necessary pass in to `xcodebuild` to build it.
    Optionally pass in a `moduleName` and `path`.

    - parameter xcodeBuildArguments: The arguments necessary pass in to `xcodebuild` to build this Module.
    - parameter name:                Module name. Will be parsed from `xcodebuild` output if nil.
    - parameter path:                Path to run `xcodebuild` from. Uses current path by default.
    */
    public init?(xcodeBuildArguments: [String], name: String? = nil, inPath path: String = FileManager.default.currentDirectoryPath) {
        let xcodeBuildOutput = runXcodeBuild(arguments: xcodeBuildArguments, inPath: path) ?? ""
        guard let arguments = parseCompilerArguments(xcodebuildOutput: xcodeBuildOutput.bridge(), language: .swift,
                                                     moduleName: name ?? moduleName(fromArguments: xcodeBuildArguments)) else {
            fputs("Could not parse compiler arguments from `xcodebuild` output.\n", stderr)
            fputs("Please confirm that `xcodebuild` is building a Swift module.\n", stderr)
            let file = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("xcodebuild-\(NSUUID().uuidString).log")
            try! xcodeBuildOutput.data(using: .utf8)?.write(to: file)
            fputs("Saved `xcodebuild` log file: \(file.path)\n", stderr)
            return nil
        }
        guard let moduleName = moduleName(fromArguments: arguments) else {
            fputs("Could not parse module name from compiler arguments.\n", stderr)
            return nil
        }
        self.init(name: moduleName, compilerArguments: arguments)
    }

    /**
    Initializer to create a Module by name and compiler arguments.

    - parameter name:              Module name.
    - parameter compilerArguments: Compiler arguments required by SourceKit to process the source files in this Module.
    */
    public init(name: String, compilerArguments: [String]) {
        self.name = name
        self.compilerArguments = compilerArguments
        sourceFiles = compilerArguments.filter({
            $0.bridge().isSwiftFile() && $0.isFile
        }).map {
            return URL(fileURLWithPath: $0).resolvingSymlinksInPath().path
        }
    }
}

// MARK: CustomStringConvertible

extension Module: CustomStringConvertible {
    /// A textual representation of `Module`.
    public var description: String {
        return "Module(name: \(name), compilerArguments: \(compilerArguments), sourceFiles: \(sourceFiles))"
    }
}
