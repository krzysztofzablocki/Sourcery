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
    public static let version: String = inUnitTests ? "Major.Minor.Patch" : "0.5.2"
    public static let generationMarker: String = "// Generated using Sourcery"
    public static let generationHeader = "\(Sourcery.generationMarker) \(Sourcery.version) — https://github.com/krzysztofzablocki/Sourcery\n"
        + "// DO NOT EDIT\n\n"

    let verbose: Bool
    private(set) var watcherEnabled: Bool = false
    private var status = ""
	let arguments: [String: NSObject]

    private var templatesPath: Path = ""
    private var outputPath: Path = ""

    /// Creates Sourcery processor
    ///
    /// - Parameter verbose: Whether to turn on verbose logs.
    /// - Parameter arguments: Additional arguments to pass to templates.
    public init(verbose: Bool = false, arguments: [String: NSObject] = [:]) {
        self.verbose = verbose
        self.arguments = arguments
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
        self.templatesPath = templatesPath
        self.outputPath = output
        self.watcherEnabled = watcherEnabled

        var types: [Type] = try parseTypes(from: sources)
        try generate(templatePath: templatesPath, output: output, types: types)

        guard watcherEnabled else {
            return nil
        }

        track("Starting watching sources.", skipStatus: true)
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
                    self.track("Source changed: ", terminator: "")
                    types = try self.parseTypes(from: sources)
                    _ = try self.generate(templatePath: templatesPath, output: output, types: types)
                } catch {
                    self.track(error)
                }
            }
        }

        track("Starting watching templates.", skipStatus: true)

        let templateWatcher = FolderWatcher.Local(path: templatesPath.string) { events in
            let events = events
                .filter { $0.flags.contains(.isFile) && $0.path.hasSuffix(".stencil") }

            if !events.isEmpty {
                do {
                    self.track("Templates changed: ", terminator: "")
                    _ = try self.generate(templatePath: templatesPath, output: output, types: types)
                } catch {
                    self.track(error)
                }
            }
        }

        return [sourceWatcher, templateWatcher]
    }

    private func parseTypes(from: Path) throws -> [Type] {
        self.track("Scanning sources...", terminator: "")
        var parserResult: ParserResult = ([], [])

        guard from.isDirectory else {
            let parserResult = try FileParser(verbose: verbose, path: from).parse()
            return Composer(verbose: verbose).uniqueTypes(parserResult)
        }

        let sources = try from
            .recursiveChildren()
            .filter {
                $0.extension == "swift"
            }

        var lastIdx = 0
        let step = sources.count / 10 // every 10%
        try sources.enumerated().forEach { idx, path in
            if idx > lastIdx + step {
                lastIdx = idx
                let percentage = idx * 100 / sources.count
                self.track("Scanning sources... \(percentage)% (\(sources.count) files)", terminator: "")
            }
            let result = try FileParser(verbose: verbose, path: path).parse()
            parserResult.typealiases += result.typealiases
            parserResult.types += result.types
        }

        //! All files have been scanned, time to join extensions with base class
        let types = Composer(verbose: verbose).uniqueTypes(parserResult)

        track("Found \(types.count) types.")
        return types
    }

    private func generate(templatePath: Path, output: Path, types: [Type]) throws {
        track("Loading templates...", terminator: "")
        let allTemplates = try templates(from: templatePath)
        track("Loaded \(allTemplates.count) templates.")

        track("Generating code...", terminator: "")
        status = ""

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

        track("Finished.", skipStatus: true)
    }

    private func generate(_ template: Template, forTypes types: [Type]) throws -> String {
        guard watcherEnabled else {
            return try Generator.generate(types, template: template, arguments: self.arguments)
        }

        var result: String = ""
        SwiftTryCatch.try({
            result = (try? Generator.generate(types, template: template, arguments: self.arguments)) ?? ""
        }, catch: { error in
            result = error?.description ?? ""
        }, finallyBlock: {})

        return result
    }

    internal func generatedPath(`for` templatePath: Path) -> Path {
        return Path("\(templatePath.lastComponentWithoutExtension).generated.swift")
    }

    private func templates(from: Path) throws -> [Template] {
        return try templatePaths(from: from).map {
            if $0.extension == "swifttemplate" {
                return try SwiftTemplate(path: $0)
            } else {
                return try StencilTemplate(path: $0)
            }
        }
    }

    private func outputPaths(from: Path, output: Path) throws -> [Path] {
        return try templatePaths(from: from).map { output + generatedPath(for: $0) }
    }

    private func templatePaths(from: Path) throws -> [Path] {
        guard from.isDirectory else {
            return [from]
        }

        return try from
            .recursiveChildren()
            .filter {
                $0.extension == "stencil"
        }
    }

    private func track(_ message: Any, terminator: String = "\n", skipStatus: Bool = false) {
        if !watcherEnabled || verbose {
            //! console doesn't update in-place so always print on new line
            Swift.print(message)
        }

        guard watcherEnabled && !skipStatus else { return }
        status = String(describing: message) + terminator

        _ = try? outputPaths(from: templatesPath, output: outputPath).forEach { path in
            _ = try? path.write(Sourcery.generationHeader + "STATUS:\n" + status, encoding: .utf8)
        }
    }
}
