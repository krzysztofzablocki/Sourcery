//
//  SwiftTemplate.swift
//  Sourcery
//
//  Created by Krunoslav Zaher on 12/30/16.
//  Copyright © 2016 Pixle. All rights reserved.
//

import Foundation
import PathKit
import SwiftTryCatch

fileprivate enum Delimiters {
    static let open = "<%"
    static let close = "%>"
}

fileprivate struct ProcessResult {
    let output: String
    let error: String
}

class SwiftTemplateParser {

    enum Command {
        case output(String)
        case controlFlow(String)
        case outputEncoded(String)
    }

    static func parse(sourcePath: Path) throws -> String {
        let templateContent = try "<%%>" + sourcePath.read()

        let components = templateContent.components(separatedBy: Delimiters.open)

        var sourceFile = [String]()
        var commands = [Command]()

        let currentLineNumber = {
            return sourceFile.joined(separator: "").numberOfLineSeparators
        }

        for component in components.suffix(from: 1) {
            guard let endIndex = component.range(of: Delimiters.close) else {
                throw "\(path):\(currentLineNumber()) Error while parsing template. Unmatched <%"
            }

            var code = component.substring(to: endIndex.lowerBound)
            let shouldTrimTrailingNewLines = code.trimSuffix("-")
            let shouldTrimLeadingWhitespaces = code.trimPrefix("_")
            let shouldTrimTrailingWhitespaces = code.trimSuffix("_")

            // string after closing tag
            var encodedPart = component.substring(from: endIndex.upperBound)
            if shouldTrimTrailingNewLines {
                // we trim only new line caused by script tag, not all of leading new lines in string after tag
                encodedPart = encodedPart.replacingOccurrences(of: "^\\n{1}", with: "", options: .regularExpression, range: nil)
            }
            if shouldTrimTrailingWhitespaces {
                // trim all leading whitespaces in string after tag
                encodedPart = encodedPart.replacingOccurrences(of: "^[\\h\\t]*", with: "", options: .regularExpression, range: nil)
            }
            if shouldTrimLeadingWhitespaces {
                if case .outputEncoded(let code)? = commands.last {
                    // trim all trailing white spaces in previously enqued code string
                    let trimmed = code.replacingOccurrences(of: "[\\h\\t]*$", with: "", options: .regularExpression, range: nil)
                    _ = commands.popLast()
                    commands.append(.outputEncoded(trimmed))
                }
            }

            if code.trimPrefix("=") {
                commands.append(.output(code))
            } else {
                if !code.hasPrefix("#") && !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    commands.append(.controlFlow(code))
                }
            }

            if !encodedPart.isEmpty {
                commands.append(.outputEncoded(encodedPart))
            }
        }

        for command in commands {
            switch command {
            case let .output(code):
                sourceFile.append("\n  print(\"\\(" + code + ")\", terminator: \"\");")
            case let .controlFlow(code):
                sourceFile.append("\n \(code)")
            case let .outputEncoded(code):
                if !code.isEmpty {
                    sourceFile.append(("\n  print(\"") + code.stringEncoded + "\", terminator: \"\");")
                }
            }
        }
        let contents = sourceFile.joined(separator: "")
        let code = "extension TemplateContext {\n\n override func generate() {" + contents + "\n }\n\n}\nrun();"
        return code
    }

    static func loadOrBuild(template: SwiftTemplate, buildDir: Path, cachePath: Path?) throws -> Path {
        var binaryFile: Path!

        let cachedTemplateFile = cachePath.map({ $0 + "\(template.sourcePath.string.hash).srf" })
        let cachedBinaryFile = cachePath.map({ $0 + Path("bin") })

        if let cachedTemplateFile = cachedTemplateFile, cachedTemplateFile.exists,
            let cachedBinaryFile = cachedBinaryFile, cachedBinaryFile.exists,
            let cachedTemplate = SwiftTemplate.load(path: cachedTemplateFile),
            cachedTemplate.contentSha == template.contentSha {

            return cachedBinaryFile
        }

        binaryFile = try compile(template: template, buildDir: buildDir)

        if let cachedTemplateFile = cachedTemplateFile,
            let cachedBinaryFile = cachedBinaryFile {
            do {
                let data = NSKeyedArchiver.archivedData(withRootObject: template)
                try cachedTemplateFile.write(data)
                try binaryFile.copy(cachedBinaryFile)
            } catch {
                try? cachePath?.delete()
            }
        }

        return binaryFile
    }

    static func compile(template: SwiftTemplate, buildDir: Path) throws -> Path {
        let runtimeFiles = try SwiftTemplate.swiftTemplatesRuntime.children().map { file in
            return file.description
        }

        let mainFile = buildDir + Path("main.swift")
        let binaryFile = buildDir + Path("bin")

        try mainFile.write(template.code)

        let arguments = [mainFile.description] +
            runtimeFiles + [
                "-suppress-warnings",
                "-Onone",
                "-module-name", "Sourcery",
                "-o", binaryFile.description
        ]

        let compilationResult = try Process.runCommand(path: "/usr/bin/swiftc",
                                                       arguments: arguments,
                                                       environment: [:])

        if !compilationResult.error.isEmpty {
            #if DEBUG
                let command = "/usr/bin/swiftc " + arguments.map { "\"\($0)\"" }.joined(separator: " ")
                print(command)
            #endif
            throw compilationResult.error
        }

        return binaryFile
    }

}

