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
import SourceryRuntime

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
    let cachePath: Path?
    let code: String

    private lazy var buildDir: Path = Path.cleanTemporaryDir(name: "build")

    init(path: Path, cachePath: Path? = nil) throws {
        self.sourcePath = path
        self.cachePath = cachePath
        self.code = try SwiftTemplate.parse(sourcePath: path)
    }

    static func parse(sourcePath: Path) throws -> String {

        enum Command {
            case output(String)
            case controlFlow(String)
            case outputEncoded(String)
        }

        let templateContent = try "<%%>" + sourcePath.read()

        let components = templateContent.components(separatedBy: Delimiters.open)

        var processedComponents = [String]()
        var commands = [Command]()

        let currentLineNumber = {
            return processedComponents.joined(separator: "").numberOfLineSeparators + 1
        }

        for component in components.suffix(from: 1) {
            guard let endIndex = component.range(of: Delimiters.close) else {
                throw "\(sourcePath):\(currentLineNumber()) Error while parsing template. Unmatched <%"
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
            processedComponents.append(component)
        }

        var outputFile = [String]()
        for command in commands {
            switch command {
            case let .output(code):
                outputFile.append("\n  print(\"\\(" + code + ")\", terminator: \"\");")
            case let .controlFlow(code):
                outputFile.append("\n \(code)")
            case let .outputEncoded(code):
                if !code.isEmpty {
                    outputFile.append(("\n  print(\"") + code.stringEncoded + "\", terminator: \"\");")
                }
            }
        }
        let contents = outputFile.joined(separator: "")
        let code = "import Foundation\n" +
            "import SourceryRuntime\n" +
            "\n" +
            "extension TemplateContext {\nfunc generate() {" + contents + "\n}\n\n}\n\n" +
            "ProcessInfo().context!.generate()"

        return code
    }

    func render(types: Types, arguments: [String: NSObject]) throws -> String {
        let binaryPath: Path

        if let cachePath = cachePath,
            let hash = code.sha256(),
            let hashPath = hash.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) {

            binaryPath = cachePath + hashPath
            if !binaryPath.exists {
                try? cachePath.delete() // clear old cache
                try cachePath.mkdir()
                try build().move(binaryPath)
                try copyFramework(to: cachePath.parent())
            }
        } else {
            try binaryPath = build()
        }

        let context = TemplateContext(types: types, arguments: arguments)

        let serializedContextPath = buildDir + "context.bin"
        let data = NSKeyedArchiver.archivedData(withRootObject: context)
        try serializedContextPath.write(data)

        let result = try Process.runCommand(path: binaryPath.description,
                                            arguments: [serializedContextPath.description])

        if !result.error.isEmpty {
            throw "\(sourcePath): \(result.error)"
        }

        return result.output
    }

    func build() throws -> Path {
        let mainFile = buildDir + Path("main.swift")
        let binaryFile = buildDir + Path("bin")

        try copyFramework(to: buildDir.parent())
        try mainFile.write(code)

        let arguments = [mainFile.description] +
            [
                "-suppress-warnings",
                "-Onone",
                "-module-name", "main",
                "-target", "x86_64-apple-macosx10.10",
                "-F", buildDir.parent().description,
                "-o", binaryFile.description,
                "-Xlinker", "-headerpad_max_install_names"
        ]

        let compilationResult = try Process.runCommand(path: "/usr/bin/swiftc",
                                                       arguments: arguments,
                                                       environment: [:])

        if !compilationResult.error.isEmpty {
            throw compilationResult.error
        }

        let linkingResult = try Process.runCommand(path: "/usr/bin/install_name_tool",
                                                   arguments: [
                                                    "-add_rpath",
                                                    "@executable_path/../",
                                                    binaryFile.description])
        if !linkingResult.error.isEmpty {
            throw linkingResult.error
        }

        try? mainFile.delete()

        return binaryFile
    }

    private func copyFramework(to path: Path) throws {
        let sourceryFramework = SwiftTemplate.frameworksPath + "SourceryRuntime.framework"

        let copyFramework = try Process.runCommand(path: "/usr/bin/rsync", arguments: [
            "-av", sourceryFramework.description, path.description
            ])

        if !copyFramework.error.isEmpty {
            throw copyFramework.error
        }
    }

}

fileprivate extension SwiftTemplate {

    static var frameworksPath: Path {
        return Bundle(for: Sourcery.self).privateFrameworksPath.flatMap { Path($0) }!
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

        Log.info(path + " " + arguments.map { "\"\($0)\"" }.joined(separator: " "))
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
