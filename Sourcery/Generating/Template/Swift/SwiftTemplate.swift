//
//  SwiftTemplate.swift
//  Sourcery
//
//  Created by Krunoslav Zaher on 12/30/16.
//  Copyright © 2016 Pixle. All rights reserved.
//

import Foundation
import PathKit

fileprivate enum SwiftTemplateParsingError: Error {
    case unmatchedOpening(path: Path, line: Int)
    case compilationError(path: Path, error: String)
}

fileprivate enum Delimiters {
    static let open = "<%"
    static let close = "%>"
}

fileprivate struct ProcessResult {
    let output: String
    let error: String
}

class SwiftTemplate: Template {
    let sourcePath: Path

    init(path: Path) throws {
        self.sourcePath = path
    }

    fileprivate static func generateSwiftCode(templateContent _templateContent: String, path: Path) throws -> String {
        let templateContent = "<%%>" + _templateContent

        let components = templateContent.components(separatedBy: Delimiters.open)

        var sourceFile = [String]()

        let line = {
            return sourceFile.joined(separator: "").numberOfLineSeparators
        }

        for component in components.suffix(from: 1) {
            guard let endIndex = component.range(of: Delimiters.close) else {
                throw SwiftTemplateParsingError.unmatchedOpening(path: path, line: line())
            }

            let code = component.substring(to: endIndex.lowerBound)
            if code.hasPrefix("=") {
                let codeStartIndex = code.index(code.startIndex, offsetBy: 1)
                let realCode = code.substring(from: codeStartIndex)
                sourceFile.append("\n print(\"\\(" + realCode + ")\", terminator: \"\");")
            } else {
                sourceFile.append(code)
            }

            let encodedPart = component.substring(from: endIndex.upperBound)
            sourceFile.append(("\n print(\"") + encodedPart.stringEncoded + "\", terminator: \"\");")
            for _ in 0 ..< encodedPart.numberOfLineSeparators {
                sourceFile.append("\n")
            }
        }

        return sourceFile.joined(separator: "")
    }

    func render(types: [Type], arguments: [String: NSObject]) throws -> String {
        let context = GenerationContext(types: types, arguments: arguments)
        let swiftCode = try SwiftTemplate.generateSwiftCode(templateContent: try sourcePath.read(), path: sourcePath)

        let compilationDir = Path.cleanTemporaryDir(name: "build")

        let runtimeFiles = try SwiftTemplate.swiftTemplatesRuntime.children().map { file in
            return file.description
        }

        let mainFile = compilationDir + Path("main.swift")
        let binaryFile = compilationDir + Path("bin")

        let runableCode = "extension GenerationContext { override func generate() { " + swiftCode + " } }; run();"

        try mainFile.write(runableCode)

        let serializedContextPath = compilationDir + Path("context.bin")

        let serializedContext = NSKeyedArchiver.archivedData(withRootObject: context)
        try serializedContextPath.write(serializedContext)

        #if DEBUG
            // this is a sanity check, deserialized object should be equal to initial object
            let diff = context.diffAgainst(NSKeyedUnarchiver.unarchiveObject(with: serializedContext))
            if !diff.isEmpty {
                print(diff.description)
            }
            assert(diff.isEmpty)
        #endif

        let arguments = [mainFile.description] + runtimeFiles + ["-Onone", "-module-name", "Sourcery"] + ["-o"] + [binaryFile.description]

        let compilationResult = try Process.runCommand(path: "/usr/bin/swiftc",
                                            arguments: arguments,
                                            environment: [:])

        if !compilationResult.error.isEmpty {
            #if DEBUG
                let command = "/usr/bin/swiftc " + arguments.map { "\"\($0)\"" }.joined(separator: " ")
                print(command)
            #endif
            throw SwiftTemplateParsingError.compilationError(path: binaryFile, error: compilationResult.error)
        }

        let result = try Process.runCommand(path: binaryFile.description,
                                            arguments: [serializedContextPath.description])

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

extension SwiftTemplateParsingError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .unmatchedOpening(path, line):
            return "\(path):\(line) Error while parsing template. Unmatched <%"
        case let .compilationError(_, error):
            return error
        }
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
