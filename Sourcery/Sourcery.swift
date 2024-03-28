//
// Created by Krzysztof Zablocki on 14/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import PathKit
import SourceryFramework
import SourceryUtils
import SourceryRuntime
import SourceryJS
import SourcerySwift
import SourceryStencil
#if canImport(ObjectiveC)
import TryCatch
#endif
import XcodeProj

public class Sourcery {
    public static let version: String = SourceryVersion.current.value
    public static let generationMarker: String = "// Generated using Sourcery"
    public let generationHeader: String

    enum Error: Swift.Error {
        case containsMergeConflictMarkers
    }

    fileprivate let verbose: Bool
    fileprivate let watcherEnabled: Bool
    fileprivate let arguments: [String: NSObject]
    fileprivate let cacheDisabled: Bool
    fileprivate let cacheBasePath: Path?
    fileprivate let buildPath: Path?
    fileprivate let prune: Bool
    fileprivate let serialParse: Bool
    fileprivate var hideVersionHeader: Bool

    fileprivate var status = ""
    fileprivate var templatesPaths = Paths(include: [])
    fileprivate var outputPath = Output("", linkTo: nil)
    fileprivate var isDryRun: Bool = false
    fileprivate lazy var dryOutputBuffer = [DryOutputValue]()

    internal var dryOutput: (String) -> Void = Log.output(_:)

    // content annotated with file annotations per file path to write it to
    fileprivate var fileAnnotatedContent: [Path: [String]] = [:]

    /// Creates Sourcery processor
  public init(verbose: Bool = false, watcherEnabled: Bool = false, cacheDisabled: Bool = false, cacheBasePath: Path? = nil, buildPath: Path? = nil, prune: Bool = false, serialParse: Bool = false, hideVersionHeader: Bool = false, arguments: [String: NSObject] = [:]) {
        self.verbose = verbose
        self.arguments = arguments
        self.watcherEnabled = watcherEnabled
        self.cacheDisabled = cacheDisabled
        self.cacheBasePath = cacheBasePath
        self.buildPath = buildPath
        self.prune = prune
        self.serialParse = serialParse
        self.hideVersionHeader = hideVersionHeader

        var prefix = Sourcery.generationMarker
        if !hideVersionHeader {
          prefix += " \(Sourcery.version)"
        }
        self.generationHeader = "\(prefix) — https://github.com/krzysztofzablocki/Sourcery\n"
        + "// DO NOT EDIT\n"
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
    public func processFiles(_ source: Source, usingTemplates templatesPaths: Paths, output: Output, isDryRun: Bool = false, forceParse: [String] = [], parseDocumentation: Bool = false, baseIndentation: Int) throws -> [FolderWatcher.Local]? {
        self.templatesPaths = templatesPaths
        self.outputPath = output
        self.isDryRun = isDryRun

        let hasSwiftTemplates = templatesPaths.allPaths.contains(where: { $0.extension == "swifttemplate" })

        let watchPaths: Paths
        switch source {
        case let .sources(paths):
            watchPaths = paths
        case let .projects(projects):
            watchPaths = Paths(include: projects.map(\.root),
                               exclude: projects.flatMap(\.exclude))
        case let .packages(packages):
            watchPaths = Paths(include: packages.flatMap({ $0.targets.map(\.root) }),
                               exclude: packages.flatMap({ $0.targets.flatMap(\.excludes) }))
        }

        let process: (Source) throws -> ParsingResult = { source in
            var result: ParsingResult
            switch source {
            case let .sources(paths):
                result = try self.parse(from: paths.include, exclude: paths.exclude, forceParse: forceParse, parseDocumentation: parseDocumentation, modules: nil, requiresFileParserCopy: hasSwiftTemplates)
            case let .projects(projects):
                var paths: [Path] = []
                var modules = [String]()
                projects.forEach { project in
                    project.targets.forEach { target in
                        guard let projectTarget = project.file.target(named: target.name) else { return }

                        let files: [Path] = project.file.sourceFilesPaths(target: projectTarget, sourceRoot: project.root)
                        files.forEach { file in
                            guard !project.exclude.contains(file) else { return }
                            paths.append(file)
                            modules.append(target.module)
                        }
                        for framework in target.xcframeworks {
                            paths.append(framework.swiftInterfacePath)
                            modules.append(target.module)
                        }
                    }
                }
                result = try self.parse(from: paths, forceParse: forceParse, parseDocumentation: parseDocumentation, modules: modules, requiresFileParserCopy: hasSwiftTemplates)
            case let .packages(packages):
                let paths: [Path] = packages.flatMap({ $0.targets.map(\.root) })
                let excludePaths: [Path] = packages.flatMap({ $0.targets.flatMap(\.excludes) })
                let modules = packages.flatMap({ $0.targets.map(\.name) })
                result = try self.parse(from: paths, exclude: excludePaths, forceParse: forceParse, parseDocumentation: parseDocumentation, modules: modules, requiresFileParserCopy: hasSwiftTemplates)
            }

            try self.generate(source: source, templatePaths: templatesPaths, output: output, parsingResult: &result, forceParse: forceParse, baseIndentation: baseIndentation)
            return result
        }

        var result = try process(source)

        result.types.types.forEach {
            $0.cleanUp()
        }
        
        if isDryRun {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data: Data = try encoder.encode(DryOutputSuccess(outputs: self.dryOutputBuffer))
            self.dryOutput(String(data: data, encoding: .utf8) ?? "")
        }

        guard watcherEnabled else {
            return nil
        }

        Log.info("Starting watching sources.")
#if canImport(ObjectiveC)
        let sourceWatchers = topPaths(from: watchPaths.allPaths).map({ watchPath in
            return FolderWatcher.Local(path: watchPath.string) { events in
                let eventPaths: [Path] = events
                    .filter { $0.flags.contains(.isFile) }
                    .compactMap {
                        let path = Path($0.path)
                        return path.isSwiftSourceFile ? path : nil
                    }

                var pathThatForcedRegeneration: Path?
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
                        try self.generate(source: source, templatePaths: Paths(include: [templatesPath]), output: output, parsingResult: &result, forceParse: forceParse, baseIndentation: baseIndentation)
                    } catch {
                        Log.error(error)
                    }
                }
            }
        })

