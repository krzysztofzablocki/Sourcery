//
// Created by Krzysztof Zablocki on 14/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import PathKit
import SourceryParser
import SourceryFramework
import SourceryUtils
import SourceryRuntime
import SourceryJS
import SourcerySwift
import SourceryStencil
import TryCatch
import XcodeProj

class Sourcery {
    public static let version: String = SourceryVersion.current.value
    public static let generationMarker: String = "// Generated using Sourcery"
    public static let generationHeader = "\(Sourcery.generationMarker) \(Sourcery.version) — https://github.com/krzysztofzablocki/Sourcery\n"
        + "// DO NOT EDIT\n"

    fileprivate let verbose: Bool
    fileprivate let watcherEnabled: Bool
    fileprivate let arguments: [String: NSObject]
    fileprivate let cacheDisabled: Bool
    fileprivate let cacheBasePath: Path?
    fileprivate let prune: Bool

    fileprivate var status = ""
    fileprivate var templatesPaths = Paths(include: [])
    fileprivate var outputPath = Output("", linkTo: nil)

    // content annotated with file annotations per file path to write it to
    fileprivate var fileAnnotatedContent: [Path: [String]] = [:]

    private let sourceParser: SourceParser

    /// Creates Sourcery processor
    init(verbose: Bool = false, watcherEnabled: Bool = false, cacheDisabled: Bool = false, cacheBasePath: Path? = nil, prune: Bool = false, arguments: [String: NSObject] = [:]) {
        self.verbose = verbose
        self.arguments = arguments
        self.watcherEnabled = watcherEnabled
        self.cacheDisabled = cacheDisabled
        self.cacheBasePath = cacheBasePath
        self.prune = prune
        self.sourceParser = SourceParser(version: Sourcery.version, generationMarker: Sourcery.generationMarker, verbose: verbose, watcherEnabled: watcherEnabled, cacheDisabled: cacheDisabled, cacheBasePath: cacheBasePath)
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
    func processFiles(_ source: Source, usingTemplates templatesPaths: Paths, output: Output, forceParse: [String] = []) throws -> [FolderWatcher.Local]? {
        self.templatesPaths = templatesPaths
        self.outputPath = output

        let hasSwiftTemplates = templatesPaths.allPaths.contains(where: { $0.extension == "swifttemplate" })

        let watchPaths: Paths
        switch source {
        case let .sources(paths):
            watchPaths = paths
        case let .projects(projects):
            watchPaths = Paths(include: projects.map({ $0.root }),
                               exclude: projects.flatMap({ $0.exclude }))
        }

        var result = try self.sourceParser.processSource(source, forceParse: forceParse, hasSwiftTemplates: hasSwiftTemplates)

        try self.generate(source: source, templatePaths: templatesPaths, output: output, parsingResult: result)

        guard watcherEnabled else {
            return nil
        }

        Log.info("Starting watching sources.")

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
                        result = try self.sourceParser.processSource(source, forceParse: forceParse, hasSwiftTemplates: hasSwiftTemplates)
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
                        try self.generate(source: source, templatePaths: Paths(include: [templatesPath]), output: output, parsingResult: result)
                    } catch {
                        Log.error(error)
                    }
                }
            }
        })

        return Array([sourceWatchers, templateWatchers].joined())
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

    fileprivate func templates(from: Paths) throws -> [Template] {
        return try templatePaths(from: from).compactMap {
            if $0.extension == "swifttemplate" {
                let cachePath = cachesDir(sourcePath: $0)
                return try SwiftTemplate(path: $0, cachePath: cachePath, version: type(of: self).version)
            } else if $0.extension == "ejs" {
                guard EJSTemplate.ejsPath != nil else {
                    Log.warning("Skipping template \($0). JavaScript templates require EJS path to be set manually when using Sourcery built with Swift Package Manager. Use `--ejsPath` command line argument to set it.")
                    return nil
                }
                return try JavaScriptTemplate(path: $0)
            } else {
                return try StencilTemplate(path: $0)
            }
        }
    }

    private func templatePaths(from: Paths) -> [Path] {
        return from.allPaths.filter { $0.isTemplateFile }
    }

}

