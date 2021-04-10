//
// Created by Krzysztof Zablocki on 14/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import PathKit
import SourceryFramework
import SourceryRuntime
import TryCatch

public typealias ParsingResult = (
    parserResult: FileParserResult?,
    types: Types,
    functions: [SourceryMethod],
    inlineRanges: [(file: String, ranges: [String: NSRange], indentations: [String: String])])

public class SourceParser {
    typealias ParserWrapper = (path: Path, parse: () throws -> FileParserResult)

    enum Error: Swift.Error {
        case containsMergeConflictMarkers
    }

    private let version: String
    private let generationMarker: String
    private let verbose: Bool
    private let watcherEnabled: Bool
    private let cacheDisabled: Bool
    private let cacheBasePath: Path?

    private var numberOfFilesThatHadToBeParsed: Int32 = 0
    private func incrementFileParsedCount() {
        OSAtomicIncrement32(&numberOfFilesThatHadToBeParsed)
    }

    /// Creates Source processor
    public init(version: String, generationMarker: String, verbose: Bool, watcherEnabled: Bool, cacheDisabled: Bool, cacheBasePath: Path?) {
        self.version = version
        self.generationMarker = generationMarker
        self.verbose = verbose
        self.watcherEnabled = watcherEnabled
        self.cacheDisabled = cacheDisabled
        self.cacheBasePath = cacheBasePath
    }

    /// Processes source files and generates corresponding code.
    ///
    /// - Parameters:
    ///   - source: Path of files to process, can be directory or specific file.
    ///   - forceParse: extensions of generated sourcery file that can be parsed
    ///   - hasSwiftTemplates: TODO...
    /// - Throws: Potential errors.
    public func processSource(_ source: Source, forceParse: [String], hasSwiftTemplates: Bool) throws -> ParsingResult {
        var result: ParsingResult
        switch source {
        case let .sources(paths):
            result = try parse(from: paths.include, exclude: paths.exclude, forceParse: forceParse, modules: nil, requiresFileParserCopy: hasSwiftTemplates)
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
                }
            }
            result = try parse(from: paths, modules: modules, requiresFileParserCopy: hasSwiftTemplates)
        }

        return result
    }

    /// This function should be used to retrieve the path to the cache instead of `Path.cachesDir`,
    /// as it considers the `--cacheDisabled` and `--cacheBasePath` command line parameters.
    private func cachesDir(sourcePath: Path, createIfMissing: Bool = true) -> Path? {
        return cacheDisabled
            ? nil
            : Path.cachesDir(sourcePath: sourcePath, basePath: cacheBasePath, createIfMissing: createIfMissing)
    }

    private func parse(from: [Path], exclude: [Path] = [], forceParse: [String] = [], modules: [String]?, requiresFileParserCopy: Bool) throws -> ParsingResult {
        if let modules = modules {
            precondition(from.count == modules.count, "There should be module for each file to parse")
        }

        let startScan = currentTimestamp()
        Log.info("Scanning sources...")

        var inlineRanges = [(file: String, ranges: [String: NSRange], indentations: [String: String])]()
        var allResults = [FileParserResult]()

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
                    return (path: path, makeParser: {
                        let module = modules?[index]

                        guard path.exists else {
                            return FileParserResult(path: path.string, module: module, types: [], functions: [])
                        }

                        let content = try path.read(.utf8)
                        let status = Verifier.canParse(content: content, path: path, generationMarker: self.generationMarker, forceParse: forceParse)
                        switch status {
                        case .containsConflictMarkers:
                            throw Error.containsMergeConflictMarkers
                        case .isCodeGenerated:
                            return FileParserResult(path: path.string, module: module, types: [], functions: [])
                        case .approved:
                            return try makeParser(for: content, path: path, module: module).parse()
                        }
                    })
                }

            var previousUpdate = 0
            var accumulator = 0
            let step = parserGenerator.count / 10 // every 10%
            numberOfFilesThatHadToBeParsed = 0

            let results = try parserGenerator.parallelMap({
                try self.loadOrParse(parser: $0, cachesPath: cachesDir(sourcePath: from))
            }, progress: !(verbose || watcherEnabled) ? nil : { _ in
                if accumulator > previousUpdate + step {
                    previousUpdate = accumulator
                    let percentage = accumulator * 100 / parserGenerator.count
                    Log.info("Scanning sources... \(percentage)% (\(parserGenerator.count) files)")
                }
                accumulator += 1
                })

            if !results.isEmpty {
                allResults.append(contentsOf: results)
            }
        }

        Log.benchmark("\tloadOrParse: \(currentTimestamp() - startScan)")

        let parserResult = allResults.reduce(FileParserResult(path: nil, module: nil, types: [], functions: [], typealiases: [])) { acc, next in
            acc.typealiases += next.typealiases
            acc.types += next.types
            acc.functions += next.functions

            // swiftlint:disable:next force_unwrapping
            inlineRanges.append((next.path!, next.inlineRanges, next.inlineIndentations))
            return acc
        }

        var parserResultCopy: FileParserResult?
        if requiresFileParserCopy {
            let data = NSKeyedArchiver.archivedData(withRootObject: parserResult)
            parserResultCopy = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? FileParserResult
        }

        let uniqueTypeStart = currentTimestamp()

        //! All files have been scanned, time to join extensions with base class
        let (types, functions, typealiases) = Composer.uniqueTypesAndFunctions(parserResult)

        Log.benchmark("\tcombiningTypes: \(currentTimestamp() - uniqueTypeStart)\n\ttotal: \(currentTimestamp() - startScan)")
        Log.info("Found \(types.count) types in \(allResults.count) files, \(numberOfFilesThatHadToBeParsed) changed from last run.")
        return (parserResultCopy, Types(types: types, typealiases: typealiases), functions, inlineRanges)
    }

    private func loadOrParse(parser: ParserWrapper, cachesPath: @autoclosure () -> Path?) throws -> FileParserResult {
        guard let cachesPath = cachesPath() else {
            incrementFileParsedCount()
            return try parser.parse()
        }

        let path = parser.path
        let artifactsPath = cachesPath + "\(path.string.hash).srf"

        guard
            artifactsPath.exists,
            let modifiedDate = path.modifiedDate,
            let unarchived = load(artifacts: artifactsPath.string, modifiedDate: modifiedDate, path: path) else {

            incrementFileParsedCount()
            let result = try parser.parse()

            let data = NSKeyedArchiver.archivedData(withRootObject: result)
            do {
                try artifactsPath.write(data)
            } catch {
                fatalError("Unable to save artifacts for \(path) under \(artifactsPath), error: \(error)")
            }

            return result
        }

        return unarchived
    }

    private func load(artifacts: String, modifiedDate: Date, path: Path) -> FileParserResult? {
        var unarchivedResult: FileParserResult?
        SwiftTryCatch.try({

            if let unarchived = NSKeyedUnarchiver.unarchiveObject(withFile: artifacts) as? FileParserResult {
                if unarchived.sourceryVersion == self.version, unarchived.modifiedDate == modifiedDate {
                    unarchivedResult = unarchived
                }
            }
        }, catch: { _ in
            Log.warning("Failed to unarchive cache for \(path.string) due to error, re-parsing file")
        }, finallyBlock: {})

        return unarchivedResult
    }
}