        return Array([sourceWatchers, templateWatchers].joined())
#else
        return []
#endif
    }

    private func topPaths(from paths: [Path]) -> [Path] {
        var top: [(Path, [Path])] = []
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

    /// This function should be used to retrieve the path to the cache instead of `Path.cachesDir`,
    /// as it considers the `--cacheDisabled` and `--cacheBasePath` command line parameters.
    fileprivate func cachesDir(sourcePath: Path, createIfMissing: Bool = true) -> Path? {
        return cacheDisabled
            ? nil
            : Path.cachesDir(sourcePath: sourcePath, basePath: cacheBasePath, createIfMissing: createIfMissing)
    }

    /// Remove the existing cache artifacts if it exists.
    /// Currently this is only called from tests, and the `--cacheDisabled` and `--cacheBasePath` command line parameters are not considered.
    ///
    /// - Parameter sources: paths of the sources you want to delete the
    static func removeCache(for sources: [Path], cacheDisabled: Bool = false, cacheBasePath: Path? = nil) {
        if cacheDisabled {
            return
        }
        sources.forEach { path in
            let cacheDir = Path.cachesDir(sourcePath: path, basePath: cacheBasePath, createIfMissing: false)
            _ = try? cacheDir.delete()
        }
    }

    private func templatePaths(from: Paths) -> [Path] {
        return from.allPaths.filter { $0.isTemplateFile }
    }

}