// MARK: - Generation
extension Sourcery {

    fileprivate func generate(source: Source, templatePaths: Paths, output: Output, parsingResult: ParsingResult) throws {
        let generationStart = currentTimestamp()

        Log.info("Loading templates...")
        let allTemplates = try templates(from: templatePaths)
        Log.info("Loaded \(allTemplates.count) templates.")
        Log.benchmark("\tLoading took \(currentTimestamp() - generationStart)")

        Log.info("Generating code...")
        status = ""

        if output.isDirectory {
            try allTemplates.forEach { template in
                let result = try generate(template, forParsingResult: parsingResult, outputPath: output.path)
                let outputPath = output.path + generatedPath(for: template.sourcePath)
                try self.output(result: result, to: outputPath)

                if let linkTo = output.linkTo {
                    link(outputPath, to: linkTo)
                }
            }
        } else {
            let result = try allTemplates.reduce("") { result, template in
                return result + "\n" + (try generate(template, forParsingResult: parsingResult, outputPath: output.path))
            }
            try self.output(result: result, to: output.path)

            if let linkTo = output.linkTo {
                link(output.path, to: linkTo)
            }
        }

        try fileAnnotatedContent.forEach { (path, contents) in
            try self.output(result: contents.joined(separator: "\n"), to: path)

            if let linkTo = output.linkTo {
                link(path, to: linkTo)
            }
        }

        if let linkTo = output.linkTo {
            try linkTo.project.writePBXProj(path: linkTo.projectPath, outputSettings: .init())
        }

        Log.benchmark("\tGeneration took \(currentTimestamp() - generationStart)")
        Log.info("Finished.")
    }

    private func link(_ output: Path, to linkTo: Output.LinkTo) {
        guard let target = linkTo.project.target(named: linkTo.target) else {
            Log.warning("Unable to find target \(linkTo.target)")
            return
        }

        guard let rootGroup = linkTo.project.rootGroup else {
            Log.warning("Unable to find rootGroup for the project")
            return
        }

        let sourceRoot = linkTo.projectPath.parent()
        var fileGroup: PBXGroup = rootGroup
        if let group = linkTo.group {
            do {
                if let addedGroup = linkTo.project.addGroup(named: group, to: rootGroup, options: []),
                   let groupPath = linkTo.project.fullPath(fileElement: addedGroup, sourceRoot: sourceRoot) {
                    fileGroup = addedGroup
                    try groupPath.mkpath()
                }
            } catch {
                Log.warning("Failed to create a folder for group '\(fileGroup.name ?? "")'. \(error)")
            }
        }

        do {
            try linkTo.project.addSourceFile(at: output, toGroup: fileGroup, target: target, sourceRoot: sourceRoot)
        } catch {
            Log.warning("Failed to link file at \(output) to \(linkTo.projectPath). \(error)")
        }
    }

