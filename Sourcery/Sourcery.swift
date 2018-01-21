//
// Created by Krzysztof Zablocki on 14/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import Stencil
import PathKit
import SwiftTryCatch
import SourceryRuntime

class Sourcery {
    public static let version: String = inUnitTests ? "Major.Minor.Patch" : Version.current.value
    public static let generationMarker: String = "// Generated using Sourcery"
    public static let generationHeader = "\(Sourcery.generationMarker) \(Sourcery.version) — https://github.com/krzysztofzablocki/Sourcery\n"
        + "// DO NOT EDIT\n\n"

    enum Error: Swift.Error {
        case containsMergeConflictMarkers
    }

    fileprivate let verbose: Bool
    fileprivate let watcherEnabled: Bool
    fileprivate let arguments: [String: NSObject]
    fileprivate let cacheDisabled: Bool
    fileprivate let prune: Bool

    fileprivate var status = ""
    fileprivate var templatesPaths = Paths(include: [])
    fileprivate var outputPath: Path = ""

    /// Creates Sourcery processor
    ///
    /// - Parameter verbose: Whether to turn on verbose logs.
    /// - Parameter arguments: Additional arguments to pass to templates.
    init(verbose: Bool = false, watcherEnabled: Bool = false, cacheDisabled: Bool = false, prune: Bool = false, arguments: [String: NSObject] = [:]) {
        self.verbose = verbose
        self.arguments = arguments
        self.watcherEnabled = watcherEnabled
        self.cacheDisabled = cacheDisabled
        self.prune = prune
    }

    /// Processes source files and generates corresponding code.
    ///
    /// - Parameters:
    ///   - files: Path of files to process, can be directory or specific file.
    ///   - templatePath: Specific Template to use for code generation.
    ///   - output: Path to output source code to.
    ///   - forceParse: extensions of generated sourcery file that can be parsed
    ///   - watcherEnabled: Whether daemon watcher should be enabled.
    /// - Throws: Potential errors.
    func processFiles(_ source: Source, usingTemplates templatesPaths: Paths, output: Path, forceParse: [String] = []) throws -> [FolderWatcher.Local]? {
        self.templatesPaths = templatesPaths
        self.outputPath = output

        let watchPaths: Paths
        switch source {
        case let .sources(paths):
            watchPaths = paths
        case let .projects(projects):
            watchPaths = Paths(include: projects.map({ $0.root }),
                               exclude: projects.flatMap({ $0.exclude }))
        }

        let process: (Source) throws -> ParsingResult = { source in
            var result: ParsingResult
            switch source {
            case let .sources(paths):
                result = try self.parse(from: paths.include, exclude: paths.exclude, forceParse: forceParse, modules: nil)
            case let .projects(projects):
                var paths = [Path]()
                var modules = [String]()
                try projects.forEach { project in
                    try project.targets.forEach { target in
                        let files: [Path] = try project.file.sourceFilesPaths(targetName: target.name, sourceRoot: project.root.string)
                        files.forEach { file in
                            guard !project.exclude.contains(file) else { return }
                            paths.append(file)
                            modules.append(target.module)
                        }
                    }
                }
                result = try self.parse(from: paths, modules: modules)
            }

            try self.generate(templatesPaths, output: output, parsingResult: result)
            return result
        }

        var result = try process(source)

        guard watcherEnabled else {
            return nil
        }

        Log.info("Starting watching sources.")

        let sourceWatchers = topPaths(from: watchPaths.allPaths).map({ watchPath in
            return FolderWatcher.Local(path: watchPath.string) { events in
                let eventPaths: [Path] = events
                    .filter { $0.flags.contains(.isFile) }
                    .flatMap {
                        let path = Path($0.path)
                        return path.isSwiftSourceFile ? path : nil
                    }

                var pathThatForcedRegeneration: Path? = nil
                for path in eventPaths {
                    guard let file = try? path.read(.utf8) else { continue }
                    if !file.hasPrefix(Sourcery.generationMarker) {
                        pathThatForcedRegeneration = path
                        break
                    }
                }

                if let path = pathThatForcedRegeneration {
                    do {
                        Log.info("Source changed at \(path.string)")
                        result = try process(source)
                    } catch {
                        Log.error(error)
                    }
                }
            }
        })

        Log.info("Starting watching templates.")

        let templateWatchers = topPaths(from: templatesPaths.allPaths).map({ templatesPath in
            return FolderWatcher.Local(path: templatesPath.string) { events in
                let events = events
                    .filter { $0.flags.contains(.isFile) && Path($0.path).isTemplateFile }

                if !events.isEmpty {
                    do {
                        if events.count == 1 {
                            Log.info("Template changed \(events[0].path)")
                        } else {
                            Log.info("Templates changed: ")
                        }
                        try self.generate(Paths(include: [templatesPath]), output: output, parsingResult: result)
                    } catch {
                        Log.error(error)
                    }
                }
            }
        })

        return Array([sourceWatchers, templateWatchers].joined())
    }

