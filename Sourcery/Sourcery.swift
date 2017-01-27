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

public class Sourcery {
    public static let version: String = inUnitTests ? "Major.Minor.Patch" : "0.5.3"
    public static let generationMarker: String = "// Generated using Sourcery"
    public static let generationHeader = "\(Sourcery.generationMarker) \(Sourcery.version) — https://github.com/krzysztofzablocki/Sourcery\n"
        + "// DO NOT EDIT\n\n"

    fileprivate let verbose: Bool
    fileprivate let watcherEnabled: Bool
    fileprivate let arguments: [String: NSObject]
    fileprivate let cacheDisabled: Bool

    fileprivate var status = ""
    fileprivate var templatesPath: Path = ""
    fileprivate var outputPath: Path = ""

    /// Creates Sourcery processor
    ///
    /// - Parameter verbose: Whether to turn on verbose logs.
    /// - Parameter arguments: Additional arguments to pass to templates.
    public init(verbose: Bool = false, watcherEnabled: Bool = false, cacheDisabled: Bool = false, arguments: [String: NSObject] = [:]) {
        self.verbose = verbose
        self.arguments = arguments
        self.watcherEnabled = watcherEnabled
        self.cacheDisabled = cacheDisabled
    }

    /// Processes source files and generates corresponding code.
    ///
    /// - Parameters:
    ///   - files: Path of files to process, can be directory or specific file.
    ///   - templatePath: Specific Template to use for code generation.
    ///   - output: Path to output source code to.
    ///   - watcherEnabled: Whether daemon watcher should be enabled.
    /// - Throws: Potential errors.
    public func processFiles(_ sources: Path, usingTemplates templatesPath: Path, output: Path) throws -> [FolderWatcher.Local]? {
        self.templatesPath = templatesPath
        self.outputPath = output

        var result = try parse(from: sources)
        try generate(templatePath: templatesPath, output: output, parsingResult: result)

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
                    result = try self.parse(from: sources)
                    _ = try self.generate(templatePath: templatesPath, output: output, parsingResult: result)
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
                    _ = try self.generate(templatePath: templatesPath, output: output, parsingResult: result)
                } catch {
                    self.track(error)
                }
            }
        }

        return [sourceWatcher, templateWatcher]
    }

    fileprivate func templates(from: Path) throws -> [Template] {
        return try templatePaths(from: from).map {
            if $0.extension == "swifttemplate" {
                return try SwiftTemplate(path: $0)
            } else {
                return try StencilTemplate(path: $0)
            }
        }
    }

    fileprivate func outputPaths(from: Path, output: Path) throws -> [Path] {
        return try templatePaths(from: from).map { output + generatedPath(for: $0) }
    }

    fileprivate func track(_ message: Any, terminator: String = "\n", skipStatus: Bool = false) {
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

    private func templatePaths(from: Path) throws -> [Path] {
        guard from.isDirectory else {
            return [from]
        }

        return try from
                .recursiveChildren()
                .filter {
                    $0.extension == "stencil" || $0.extension == "swifttemplate"
                }
    }
}

// MARK: - Parsing

extension Sourcery {
    typealias ParsingResult = (types: [Type], inlineRanges: [(file: String, ranges: [String: NSRange])])

    fileprivate func parse(from: Path) throws -> ParsingResult {
        self.track("Scanning sources...", terminator: "")

        let cachesPath = Path.cachesDir(sourcePath: from)

        guard from.isDirectory else {
            let parserResult = try FileParser(verbose: verbose, path: from).parse()
            return (Composer(verbose: verbose).uniqueTypes(parserResult), [(from.string, parserResult.inlineRanges)])
        }

        let sources = try from
                .recursiveChildren()
                .filter {
                    $0.extension == "swift"
                }
                .map { try FileParser(verbose: verbose, path: $0) }

        var previousUpdate = 0
        var accumulator = 0
        let step = sources.count / 10 // every 10%

        let results = sources.parallelMap({ self.loadOrParse(parser: $0, cachesPath: cachesPath) }, progress: !(verbose || watcherEnabled) ? nil : { _ in
            if accumulator > previousUpdate + step {
                previousUpdate = accumulator
                let percentage = accumulator * 100 / sources.count
                self.track("Scanning sources... \(percentage)% (\(sources.count) files)", terminator: "")
            }
            accumulator += 1
                })

        var inlineRanges = [(file: String, ranges: [String: NSRange])]()

        let parserResult = results.reduce(FileParserResult(path: nil, types: [], typealiases: [])) { acc, next in
            acc.typealiases += next.typealiases
            acc.types += next.types

            inlineRanges.append( (next.path!, next.inlineRanges) )
            return acc
        }

        //! All files have been scanned, time to join extensions with base class
        let types = Composer(verbose: verbose).uniqueTypes(parserResult)

        track("Found \(types.count) types.")
        return (types, inlineRanges)
    }