#if canImport(ObjectiveC)
private extension Sourcery {
    func templates(from: Paths) throws -> [Template] {
        return try templatePaths(from: from).compactMap {
            if $0.extension == "sourcerytemplate" {
                let template = try JSONDecoder().decode(SourceryTemplate.self, from: $0.read())
                switch template.instance.kind {
                case .ejs:
                    guard let ejsPath = EJSTemplate.ejsPath else {
                        Log.warning("Skipping template \($0). JavaScript templates require EJS path to be set manually when using Sourcery built with Swift Package Manager. Use `--ejsPath` command line argument to set it.")
                        return nil
                    }
                    return try JavaScriptTemplate(path: $0, templateString: template.instance.content, ejsPath: ejsPath)
                case .stencil:
                    return try StencilTemplate(path: $0, templateString: template.instance.content)
                }
            } else if $0.extension == "swifttemplate" {
                let cachePath = cachesDir(sourcePath: $0)
                return try SwiftTemplate(path: $0, cachePath: cachePath, version: type(of: self).version, buildPath: buildPath)
            } else if $0.extension == "ejs" {
                guard let ejsPath = EJSTemplate.ejsPath else {
                    Log.warning("Skipping template \($0). JavaScript templates require EJS path to be set manually when using Sourcery built with Swift Package Manager. Use `--ejsPath` command line argument to set it.")
                    return nil
                }
                return try JavaScriptTemplate(path: $0, ejsPath: ejsPath)
            } else {
                return try StencilTemplate(path: $0)
            }
        }
    }
}
#else
private extension Sourcery {
    func templates(from: Paths) throws -> [Template] {
        return try templatePaths(from: from).compactMap {
            if $0.extension == "sourcerytemplate" {
                let template = try JSONDecoder().decode(SourceryTemplate.self, from: $0.read())
                return try StencilTemplate(path: $0, templateString: template.instance.content)
            } else if $0.extension == "swifttemplate" {
                let cachePath = cachesDir(sourcePath: $0)
                return try SwiftTemplate(path: $0, cachePath: cachePath, version: type(of: self).version, buildPath: buildPath)
            } else {
                return try StencilTemplate(path: $0)
            }
        }
    }
}
#endif

// MARK: - Parsing

extension Sourcery {
    typealias ParsingResult = (
        parserResult: FileParserResult?,
        types: Types,
        functions: [SourceryMethod],
        inlineRanges: [(file: String, ranges: [String: NSRange], indentations: [String: String])])

    typealias ParserWrapper = (path: Path, parse: () throws -> FileParserResult?)

