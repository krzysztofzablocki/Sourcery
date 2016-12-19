//
// Created by Krzysztof Zablocki on 14/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import Stencil
import PathKit
import KZFileWatchers
import SwiftTryCatch

internal class SourceryTemplate: Template {
    private(set) var sourcePath: Path = ""
    convenience init(path: Path) throws {
        self.init(templateString: try path.read(), environment: SourceryTemplate.sourceryEnvironment())
        sourcePath = path
    }

    convenience init(templateString: String) {
        self.init(templateString: templateString, environment: SourceryTemplate.sourceryEnvironment())
    }

    private static func sourceryEnvironment() -> Stencil.Environment {
        let ext = Stencil.Extension()
        ext.registerFilter("upperFirst") { (any: Any?) in
            guard let s = any as? String else {
                return any
            }
            let first = String(s.characters.prefix(1)).capitalized
            let other = String(s.characters.dropFirst())
            return first + other
        }
        return Stencil.Environment(extensions: [ext])
    }
}

/// If you specify templatePath as a folder, it will create a Generated[TemplateName].swift file
/// If you specify templatePath as specific file, it will put all generated results into that single file
public class Sourcery {
    public static let version: String = inUnitTests ? "Major.Minor.Patch" : "0.4.3"
    public static let generationMarker: String = "// Generated using Sourcery"

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
    public func processFiles(_ files: Path, usingTemplates templatePath: FilePath, output: Path, watcherEnabled: Bool = false) throws -> FileWatcherProtocol? {
        self.watcherEnabled = watcherEnabled

        guard watcherEnabled else {
            try processFiles(files, usingTemplates: templatePath.path, output: output)
            return nil
        }

        let types = try parseTypes(from: files)

        print("Starting watcher")
        let watcher = FileWatcher.Local(path: templatePath.path.string)
        try watcher.start { result in
            switch result {
            case .noChanges:
                print("no changes")
            case .updated:
                do {
                    _ = try self.generate(templatePath: templatePath.path, output: output, types: types)
                } catch {
                    print(error)
                }
            }
        }

        return watcher
    }

    /// Processes source files and generates corresponding code.
    ///
    /// - Parameters:
    ///   - files: Path of files to process, can be directory or specific file.
    ///   - templatePath: Path to template's to use for code generation, can be directory or specific file.
    ///   - output: Path to output source code to.
    /// - Throws: Potential errors.
    public func processFiles(_ files: Path, usingTemplates templatePath: Path, output: Path) throws {
        let types = try parseTypes(from: files)

        try generate(templatePath: templatePath, output: output, types: types)
        return
    }

    private func parseTypes(from: Path) throws -> [Type] {
        print("Scanning sources...")
        let parser = Parser(verbose: verbose)

        var parserResult: ParserResult = ([], [:])

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

        print("Found \(types.count) types")
        return types
    }

    private func generate(templatePath: Path, output: Path, types: [Type]) throws {
        print("Loading templates...")
        let allTemplates = try templates(from: templatePath)
        print("Loaded \(allTemplates.count) templates")

        print("Generating code...")

        let header = "\(Sourcery.generationMarker) \(Sourcery.version) — https://github.com/krzysztofzablocki/Sourcery\n"
            + "// DO NOT EDIT\n\n"

        guard output.isDirectory else {
            let result = try allTemplates.reduce(header) { result, template in
                return result + "\n" + (try generate(template, forTypes: types))
            }

            try output.write(result, encoding: .utf8)
            return
        }

        try allTemplates.forEach { template in
            let result = header + (try generate(template, forTypes: types))
            let outputPath = output + generatedPath(for: template.sourcePath)
            try outputPath.write(result, encoding: .utf8)
        }
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
