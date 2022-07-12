//
//  SwiftTemplate.swift
//  Sourcery
//
//  Created by Krunoslav Zaher on 12/30/16.
//  Copyright © 2016 Pixle. All rights reserved.
//

import Foundation
import PathKit
import SourceryRuntime
import SourceryUtils

private enum Delimiters {
    static let open = "<%"
    static let close = "%>"
}

private struct ProcessResult {
    let output: String
    let error: String
    let exitCode: Int32
}

open class SwiftTemplate {

    public let sourcePath: Path
    let cachePath: Path?
    let code: String
    let version: String?
    let includedFiles: [Path]

    private lazy var buildDir: Path = {
        let pathComponent = "SwiftTemplate" + (version.map { "/\($0)" } ?? "")
        guard let tempDirURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(pathComponent) else { fatalError("Unable to get temporary path") }
        return Path(tempDirURL.path)
    }()

    public init(path: Path, cachePath: Path? = nil, version: String? = nil) throws {
        self.sourcePath = path
        self.cachePath = cachePath
        self.version = version
        (self.code, self.includedFiles) = try SwiftTemplate.parse(sourcePath: path)
    }

    private enum Command {
        case includeFile(Path)
        case output(String)
        case controlFlow(String)
        case outputEncoded(String)
    }

    static func parse(sourcePath: Path) throws -> (String, [Path]) {

        let commands = try SwiftTemplate.parseCommands(in: sourcePath)

        var includedFiles: [Path] = []
        var outputFile = [String]()
        for command in commands {
            switch command {
            case let .includeFile(path):
                includedFiles.append(path)
            case let .output(code):
                outputFile.append("print(\"\\(" + code + ")\", terminator: \"\");")
            case let .controlFlow(code):
                outputFile.append("\(code)")
            case let .outputEncoded(code):
                if !code.isEmpty {
                    outputFile.append(("print(\"") + code.stringEncoded + "\", terminator: \"\");")
                }
            }
        }

        let contents = outputFile.joined(separator: "\n")
        let code = """
        import Foundation
        import SourceryRuntime

        let context = ProcessInfo().context!
        let types = context.types
        let functions = context.functions
        let type = context.types.typesByName
        let argument = context.argument

        \(contents)
        """

        return (code, includedFiles)
    }

    private static func parseCommands(in sourcePath: Path, includeStack: [Path] = []) throws -> [Command] {
        let templateContent = try "<%%>" + sourcePath.read()

        let components = templateContent.components(separatedBy: Delimiters.open)

        var processedComponents = [String]()
        var commands = [Command]()

        let currentLineNumber = {
            // the following +1 is to transform a line count (starting from 0) to a line number (starting from 1)
            return processedComponents.joined(separator: "").numberOfLineSeparators + 1
        }

        for component in components.suffix(from: 1) {
            guard let endIndex = component.range(of: Delimiters.close) else {
                throw "\(sourcePath):\(currentLineNumber()) Error while parsing template. Unmatched <%"
            }

            var code = String(component[..<endIndex.lowerBound])
            let shouldTrimTrailingNewLines = code.trimSuffix("-")
            let shouldTrimLeadingWhitespaces = code.trimPrefix("_")
            let shouldTrimTrailingWhitespaces = code.trimSuffix("_")

            // string after closing tag
            var encodedPart = String(component[endIndex.upperBound...])
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

            func parseInclude(command: String, defaultExtension: String) -> Path? {
                let regex = try? NSRegularExpression(pattern: "\(command)\\(\"([^\"]*)\"\\)", options: [])
                let match = regex?.firstMatch(in: code, options: [], range: code.bridge().entireRange)
                guard let includedFile = match.map({ code.bridge().substring(with: $0.range(at: 1)) }) else {
                    return nil
                }
                let includePath = Path(components: [sourcePath.parent().string, includedFile])
                // The template extension may be omitted, so try to read again by adding it if a template was not found
                if !includePath.exists, includePath.extension != "\(defaultExtension)" {
                    return Path(includePath.string + ".\(defaultExtension)")
                } else {
                    return includePath
                }
            }

            if code.trimPrefix("-") {
                if let includePath = parseInclude(command: "includeFile", defaultExtension: "swift") {
                    commands.append(.includeFile(includePath))
                } else if let includePath = parseInclude(command: "include", defaultExtension: "swifttemplate") {
                    // Check for include cycles to prevent stack overflow and show a more user friendly error
                    if includeStack.contains(includePath) {
                        throw "\(sourcePath):\(currentLineNumber()) Error: Include cycle detected for \(includePath). Check your include statements so that templates do not include each other."
                    }
                    let includedCommands = try SwiftTemplate.parseCommands(in: includePath, includeStack: includeStack + [includePath])
                    commands.append(contentsOf: includedCommands)
                } else {
                    throw "\(sourcePath):\(currentLineNumber()) Error while parsing template. Invalid include tag format '\(code)'"
                }
            } else if code.trimPrefix("=") {
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

        return commands
    }

    public func render(_ context: Any) throws -> String {
        let binaryPath: Path

        if let cachePath = cachePath,
            let hash = cacheKey,
            let hashPath = hash.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) {

            binaryPath = cachePath + hashPath
            if !binaryPath.exists {
                try? cachePath.delete() // clear old cache
                try cachePath.mkdir()
                try build().move(binaryPath)
            }
        } else {
            try binaryPath = build()
        }

        let serializedContextPath = buildDir + "context.bin"
        let data = NSKeyedArchiver.archivedData(withRootObject: context)
        if !buildDir.exists {
            try buildDir.mkpath()
        }
        try serializedContextPath.write(data)

        let result = try Process.runCommand(path: binaryPath.description,
                                            arguments: [serializedContextPath.description])
        if !result.error.isEmpty {
            throw "\(sourcePath): \(result.error)"
        }
        return result.output
    }

    func build() throws -> Path {
        let sourcesDir = buildDir + Path("Sources")
        let templateFilesDir = sourcesDir + Path("SwiftTemplate")
        let mainFile = templateFilesDir + Path("main.swift")
        let manifestFile = buildDir + Path("Package.swift")

        try sourcesDir.mkpath()
        try? templateFilesDir.delete()
        try templateFilesDir.mkpath()

        try copyRuntimePackage(to: sourcesDir)
        try manifestFile.write(manifestCode)
        try mainFile.write(code)

        let binaryFile = buildDir + Path(".build/release/SwiftTemplate")

        try includedFiles.forEach { includedFile in
            try includedFile.copy(templateFilesDir + Path(includedFile.lastComponent))
        }

        let arguments = [
            "xcrun",
            "--sdk", "macosx",
            "swift",
            "build",
            "-c", "release",
            "-Xswiftc", "-suppress-warnings",
            "--disable-sandbox"
        ]
        let compilationResult = try Process.runCommand(path: "/usr/bin/env",
                                                       arguments: arguments,
                                                       currentDirectoryPath: buildDir)

        if compilationResult.exitCode != EXIT_SUCCESS {
            throw [compilationResult.output, compilationResult.error]
                .filter { !$0.isEmpty }
                .joined(separator: "\n")
        }

        return binaryFile
    }

    private var manifestCode: String {
        return """
        // swift-tools-version:4.0
        // The swift-tools-version declares the minimum version of Swift required to build this package.

        import PackageDescription

        let package = Package(
            name: "SwiftTemplate",
            products: [
                .executable(name: "SwiftTemplate", targets: ["SwiftTemplate"])
            ],
            targets: [
                .target(name: "SourceryRuntime"),
                .target(
                    name: "SwiftTemplate",
                    dependencies: ["SourceryRuntime"]),
            ]
        )
        """
    }

    var cacheKey: String? {
        var contents = code

        // For every included file, make sure that the path and modification date are included in the key
        let files = includedFiles.map({ $0.absolute() }).sorted(by: { $0.string < $1.string })
        for file in files {
            let modificationDate = file.modifiedDate?.timeIntervalSinceReferenceDate ?? 0
            contents += "\n// \(file.string)-\(modificationDate)"
        }

        return contents.sha256()
    }

    private func copyRuntimePackage(to path: Path) throws {
        try FolderSynchronizer().sync(files: sourceryRuntimeFiles, to: path + Path("SourceryRuntime"))
    }

}

fileprivate extension SwiftTemplate {

    static var frameworksPath: Path {
        return Path(Bundle(for: SwiftTemplate.self).bundlePath +  "/Versions/Current/Frameworks")
    }

}

// swiftlint:disable:next force_try
private let newlines = try! NSRegularExpression(pattern: "\\n\\r|\\r\\n|\\r|\\n", options: [])

private extension String {
    var numberOfLineSeparators: Int {
        return newlines.matches(in: self, options: [], range: NSRange(location: 0, length: self.count)).count
    }