  fileprivate func parse(from: [Path], exclude: [Path] = [], forceParse: [String] = [], parseDocumentation: Bool, modules: [String]?, requiresFileParserCopy: Bool) throws -> ParsingResult {
        if let modules = modules {
            precondition(from.count == modules.count, "There should be module for each file to parse")
        }

        let startScan = currentTimestamp()
        Log.info("Scanning sources...")

        var inlineRanges = [(file: String, ranges: [String: NSRange], indentations: [String: String])]()
        var allResults = [(changed: Bool, result: FileParserResult)]()

        let excludeSet = Set(exclude
            .map { $0.isDirectory ? try? $0.recursiveChildren() : [$0] }
            .compactMap({ $0 }).flatMap({ $0 }))

        try from.enumerated().forEach { index, from in
            let fileList = from.isDirectory ? try from.recursiveChildren() : [from]
            let parserGenerator: [ParserWrapper] = fileList
                .filter { $0.isSwiftSourceFile }
                .filter {
                    return !excludeSet.contains($0)
                }
                .map { path in
                    return (path: path, parse: {
                        let module = modules?[index]

                        guard path.exists else {
                            return nil
                        }

                        let content = try path.read(.utf8)
                        let status = Verifier.canParse(content: content, path: path, generationMarker: Sourcery.generationMarker, forceParse: forceParse)
                        switch status {
                        case .containsConflictMarkers:
                            throw Error.containsMergeConflictMarkers
                        case .isCodeGenerated:
                            return nil
                        case .approved:
                            return try makeParser(for: content, forceParse: forceParse, parseDocumentation: parseDocumentation, path: path, module: module).parse()
                        }
                    })
                }

            var lastError: Swift.Error?

            let transform: (ParserWrapper) -> (changed: Bool, result: FileParserResult)? = { parser in
                do {
                    return try self.loadOrParse(parser: parser, cachesPath: self.cachesDir(sourcePath: from))
                } catch {
                    lastError = error
                    Log.error("Unable to parse \(parser.path), error \(error)")
                    return nil
                }
            }

            let results: [(changed: Bool, result: FileParserResult)]
            if serialParse {
                results = parserGenerator.compactMap(transform)
            } else {
                results = parserGenerator.parallelCompactMap(transform: transform)
            }

            if let error = lastError {
                throw error
            }

            if !results.isEmpty {
                allResults.append(contentsOf: results)
            }
        }

        Log.benchmark("\tloadOrParse: \(currentTimestamp() - startScan)")
        let reduceStart = currentTimestamp()

        var allTypealiases = [Typealias]()
        var allTypes = [Type]()
        var allFunctions = [SourceryMethod]()

        for pair in allResults {
            let next = pair.result
            allTypealiases += next.typealiases
            allTypes += next.types
            allFunctions += next.functions

            // swiftlint:disable:next force_unwrapping
            inlineRanges.append((next.path!, next.inlineRanges, next.inlineIndentations))
        }

        let parserResult = FileParserResult(path: nil, module: nil, types: allTypes, functions: allFunctions, typealiases: allTypealiases)

        var parserResultCopy: FileParserResult?
        if requiresFileParserCopy {
            let data = try NSKeyedArchiver.archivedData(withRootObject: parserResult, requiringSecureCoding: false)
            parserResultCopy = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? FileParserResult
        }

        let uniqueTypeStart = currentTimestamp()

        // ! All files have been scanned, time to join extensions with base class
        let (types, functions, typealiases) = Composer.uniqueTypesAndFunctions(parserResult, serial: serialParse)


        let filesThatHadToBeParsed = allResults
            .filter { $0.changed }
            .compactMap { $0.result.path }

        Log.benchmark("\treduce: \(uniqueTypeStart - reduceStart)\n\tcomposer: \(currentTimestamp() - uniqueTypeStart)\n\ttotal: \(currentTimestamp() - startScan)")
        Log.info("Found \(types.count) types in \(allResults.count) files, \(filesThatHadToBeParsed.count) changed from last run.")

        if !filesThatHadToBeParsed.isEmpty, (filesThatHadToBeParsed.count < 50 || Log.level == .verbose) {
            let files = filesThatHadToBeParsed
                .joined(separator: "\n")
            Log.info("Files changed:\n\(files)")
        }
        return (parserResultCopy, Types(types: types, typealiases: typealiases), functions, inlineRanges)
    }

    private func loadOrParse(parser: ParserWrapper, cachesPath: @autoclosure () -> Path?) throws -> (changed: Bool, result: FileParserResult)? {
        guard let cachesPath = cachesPath() else {
            return try parser.parse().map { (changed: true, result: $0) }
        }

        let path = parser.path
        let artifactsPath = cachesPath + "\(path.string.sha256()?.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "\(path.string.hash)").srf"

        guard
            artifactsPath.exists,
            let modifiedDate = path.modifiedDate,
            let unarchived = load(artifacts: artifactsPath.string, modifiedDate: modifiedDate, path: path) else {

            guard let result = try parser.parse() else {
                return nil
            }

            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: result, requiringSecureCoding: false)
                try artifactsPath.write(data)
            } catch {
                fatalError("Unable to save artifacts for \(path) under \(artifactsPath), error: \(error)")
            }

