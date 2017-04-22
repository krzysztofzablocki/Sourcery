//
//  SwiftTemplate.swift
//  Sourcery
//
//  Created by Krunoslav Zaher on 12/30/16.
//  Copyright © 2016 Pixle. All rights reserved.
//

import Foundation
import PathKit

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

    enum Command {
        case output(String)
        case controlFlow(String)
        case outputEncoded(String)
    }

    fileprivate static func generateSwiftCode(templateContent _templateContent: String, path: Path) throws -> String {
        let templateContent = "<%%>" + _templateContent

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
        return sourceFile.joined(separator: "")
    }

    func render(types: Types, arguments: [String: NSObject]) throws -> String {
        let context = TemplateContext(types: types, arguments: arguments)
        let swiftCode = try SwiftTemplate.generateSwiftCode(templateContent: try sourcePath.read(), path: sourcePath)

        let compilationDir = Path.cleanTemporaryDir(name: "build")

        let runtimeFiles = try SwiftTemplate.swiftTemplatesRuntime.children().map { file in
            return file.description
        }

        let mainFile = compilationDir + Path("main.swift")
        let binaryFile = compilationDir + Path("bin")

        let runableCode = "extension TemplateContext {\n\n override func generate() {" + swiftCode + "\n }\n\n}\nrun();"

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

        let result = try Process.runCommand(path: binaryFile.description,
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