    private func output(result: String, to outputPath: Path) throws {
        var result = result
        if !result.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if outputPath.extension == "swift" {
                result = Sourcery.generationHeader + result
            }
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

    private func generate(_ template: Template, forParsingResult parsingResult: ParsingResult, outputPath: Path) throws -> String {
        guard watcherEnabled else {
            let generationStart = currentTimestamp()
            let result = try Generator.generate(parsingResult.parserResult, types: parsingResult.types, functions: parsingResult.functions, template: template, arguments: self.arguments)
            Log.benchmark("\tGenerating \(template.sourcePath.lastComponent) took \(currentTimestamp() - generationStart)")

            return try processRanges(in: parsingResult, result: result, outputPath: outputPath)
        }

        var result: String = ""
        SwiftTryCatch.try({
            do {
                result = try Generator.generate(parsingResult.parserResult, types: parsingResult.types, functions: parsingResult.functions, template: template, arguments: self.arguments)
            } catch {
                Log.error(error)
            }
        }, catch: { error in
            result = error?.description ?? ""
        }, finallyBlock: {})

        return try processRanges(in: parsingResult, result: result, outputPath: outputPath)
    }

    private func processRanges(in parsingResult: ParsingResult, result: String, outputPath: Path) throws -> String {
        let start = currentTimestamp()
        defer {
            Log.benchmark("\t\tProcessing Ranges took \(currentTimestamp() - start)")
        }
        var result = result
        result = processFileRanges(for: parsingResult, in: result, outputPath: outputPath)
        result = try processInlineRanges(for: parsingResult, in: result)
        return TemplateAnnotationsParser.removingEmptyAnnotations(from: result)
    }

    private func processInlineRanges(`for` parsingResult: ParsingResult, in contents: String) throws -> String {
        var (annotatedRanges, rangesToReplace) = TemplateAnnotationsParser.annotationRanges("inline", contents: contents)

        typealias MappedInlineAnnotations = (
            range: NSRange,
            filePath: Path,
            rangeInFile: NSRange,
            toInsert: String,
            indentation: String
        )

        let contentsView = StringView(contents)

        try annotatedRanges
            .map { (key: $0, range: $1[0].range) }
            .compactMap { (key, range) -> MappedInlineAnnotations? in
                let generatedBody = contents.bridge().substring(with: range)

                if let (filePath, inlineRanges, inlineIndentations) = parsingResult.inlineRanges.first(where: { $0.ranges[key] != nil }) {
                    // swiftlint:disable:next force_unwrapping
                    return MappedInlineAnnotations(range, Path(filePath), inlineRanges[key]!, generatedBody, inlineIndentations[key] ?? "")
                }

                guard key.hasPrefix("auto:") else {
                    rangesToReplace.remove(range)
                    return nil
                }
                let autoTypeName = key.trimmingPrefix("auto:").components(separatedBy: ".").dropLast().joined(separator: ".")
                let toInsert = "\n// sourcery:inline:\(key)\n\(generatedBody)// sourcery:end\n"

                guard let definition = parsingResult.types.types.first(where: { $0.name == autoTypeName }),
                    let path = definition.path.map({ Path($0) }),
                    let contents = try? path.read(.utf8),
                    let bodyRange = bodyRange(for: definition, contentsView: contentsView) else {
                        rangesToReplace.remove(range)
                        return nil
                }
                let bodyEndRange = NSRange(location: NSMaxRange(bodyRange), length: 0)
                let bodyEndLineRange = contents.bridge().lineRange(for: bodyEndRange)
                let rangeInFile = NSRange(location: max(bodyRange.location, bodyEndLineRange.location), length: 0)
                return MappedInlineAnnotations(range, path, rangeInFile, toInsert, "")
            }
            .sorted { lhs, rhs in
                return lhs.rangeInFile.location > rhs.rangeInFile.location
            }.forEach { (arg) in
                let (_, path, rangeInFile, toInsert, indentation) = arg
                let content = try path.read(.utf8)
                let updated = content.bridge().replacingCharacters(in: rangeInFile, with: indent(toInsert: toInsert, indentation: indentation))
                try writeIfChanged(updated, to: path)
        }

        var bridged = contents.bridge()
        rangesToReplace
            .sorted(by: { $0.location > $1.location })
            .forEach {
                bridged = bridged.replacingCharacters(in: $0, with: "") as NSString
        }
        return bridged as String
    }

    private func bodyRange(for type: Type, contentsView: StringView) -> NSRange? {
        guard let bytesRange = type.bodyBytesRange else { return nil }
        return contentsView.byteRangeToNSRange(ByteRange(location: ByteCount(bytesRange.offset), length: ByteCount(bytesRange.length)))
    }

    private func processFileRanges(`for` parsingResult: ParsingResult, in contents: String, outputPath: Path) -> String {
        let files = TemplateAnnotationsParser.parseAnnotations("file", contents: contents, aggregate: true)

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