            return (changed: true, result: result)
        }

        return (changed: false, result: unarchived)
    }

    private func load(artifacts: String, modifiedDate: Date, path: Path) -> FileParserResult? {
        var unarchivedResult: FileParserResult?

#if canImport(ObjectiveC)
        SwiftTryCatch.try({
            // this deprecation can't be removed atm, new API is 10x slower
            if let unarchived = NSKeyedUnarchiver.unarchiveObject(withFile: artifacts) as? FileParserResult {
                if unarchived.sourceryVersion == Sourcery.version, unarchived.modifiedDate == modifiedDate {
                    unarchivedResult = unarchived
                }
            }
        }, catch: { _ in
            Log.warning("Failed to unarchive cache for \(path.string) due to error, re-parsing file")
        }, finallyBlock: {})
#else
            // this deprecation can't be removed atm, new API is 10x slower
            if let unarchived = NSKeyedUnarchiver.unarchiveObject(withFile: artifacts) as? FileParserResult {
                if unarchived.sourceryVersion == Sourcery.version, unarchived.modifiedDate == modifiedDate {
                    unarchivedResult = unarchived
                }
            }
#endif

        return unarchivedResult
    }
}

// MARK: - Generation
extension Sourcery {
    private typealias SourceChange = (path: String, rangeInFile: NSRange, newRangeInFile: NSRange)
    private typealias GenerationResult = (String, [SourceChange])

    fileprivate func generate(source: Source, templatePaths: Paths, output: Output, parsingResult: inout ParsingResult, forceParse: [String], baseIndentation: Int) throws {
        let generationStart = currentTimestamp()

        Log.info("Loading templates...")
        let allTemplates = try templates(from: templatePaths)
        Log.info("Loaded \(allTemplates.count) templates.")
        Log.benchmark("\tLoading took \(currentTimestamp() - generationStart)")

        Log.info("Generating code...")
        status = ""

        if output.isDirectory {
            try allTemplates.forEach { template in
                let (result, sourceChanges) = try generate(template, forParsingResult: parsingResult, outputPath: output.path, forceParse: forceParse, baseIndentation: baseIndentation)
                updateRanges(in: &parsingResult, sourceChanges: sourceChanges)
                let outputPath = output.path + generatedPath(for: template.sourcePath)
                try self.output(type: .template(template.sourcePath.string), result: result, to: outputPath)

                if !isDryRun, let linkTo = output.linkTo {
                    linkTo.targets.forEach { target in
                        link(outputPath, to: linkTo, target: target)
                    }
                }
            }
        } else {
            let result = try allTemplates.reduce((contents: "", parsingResult: parsingResult)) { state, template in
                var (result, parsingResult) = state
                let (generatedCode, sourceChanges) = try generate(template, forParsingResult: parsingResult, outputPath: output.path, forceParse: forceParse, baseIndentation: baseIndentation)
                result += "\n" + generatedCode
                updateRanges(in: &parsingResult, sourceChanges: sourceChanges)
                return (result, parsingResult)
            }
            parsingResult = result.parsingResult
            try self.output(type: .allTemplates, result: result.contents, to: output.path)

            if !isDryRun, let linkTo = output.linkTo {
                linkTo.targets.forEach { target in
                    link(output.path, to: linkTo, target: target)
                }
            }
        }

        try fileAnnotatedContent.forEach { (path, contents) in
            try self.output(type: .path(path.string), result: contents.joined(separator: "\n"), to: path)

            if !isDryRun, let linkTo = output.linkTo {
                linkTo.targets.forEach { target in
                    link(path, to: linkTo, target: target)
                }
            }
        }

        if !isDryRun, let linkTo = output.linkTo {
            try linkTo.project.writePBXProj(path: linkTo.projectPath, outputSettings: .init())
        }

        Log.benchmark("\tGeneration took \(currentTimestamp() - generationStart)")
        Log.info("Finished.")
    }