class SwiftTemplate: NSObject, NSCoding, Template {

    var sourcePath: Path
    let code: String
    let contentSha: String?

    private lazy var buildDir: Path = Path.cleanTemporaryDir(name: "build")

    private(set) var binaryPath: Path!

    init(code: String, sourcePath: Path) {
        self.code = code
        self.sourcePath = sourcePath
        self.contentSha = code.sha256()
    }

    init(path: Path, cachePath: Path?) throws {
        sourcePath = path
        code = try SwiftTemplateParser.parse(sourcePath: path)
        contentSha = code.sha256()
        super.init()

        binaryPath = try SwiftTemplateParser.loadOrBuild(template: self, buildDir: buildDir, cachePath: cachePath)
    }

    required init?(coder aDecoder: NSCoder) {
        guard
            let code = aDecoder.decodeObject(forKey: "code") as? String,
            let sourcePath = aDecoder.decodeObject(forKey: "sourcePath") as? String else
        {
            return nil
        }

        self.code = code
        self.sourcePath = Path(sourcePath)
        self.contentSha = aDecoder.decodeObject(forKey: "contentSha") as? String
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(code, forKey: "code")
        aCoder.encode(sourcePath.string, forKey: "sourcePath")
        aCoder.encode(contentSha, forKey: "contentSha")
    }

    /// Loads template from provided path
    static func load(path: Path) -> SwiftTemplate? {
        var template: SwiftTemplate?
        SwiftTryCatch.try({
            template = NSKeyedUnarchiver.unarchiveObject(withFile: path.string) as? SwiftTemplate
        }, catch: { _ in }, finallyBlock: {})
        return template
    }

    func render(types: Types, arguments: [String: NSObject]) throws -> String {
        let context = TemplateContext(types: types, arguments: arguments)

        let serializedContextPath = buildDir + Path("context.bin")
        let data = NSKeyedArchiver.archivedData(withRootObject: context)
        try serializedContextPath.write(data)
        
        #if DEBUG
            // this is a sanity check, deserialized object should be equal to initial object
            let diff = context.diffAgainst(NSKeyedUnarchiver.unarchiveObject(with: data))
            if !diff.isEmpty {
                print(diff.description)
            }
            assert(diff.isEmpty)
        #endif

        let result = try Process.runCommand(path: binaryPath.description,
                                            arguments: [serializedContextPath.description])

        if !result.error.isEmpty {
            throw "\(sourcePath): \(result.error)"
        }

        return result.output
    }

}

fileprivate extension SwiftTemplate {
    static var resourcesPath: Path {
        return Bundle(for: Sourcery.self).resourcePath.flatMap { Path($0) }!
    }

    static var swiftTemplatesRuntime: Path {
        return resourcesPath + Path("SwiftTemplateRuntime")
    }
}

// swiftlint:disable:next force_try
fileprivate let newlines = try! NSRegularExpression(pattern: "\\n\\r|\\r\\n|\\r|\\n", options: [])

private extension String {
    var numberOfLineSeparators: Int {
        return newlines.matches(in: self, options: [], range: NSRange(location: 0, length: self.characters.count)).count
    }

    var stringEncoded: String {
        return self.unicodeScalars.map { x -> String in
            return x.escaped(asASCII: true)
        }.joined(separator: "")
    }
}

private extension Process {
    static func runCommand(path: String, arguments: [String], environment: [String: String] = [:]) throws -> ProcessResult {
        let task = Process()
        task.launchPath = path
        task.arguments = arguments
        task.environment = environment

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        let outHandle = outputPipe.fileHandleForReading
        let errorHandle = errorPipe.fileHandleForReading

        task.launch()

        let outputData = outHandle.readDataToEndOfFile()
        let errorData = errorHandle.readDataToEndOfFile()
        outHandle.closeFile()
        errorHandle.closeFile()

        task.waitUntilExit()

        let output = String(data: outputData, encoding: .utf8) ?? ""
        let error = String(data: errorData, encoding: .utf8) ?? ""

        if task.terminationReason != .exit {
            throw NSError(domain: NSOSStatusErrorDomain, code: -1, userInfo: [
                "terminationReason": task.terminationReason,
                "error": error
                ])
        }

        return ProcessResult(output: output, error: error)
    }
}