    private func topPaths(from paths: [Path]) -> [Path] {
        var top = [(Path, [Path])]()
        paths.forEach { path in
            // See if its already contained by the topDirectories
            guard top.first(where: { (_, children) -> Bool in
                return children.contains(path)
            }) == nil else { return }

            if path.isDirectory {
                top.append((path, (try? path.recursiveChildren()) ?? []))
            } else {
                let dir = path.parent()
                let children = (try? dir.recursiveChildren()) ?? []
                if children.contains(path) {
                    top.append((dir, children))
                } else {
                    top.append((path, []))
                }
            }
        }

        return top.map { $0.0 }
    }

    /// Remove the existing cache artifacts if it exists.
    ///
    /// - Parameter sources: paths of the sources you want to delete the
    static func removeCache(for sources: [Path]) {
        sources.forEach { path in
            let cacheDir = Path.cachesDir(sourcePath: path, createIfMissing: false)
            _ = try? cacheDir.delete()
        }
    }

    fileprivate func templates(from: Paths) throws -> [Template] {
        return try templatePaths(from: from).map {
            #if SWIFT_PACKAGE
                if $0.extension == "swifttemplate" || $0.extension == "ejs" {
                    throw "Swift and JavaScript templates are not supported when using Sourcery built with Swift Package Manager yet. Please use only Stencil templates. See https://github.com/krzysztofzablocki/Sourcery/issues/244 for details."
                } else {
                    return try StencilTemplate(path: $0)
                }
            #else
                if $0.extension == "swifttemplate" {
                    let cachePath = cacheDisabled ? nil : Path.cachesDir(sourcePath: $0)
                    return try SwiftTemplate(path: $0, cachePath: cachePath)
                } else if $0.extension == "ejs" {
                    return try JavaScriptTemplate(path: $0)
                } else {
                    return try StencilTemplate(path: $0)
                }
            #endif
        }
    }

    fileprivate func outputPaths(from: Paths, output: Path) throws -> [Path] {
        return templatePaths(from: from).map { output + generatedPath(for: $0) }
    }

    private func templatePaths(from: Paths) -> [Path] {
        return from.allPaths.filter { $0.isTemplateFile }
    }

}

// MARK: - Parsing

extension Sourcery {
    typealias ParsingResult = (types: Types, inlineRanges: [(file: String, ranges: [String: NSRange])])