    private func loadOrParse(parser: FileParser, cachesPath: Path) -> FileParserResult {
        guard let pathString = parser.path else { fatalError("Unable to retrieve FileParser.path") }
        let path = Path(pathString)
        let artifacts = cachesPath + "\(pathString.hash).srf"

        guard !cacheDisabled,
              artifacts.exists,
              let contents = try? path.read(.utf8),
              let contentSha = contents.sha256(),
              let unarchived = load(artifacts: artifacts.string, contentSha: contentSha) else {

            let result = parser.parse()
            let data = NSKeyedArchiver.archivedData(withRootObject: result)
            do {
                try artifacts.write(data)
            } catch {
                fatalError("Unable to save artifacts for \(path) under \(artifacts), error: \(error)")
            }

            return result
        }

        return unarchived
    }

    private func load(artifacts: String, contentSha: String) -> FileParserResult? {

        var unarchivedResult: FileParserResult? = nil
        SwiftTryCatch.try({
                              if let unarchived = NSKeyedUnarchiver.unarchiveObject(withFile: artifacts) as? FileParserResult, unarchived.sourceryVersion == Sourcery.version, unarchived.contentSha == contentSha {
                                  unarchivedResult = unarchived
                              }
                          }, catch: { _ in
            self.track("Failed to unarchive \(artifacts) due to error, re-parsing")
        }, finallyBlock: {})

        return unarchivedResult
    }
}

// MARK: - Generation
extension Sourcery {
    fileprivate func generate(templatePath: Path, output: Path, parsingResult: ParsingResult) throws {
        track("Loading templates...", terminator: "")
        let allTemplates = try templates(from: templatePath)
        track("Loaded \(allTemplates.count) templates.")

        track("Generating code...", terminator: "")
        status = ""

        guard output.isDirectory else {
            let result = try allTemplates.reduce(Sourcery.generationHeader) { result, template in
                return result + "\n" + (try generate(template, forParsingResult: parsingResult))
            }

            try output.write(result, encoding: .utf8)
            return
        }

        try allTemplates.forEach { template in
            let result = Sourcery.generationHeader + (try generate(template, forParsingResult: parsingResult))
            let outputPath = output + generatedPath(for: template.sourcePath)
            try outputPath.write(result, encoding: .utf8)
        }

        track("Finished.", skipStatus: true)
    }

    private func generate(_ template: Template, forParsingResult parsingResult: ParsingResult) throws -> String {
        guard watcherEnabled else {
            let result = try Generator.generate(parsingResult.types, template: template, arguments: self.arguments)
            return try processInlineRanges(for: parsingResult, in: result)
        }

        var result: String = ""
        SwiftTryCatch.try({
                              result = (try? Generator.generate(parsingResult.types, template: template, arguments: self.arguments)) ?? ""
                          }, catch: { error in
            result = error?.description ?? ""
        }, finallyBlock: {})

        return try processInlineRanges(for: parsingResult, in: result)
    }

    private func processInlineRanges(`for` parsingResult: ParsingResult, in contents: String) throws -> String {
        let inline = InlineParser.parse(contents)

        try inline
                .inlineRanges
                .map { ($0, $1) }
                .sorted { $0.0.1.location > $0.1.1.location }
                .forEach { (key, range) in

                    let generatedBody = contents.bridge().substring(with: range)

                    try parsingResult.inlineRanges.forEach { (filePath, ranges) in

                        if let range = ranges[key] {
                            let path = Path(filePath)
                            let original = try path.read(.utf8)
                            let updated = original.bridge().replacingCharacters(in: range, with: generatedBody)
                            try path.write(updated, encoding: .utf8)
                        }
                    }
                }
        return contents
    }

    internal func generatedPath(`for` templatePath: Path) -> Path {
        return Path("\(templatePath.lastComponentWithoutExtension).generated.swift")
    }
}