    var stringEncoded: String {
        return self.unicodeScalars.map { x -> String in
            return x.escaped(asASCII: true)
            }.joined(separator: "")
    }
}

private extension Process {
    static func runCommand(path: String, arguments: [String], currentDirectoryPath: Path? = nil) throws -> ProcessResult {
        let task = Process()
        var environment = ProcessInfo.processInfo.environment

        // https://stackoverflow.com/questions/67595371/swift-package-calling-usr-bin-swift-errors-with-failed-to-open-macho-file-to
        if ProcessInfo.processInfo.environment.keys.contains("OS_ACTIVITY_DT_MODE") {
            environment = ProcessInfo.processInfo.environment
            environment["OS_ACTIVITY_DT_MODE"] = nil
        }

        task.launchPath = path
        task.environment = environment
        task.arguments = arguments
        if let currentDirectoryPath = currentDirectoryPath {
            if #available(OSX 10.13, *) {
                task.currentDirectoryURL = currentDirectoryPath.url
            } else {
                task.currentDirectoryPath = currentDirectoryPath.description
            }
        }

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        let outHandle = outputPipe.fileHandleForReading
        let errorHandle = errorPipe.fileHandleForReading

        Log.verbose(path + " " + arguments.map { "\"\($0)\"" }.joined(separator: " "))
        task.launch()

        let outputData = outHandle.readDataToEndOfFile()
        let errorData = errorHandle.readDataToEndOfFile()
        outHandle.closeFile()
        errorHandle.closeFile()

        task.waitUntilExit()

        let output = String(data: outputData, encoding: .utf8) ?? ""
        let error = String(data: errorData, encoding: .utf8) ?? ""

        return ProcessResult(output: output, error: error, exitCode: task.terminationStatus)
    }
}

extension String {
    func bridge() -> NSString {
        #if os(Linux)
            return NSString(string: self)
        #else
            return self as NSString
        #endif
    }
}

struct FolderSynchronizer {
    struct File {
        let name: String
        let content: String
    }

    func sync(files: [File], to dir: Path) throws {
        if dir.exists {
            let synchronizedPaths = files.map { dir + Path($0.name) }
            try dir.children().forEach({ path in
                if synchronizedPaths.contains(path) {
                    return
                }
                try path.delete()
            })
        } else {
            try dir.mkpath()
        }
        try files.forEach { file in
            let filePath = dir + Path(file.name)
            try filePath.write(file.content)
        }
    }
}