    private func updateRanges(in parsingResult: inout ParsingResult, sourceChanges: [SourceChange]) {
        for (path, rangeInFile, newRangeInFile) in sourceChanges {
            if let inlineRangesIndex = parsingResult.inlineRanges.firstIndex(where: { $0.file == path }) {
                let inlineRanges = parsingResult.inlineRanges[inlineRangesIndex].ranges
                    .mapValues { inlineRange -> NSRange in
                        let change = NSRange(
                            location: newRangeInFile.location,
                            length: newRangeInFile.length - rangeInFile.length
                        )
                        return inlineRange.changingContent(change)
                    }
                parsingResult.inlineRanges[inlineRangesIndex].ranges = inlineRanges
            }

            func stringViewForContent(at path: String) -> StringView? {
                do {
                    return StringView(try Path(path).read(.utf8))
                } catch {
                    return nil
                }
            }

            for type in parsingResult.types.types {
                guard
                    type.path == path,
                    let bytesRange = type.bodyBytesRange,
                    let completeDeclarationRange = type.completeDeclarationRange,
                    let content = stringViewForContent(at: path),
                    let byteRangeInFile = content.NSRangeToByteRange(rangeInFile),
                    let newByteRangeInFile = content.NSRangeToByteRange(newRangeInFile)
                else {
                    continue
                }

                let change = ByteRange(
                    location: newByteRangeInFile.location,
                    length: newByteRangeInFile.length - byteRangeInFile.length
                )
                type.bodyBytesRange = bytesRange.changingContent(change)
                type.completeDeclarationRange = completeDeclarationRange.changingContent(change)
            }
        }
    }

    private func link(_ output: Path, to linkTo: Output.LinkTo, target targetName: String) {
        guard let target = linkTo.project.target(named: targetName) else {
            Log.warning("Unable to find target \(targetName)")
            return
        }

        let sourceRoot = linkTo.projectPath.parent()

        guard let fileGroup = linkTo.project.createGroupIfNeeded(named: linkTo.group, sourceRoot: sourceRoot) else {
            Log.warning("Unable to create group \(String(describing: linkTo.group))")
            return
        }

        do {
            try linkTo.project.addSourceFile(at: output, toGroup: fileGroup, target: target, sourceRoot: sourceRoot)
        } catch {
            Log.warning("Failed to link file at \(output) to \(linkTo.projectPath). \(error)")
        }
    }

    private func output(type: DryOutputType, result: String, to outputPath: Path) throws {
        let resultIsEmpty = result.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        var result = result
        if !resultIsEmpty, outputPath.extension == "swift" {
            result = generationHeader + result
        }

        if isDryRun {
            dryOutputBuffer.append(.init(type: type,
                                         outputPath: outputPath.string,
                                         value: result))
            return
        }

        if !resultIsEmpty {
            if !outputPath.parent().exists {
                try outputPath.parent().mkpath()
            }
            try writeIfChanged(result, to: outputPath)
        } else {
            if prune && outputPath.exists {
                Log.verbose("Removing \(outputPath) as it is empty.")
                do { try outputPath.delete() } catch { Log.error("\(error)") }
            } else {
                Log.verbose("Skipping \(outputPath) as it is empty.")
            }
        }
    }
    private func output(range: NSRange, in file: String,
                        insertedContent: String,
                        updatedContent: @autoclosure () -> String, to path: Path) throws {
        if isDryRun {
            dryOutputBuffer.append(.init(type: .range(range, in: file),
                                         outputPath: path.string,
                                         value: insertedContent))
            return
        }

        try writeIfChanged(updatedContent(), to: path)
    }