    fileprivate func parse(from: [Path], exclude: [Path] = [], forceParse: [String] = [], modules: [String]?) throws -> ParsingResult {
        if let modules = modules {
            precondition(from.count == modules.count, "There should be module for each file to parse")
        }

        Log.info("Scanning sources...")

        var inlineRanges = [(file: String, ranges: [String: NSRange])]()
        var allResults = [FileParserResult]()

        try from.enumerated().forEach { index, from in
            let fileList = from.isDirectory ? try from.recursiveChildren() : [from]
            let sources = try fileList
                .filter { $0.isSwiftSourceFile }
                .filter {
                    let exclude = exclude
                        .map { $0.isDirectory ? try? $0.recursiveChildren() : [$0] }
                        .flatMap({ $0 }).flatMap({ $0 })
                    return !exclude.contains($0)
                }
                .map { (path: $0, contents: try $0.read(.utf8)) }
                .filter {
                    let result = Verifier.canParse(content: $0.contents,
                                                   path: $0.path,
                                                   forceParse: forceParse)
                    if result == .containsConflictMarkers {
                        throw Error.containsMergeConflictMarkers
                    }

                    return result == .approved
                }
                .map {
                    try FileParser(contents: $0.contents, path: $0.path, module: modules?[index])
            }

            var previousUpdate = 0
            var accumulator = 0
            let step = sources.count / 10 // every 10%

            let results = sources.parallelMap({ self.loadOrParse(parser: $0, cachesPath: Path.cachesDir(sourcePath: from)) }, progress: !(verbose || watcherEnabled) ? nil : { _ in
                if accumulator > previousUpdate + step {
                    previousUpdate = accumulator
                    let percentage = accumulator * 100 / sources.count
                    Log.info("Scanning sources... \(percentage)% (\(sources.count) files)")
                }
                accumulator += 1
                })

            allResults.append(contentsOf: results)
        }

        let parserResult = allResults.reduce(FileParserResult(path: nil, module: nil, types: [], typealiases: [])) { acc, next in
            acc.typealiases += next.typealiases
            acc.types += next.types

            // swiftlint:disable:next force_unwrapping
            inlineRanges.append((next.path!, next.inlineRanges))
            return acc
        }

        //! All files have been scanned, time to join extensions with base class
        let types = Composer().uniqueTypes(parserResult)

        Log.info("Found \(types.count) types.")
        return (Types(types: types), inlineRanges)
    }

    private func loadOrParse(parser: FileParser, cachesPath: @autoclosure () -> Path) -> FileParserResult {
        guard let pathString = parser.path else { fatalError("Unable to retrieve \(String(describing: parser.path))") }

        if cacheDisabled {
            return parser.parse()
        }

        let path = Path(pathString)
        let artifacts = cachesPath() + "\(pathString.hash).srf"

        guard artifacts.exists,
              let contentSha = parser.initialContents.sha256(),
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
            Log.warning("Failed to unarchive \(artifacts) due to error, re-parsing")
        }, finallyBlock: {})

        return unarchivedResult
    }
}

// MARK: - Generation
extension Sourcery {

    fileprivate func generate(_ templatePaths: Paths, output: Path, parsingResult: ParsingResult) throws {
        Log.info("Loading templates...")
        let allTemplates = try templates(from: templatePaths)
        Log.info("Loaded \(allTemplates.count) templates.")

        Log.info("Generating code...")
        status = ""

        guard output.isDirectory else {
            let result = try allTemplates.reduce("") { result, template in
                return result + "\n" + (try generate(template, forParsingResult: parsingResult))
            }

            try self.output(result: result, to: output)
            return
        }

        try allTemplates.forEach { template in
            let outputPath = output + generatedPath(for: template.sourcePath)
            let result = try generate(template, forParsingResult: parsingResult)

            try self.output(result: result, to: outputPath)
        }

        Log.info("Finished.")
    }

