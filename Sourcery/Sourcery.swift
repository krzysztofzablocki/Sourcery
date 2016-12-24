//
// Created by Krzysztof Zablocki on 14/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import Stencil
import PathKit
import KZFileWatchers
import SwiftTryCatch

import Foundation

/// If you specify templatePath as a folder, it will create a Generated[TemplateName].swift file
/// If you specify templatePath as specific file, it will put all generated results into that single file
public class Sourcery {
    public static let version: String = inUnitTests ? "Major.Minor.Patch" : "0.4.8"
    public static let generationMarker: String = "// Generated using Sourcery"
    public static let generationHeader = "\(Sourcery.generationMarker) \(Sourcery.version) — https://github.com/krzysztofzablocki/Sourcery\n"
        + "// DO NOT EDIT\n\n"

    let verbose: Bool
    var watcherEnabled: Bool = false

    /// Creates Sourcery processor
    ///
    /// - Parameter verbose: Whether to turn on verbose logs.
    public init(verbose: Bool = false) {
        self.verbose = verbose
    }

    /// Processes source files and generates corresponding code.
    ///
    /// - Parameters:
    ///   - files: Path of files to process, can be directory or specific file.
    ///   - templatePath: Specific Template to use for code generation.
    ///   - output: Path to output source code to.
    ///   - watcherEnabled: Whether daemon watcher should be enabled.
    /// - Throws: Potential errors.
    public func processFiles(_ sources: Path, usingTemplates templatesPath: Path, output: Path, watcherEnabled: Bool = false) throws -> [FolderWatcher.Local]? {
        self.watcherEnabled = watcherEnabled

        var types: [Type] = try parseTypes(from: sources)
        try generate(templatePath: templatesPath, output: output, types: types)

        guard watcherEnabled else {
            return nil
        }

        print("Starting watching sources.")
        let sourceWatcher = FolderWatcher.Local(path: sources.string) { events in
            let events = events
                .filter { $0.flags.contains(.isFile) && $0.path.hasSuffix(".swift") }

            var shouldRegenerate = false
            for event in events {
                guard let file = try? String(contentsOfFile: event.path, encoding: .utf8) else { continue }
                if !file.hasPrefix(Sourcery.generationMarker) {
                    shouldRegenerate = true
                    break
                }
            }

            if shouldRegenerate {
                do {
                    print("Source changed: ", terminator: "")
                    types = try self.parseTypes(from: sources)
                    _ = try self.generate(templatePath: templatesPath, output: output, types: types)
                } catch {
                    print(error)
                }
            }
        }

        print("Starting watching templates.")

        let templateWatcher = FolderWatcher.Local(path: templatesPath.string) { events in
            let events = events
                .filter { $0.flags.contains(.isFile) && $0.path.hasSuffix(".stencil") }

            if !events.isEmpty {
                do {
                    print("Template changed: ", terminator: "")
                    _ = try self.generate(templatePath: templatesPath, output: output, types: types)
                } catch {
                    print(error)
                }
            }
        }

        return [sourceWatcher, templateWatcher]
    }

    private func parseTypes(from: Path) throws -> [Type] {
        print("Scanning sources...", terminator: "")
        let parser = Parser(verbose: verbose)

        var parserResult: ParserResult = ([], [])

        guard from.isDirectory else {
            let parserResult = try parser.parseFile(from)
            return parser.uniqueTypes(parserResult)
        }

        try from
            .recursiveChildren()
            .filter {
                $0.extension == "swift"
            }
            .forEach { path in
                parserResult = try parser.parseFile(path, existingTypes: parserResult)
        }

        //! All files have been scanned, time to join extensions with base class
        let types = parser.uniqueTypes(parserResult)

        print("Found \(types.count) types.")
        return types
    }

    private func generate(templatePath: Path, output: Path, types: [Type]) throws {
        print("Loading templates...", terminator: "")
        let allTemplates = try templates(from: templatePath)
        print("Loaded \(allTemplates.count) templates.")

        print("Generating code...", terminator: "")

        guard output.isDirectory else {
            let result = try allTemplates.reduce(Sourcery.generationHeader) { result, template in
                return result + "\n" + (try generate(template, forTypes: types))
            }

            try output.write(result, encoding: .utf8)
            return
        }

        try allTemplates.forEach { template in
            let result = Sourcery.generationHeader + (try generate(template, forTypes: types))
            let outputPath = output + generatedPath(for: template.sourcePath)
            try outputPath.write(result, encoding: .utf8)
        }

        print("Finished.")
    }

    private func generate(_ template: Template, forTypes types: [Type]) throws -> String {
        let shouldRecover = watcherEnabled
        guard shouldRecover else {
            return try Generator.generate(types, template: template)
        }

        var result: String = ""
        SwiftTryCatch.try({
            result = (try? Generator.generate(types, template: template)) ?? ""
        }, catch: { error in
            result = error?.description ?? ""
        }, finallyBlock: {})
        return result
    }

    internal func generatedPath(`for` templatePath: Path) -> Path {
        return Path("\(templatePath.lastComponentWithoutExtension).generated.swift")
    }

    private func templates(from: Path) throws -> [SourceryTemplate] {
        guard from.isDirectory else {
            return [try SourceryTemplate(path: from)]
        }

        return try from
            .recursiveChildren()
            .filter {
                $0.extension == "stencil"
            }
            .map {
                try SourceryTemplate(path: $0)
        }
    }
}