    private func generate(_ template: Template, forParsingResult parsingResult: ParsingResult, outputPath: Path, forceParse: [String], baseIndentation: Int) throws -> GenerationResult {
        guard watcherEnabled else {
            let generationStart = currentTimestamp()
            let result = try Generator.generate(parsingResult.parserResult, types: parsingResult.types, functions: parsingResult.functions, template: template, arguments: self.arguments)
            Log.benchmark("\tGenerating \(template.sourcePath.lastComponent) took \(currentTimestamp() - generationStart)")

            return try processRanges(in: parsingResult, result: result, outputPath: outputPath, forceParse: forceParse, baseIndentation: baseIndentation)
        }

        var result: String = ""
#if canImport(ObjectiveC)
        SwiftTryCatch.try({
            do {
                result = try Generator.generate(parsingResult.parserResult, types: parsingResult.types, functions: parsingResult.functions, template: template, arguments: self.arguments)
            } catch {
                Log.error(error)
            }
        }, catch: { error in
            result = error?.description ?? ""
        }, finallyBlock: {})
#else
        do {
                result = try Generator.generate(parsingResult.parserResult, types: parsingResult.types, functions: parsingResult.functions, template: template, arguments: self.arguments)
            } catch {
                Log.error(error)
            }
#endif

        return try processRanges(in: parsingResult, result: result, outputPath: outputPath, forceParse: forceParse, baseIndentation: baseIndentation)
    }

    private func processRanges(in parsingResult: ParsingResult, result: String, outputPath: Path, forceParse: [String], baseIndentation: Int) throws -> GenerationResult {
        let start = currentTimestamp()
        defer {
            Log.benchmark("\t\tProcessing Ranges took \(currentTimestamp() - start)")
        }
        var result = result
        result = processFileRanges(for: parsingResult, in: result, outputPath: outputPath, forceParse: forceParse)
        let sourceChanges: [SourceChange]
        (result, sourceChanges) = try processInlineRanges(for: parsingResult, in: result, forceParse: forceParse, baseIndentation: baseIndentation)
        return (TemplateAnnotationsParser.removingEmptyAnnotations(from: result), sourceChanges)
    }