    private func output(result: String, to outputPath: Path) throws {
        if !result.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            try writeIfChanged(Sourcery.generationHeader + result, to: outputPath)
        } else {
            if prune && outputPath.exists {
                Log.verbose("Removing \(outputPath) as it is empty.")
                do { try outputPath.delete() } catch { Log.error("\(error)") }
            } else {
                Log.verbose("Skipping \(outputPath) as it is empty.")
            }
        }
    }

    private func generate(_ template: Template, forParsingResult parsingResult: ParsingResult) throws -> String {
        guard watcherEnabled else {
            let result = try Generator.generate(parsingResult.types, template: template, arguments: self.arguments)
            return try processRanges(in: parsingResult, result: result)
        }

        var result: String = ""
        SwiftTryCatch.try({
                              result = (try? Generator.generate(parsingResult.types, template: template, arguments: self.arguments)) ?? ""
                          }, catch: { error in
            result = error?.description ?? ""
        }, finallyBlock: {})

        return try processRanges(in: parsingResult, result: result)
    }

    private func processRanges(in parsingResult: ParsingResult, result: String) throws -> String {
        var result = result
        result = try processFileRanges(for: parsingResult, in: result)
        result = try processInlineRanges(for: parsingResult, in: result)
        return TemplateAnnotationsParser.removingEmptyAnnotations(from: result)
    }

    private func processInlineRanges(`for` parsingResult: ParsingResult, in contents: String) throws -> String {
        let inline = TemplateAnnotationsParser.parseAnnotations("inline", contents: contents)

        typealias MappedInlineAnnotations = (
            range: NSRange,
            filePath: Path,
            rangeInFile: NSRange,
            toInsert: String
        )

        try inline.annotatedRanges
            .map { (key: $0, range: $1) }
            .flatMap { (key, range) -> MappedInlineAnnotations? in
                let generatedBody = contents.bridge().substring(with: range)

                guard let (filePath, ranges) = parsingResult.inlineRanges.first(where: { $0.ranges[key] != nil }) else {
                    guard key.hasPrefix("auto:") else { return nil }
                    let autoTypeName = key.trimmingPrefix("auto:").components(separatedBy: ".").dropLast().joined(separator: ".")
                    let toInsert = "\n// sourcery:inline:\(key)\n\(generatedBody)// sourcery:end\n"

                    guard let definition = parsingResult.types.types.first(where: { $0.name == autoTypeName }),
                        let path = definition.path,
                        let rangeInFile = try definition.rangeToAppendBody() else {
                            return nil
                    }
                    return MappedInlineAnnotations(range, path, rangeInFile, toInsert)
                }
                // swiftlint:disable:next force_unwrapping
                return MappedInlineAnnotations(range, Path(filePath), ranges[key]!, generatedBody)
            }
            .sorted { lhs, rhs in
                return lhs.rangeInFile.location > rhs.rangeInFile.location
            }.forEach { (_, path, rangeInFile, toInsert) in
                let content = try path.read(.utf8)
                let updated = content.bridge().replacingCharacters(in: rangeInFile, with: toInsert)
                try writeIfChanged(updated, to: path)
        }

        return inline.contents
    }

    private func processFileRanges(`for` parsingResult: ParsingResult, in contents: String) throws -> String {
        let files = TemplateAnnotationsParser.parseAnnotations("file", contents: contents)

        try files
            .annotatedRanges
            .map { ($0, $1) }
            .forEach({ (filePath, range) in
                var generatedBody = contents.bridge().substring(with: range)
                let path = outputPath + (Path(filePath).extension == nil ? "\(filePath).generated.swift" : filePath)
                if !generatedBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    if path.extension == "swift" {
                        generatedBody = Sourcery.generationHeader + generatedBody
                    }
                    if !path.parent().exists {
                        try path.parent().mkpath()
                    }
                    try writeIfChanged(generatedBody, to: path)
                } else {
                    if prune && outputPath.exists {
                        Log.verbose("Removing \(path) as it is empty.")
                        do { try outputPath.delete() } catch { Log.error("\(error)") }
                    } else {
                        Log.verbose("Skipping \(path) as it is empty.")
                    }
                }
            })
        return files.contents
    }

    fileprivate func writeIfChanged(_ content: String, to path: Path) throws {
        guard path.exists else {
            return try path.write(content)
        }

        let existing = try path.read(.utf8)
        if existing != content {
            try path.write(content)
        }
    }

    internal func generatedPath(`for` templatePath: Path) -> Path {
        return Path("\(templatePath.lastComponentWithoutExtension).generated.swift")
    }
}