    private func processInlineRanges(`for` parsingResult: ParsingResult, in contents: String, forceParse: [String], baseIndentation: Int) throws -> GenerationResult {
        var (annotatedRanges, rangesToReplace) = TemplateAnnotationsParser.annotationRanges("inline", contents: contents, forceParse: forceParse)

        typealias MappedInlineAnnotations = (
            range: NSRange,
            filePath: String,
            rangeInFile: NSRange,
            toInsert: String,
            indentation: String
        )

        var sourceChanges: [SourceChange] = []

        try annotatedRanges
            .map { (key: $0, range: $1[0].range) }
            .compactMap { (key, range) -> MappedInlineAnnotations? in
                let generatedBody = contents.bridge().substring(with: range)

                if let (filePath, inlineRanges, inlineIndentations) = parsingResult.inlineRanges.first(where: { $0.ranges[key] != nil }) {
                    // swiftlint:disable:next force_unwrapping
                    return MappedInlineAnnotations(range, filePath, inlineRanges[key]!, generatedBody, inlineIndentations[key] ?? "")
                }


                guard let autoRange = key.range(of: "auto:") else {
                    rangesToReplace.remove(range)
                    return nil
                }

                enum AutoType: String {
                    case after = "after-"
                    case normal = ""
                }

                let autoKey = key[..<autoRange.lowerBound]
                let autoType = AutoType(rawValue: String(autoKey)) ?? .normal

                let autoTypeName = key[autoRange.upperBound..<key.endIndex].components(separatedBy: ".").dropLast().joined(separator: ".")
                var toInsert = "\n// sourcery:inline:\(key)\n\(generatedBody)// sourcery:end"

                guard let definition = parsingResult.types.types.first(where: { $0.name == autoTypeName }),
                    let filePath = definition.path,
                    let path = definition.path.map({ Path($0) }),
                    let contents = try? path.read(.utf8),
                    let bodyRange = bodyRange(for: definition, contentsView: StringView(contents)) else {
                        rangesToReplace.remove(range)
                        return nil
                }
                let bodyEndRange = NSRange(location: NSMaxRange(bodyRange), length: 0)
                let bodyEndLineRange = contents.bridge().lineRange(for: bodyEndRange)
                let bodyEndLine = contents.bridge().substring(with: bodyEndLineRange)
                let indentRange: NSRange?
                if !bodyEndLine.contains("{") {
                    indentRange = (bodyEndLine as NSString).rangeOfCharacter(from: .whitespacesAndNewlines.inverted)
                } else {
                    indentRange = nil
                }
                let rangeInFile: NSRange

                switch autoType {
                case .after:
                    rangeInFile = NSRange(location: max(bodyRange.location, bodyEndLineRange.location) + 1, length: 0)
                case .normal:
                    rangeInFile = NSRange(location: max(bodyRange.location, bodyEndLineRange.location), length: 0)
                    toInsert += "\n"
                }

                let indent = String(repeating: " ", count: (indentRange?.location ?? 0) + baseIndentation)
                return MappedInlineAnnotations(range, filePath, rangeInFile, toInsert, indent)
            }
            .sorted { lhs, rhs in
                return lhs.rangeInFile.location > rhs.rangeInFile.location
            }.forEach { (arg) in
                let (_, filePath, rangeInFile, toInsert, indentation) = arg
                let path = Path(filePath)
                let content = try path.read(.utf8)
                let newContent = indent(toInsert: toInsert, indentation: indentation)

                try output(range: rangeInFile,
                           in: filePath,
                           insertedContent: newContent,
                           updatedContent: content.bridge().replacingCharacters(in: rangeInFile, with: newContent),
                           to: path)

                let newLength = newContent.bridge().length

                sourceChanges.append((
                    path: filePath,
                    rangeInFile: rangeInFile,
                    newRangeInFile: NSRange(location: rangeInFile.location, length: newLength)
                ))
        }


        var bridged = contents.bridge()
        if isDryRun {
            // fix file ranges, cause they not changed
            sourceChanges = sourceChanges.map{ (path, rangeInFile, newRangeInFile) in
                (path, rangeInFile, .init(location: newRangeInFile.location, length: 0))
            }
        }

        rangesToReplace
            .sorted(by: { $0.location > $1.location })
            .forEach {
                bridged = bridged.replacingCharacters(in: $0, with: "") as NSString
            }
        return (bridged as String, sourceChanges)
    }

    private func bodyRange(for type: Type, contentsView: StringView) -> NSRange? {
        guard let bytesRange = type.bodyBytesRange else { return nil }
        return contentsView.byteRangeToNSRange(ByteRange(location: ByteCount(bytesRange.offset), length: ByteCount(bytesRange.length)))
    }

    private func processFileRanges(`for` parsingResult: ParsingResult, in contents: String, outputPath: Path, forceParse: [String]) -> String {
        let files = TemplateAnnotationsParser.parseAnnotations("file", contents: contents, aggregate: true, forceParse: forceParse)

        files
            .annotatedRanges
            .map { ($0, $1) }
            .forEach({ (filePath, ranges) in
                let generatedBody = ranges.map { contents.bridge().substring(with: $0.range) }.joined(separator: "\n")
                let path = outputPath + (Path(filePath).extension == nil ? "\(filePath).generated.swift" : filePath)
                var fileContents = fileAnnotatedContent[path] ?? []
                fileContents.append(generatedBody)
                fileAnnotatedContent[path] = fileContents
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

    private func indent(toInsert: String, indentation: String) -> String {
        guard indentation.isEmpty == false else {
            return toInsert
        }
        let lines = toInsert.components(separatedBy: "\n")
        return lines.enumerated()
            .map { index, line in
                guard !line.isEmpty else {
                    return line
                }

                return index == lines.count - 1 ? line : indentation + line
            }
            .joined(separator: "\n")
    }

    internal func generatedPath(`for` templatePath: Path) -> Path {
        return Path("\(templatePath.lastComponentWithoutExtension).generated.swift")
    }
}
