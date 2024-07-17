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
    let buildPath: Path?
    let cachePath: Path?
    let mainFileCodeRaw: String
    let version: String?
    let includedFiles: [Path]

    private enum RenderError: Error {
        case binaryMissing
    }

    private lazy var buildDir: Path = {
        var pathComponent = "SwiftTemplate"
        pathComponent.append("/\(UUID().uuidString)")
        pathComponent.append((version.map { "/\($0)" } ?? ""))

        if let buildPath {
            return (buildPath + pathComponent).absolute()
        }

        guard let tempDirURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(pathComponent) else { fatalError("Unable to get temporary path") }
        return Path(tempDirURL.path)
    }()

    public init(path: Path, cachePath: Path? = nil, version: String? = nil, buildPath: Path? = nil) throws {
        self.sourcePath = path
        self.buildPath = buildPath
        self.cachePath = cachePath
        self.version = version
        (self.mainFileCodeRaw, self.includedFiles) = try SwiftTemplate.parse(sourcePath: path)
    }

    private enum Command {
        case includeFile(Path)
        case output(String)
        case controlFlow(String)
        case outputEncoded(String)
    }

    static func parse(sourcePath: Path) throws -> (String, [Path]) {
        let commands = try SwiftTemplate.parseCommands(in: sourcePath)
        let startParsing = currentTimestamp()
        var includedFiles: [Path] = []
        var outputFile = [String]()
        var hasContents = false
        for command in commands {
            switch command {
            case let .includeFile(path):
                includedFiles.append(path)
            case let .output(code):
                outputFile.append("sourceryBuffer.append(\"\\(" + code + ")\");")
                hasContents = true
            case let .controlFlow(code):
                outputFile.append("\(code)")
                hasContents = true
            case let .outputEncoded(code):
                if !code.isEmpty {
                    outputFile.append(("sourceryBuffer.append(\"") + code.stringEncoded + "\");")
                    hasContents = true
                }
            }
        }
        if hasContents {
            outputFile.insert("var sourceryBuffer = \"\";", at: 0)
        }
        outputFile.append("print(\"\\(sourceryBuffer)\", terminator: \"\");")

        let contents = outputFile.joined(separator: "\n")
        let code = """
        import Foundation
        import SourceryRuntime

        let context = ProcessInfo.processInfo.context!
        let types = context.types
        let functions = context.functions
        let type = context.types.typesByName
        let argument = context.argument

        \(contents)
        """
        Log.benchmark("\tRaw processing time for \(sourcePath.lastComponent) took: \(currentTimestamp() - startParsing)")
        return (code, includedFiles)
    }

    private static func parseCommands(in sourcePath: Path, includeStack: [Path] = []) throws -> [Command] {
        let startProcessing = currentTimestamp()
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
        Log.benchmark("\tRaw command processing for \(sourcePath.lastComponent) took: \(currentTimestamp() - startProcessing)")
        return commands
    }

    public func render(_ context: Any) throws -> String {
        do {
            return try render(context: context)
        } catch is RenderError {
            return try render(context: context)
        }
    }

    private func render(context: Any) throws -> String {
        var destinationBinaryPath: Path
        var originalBinaryPath = buildDir + Path(".build/release/SwiftTemplate")
        if let cachePath = cachePath,
           let hash = executableCacheKey,
           let hashPath = hash.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) {
            destinationBinaryPath = cachePath + hashPath
            if destinationBinaryPath.exists {
                Log.benchmark("Reusing built SwiftTemplate binary for SwiftTemplate with cache key: \(hash)...")
            } else {
                Log.benchmark("Building new SwiftTemplate binary for SwiftTemplate...")
                try build()
                // attempt to create cache dir
                try? cachePath.mkdir()
                // attempt to move to the created `cacheDir`
                try? originalBinaryPath.copy(destinationBinaryPath)
            }
            // create a link to the compiled binary in a unique stable location
            if !buildDir.exists {
                try buildDir.mkpath()
            }
            originalBinaryPath = buildDir + hashPath
            destinationBinaryPath = destinationBinaryPath.isRelative ? destinationBinaryPath.absolute() : destinationBinaryPath
            try FileManager.default.createSymbolicLink(atPath: originalBinaryPath.string, withDestinationPath: destinationBinaryPath.string)
        } else {
            try build()
        }

        let serializedContextPath = buildDir + "context.bin"
        let data = try NSKeyedArchiver.archivedData(withRootObject: context, requiringSecureCoding: false)
        if !buildDir.exists {
            try buildDir.mkpath()
        }
        try serializedContextPath.write(data)

        Log.benchmark("Binary file location: \(originalBinaryPath.string)")
        if FileManager.default.fileExists(atPath: originalBinaryPath.string) {
            let result = try Process.runCommand(path: originalBinaryPath.string,
                                                arguments: [serializedContextPath.description])
            if !result.error.isEmpty {
                throw "\(sourcePath): \(result.error)"
            }
            return result.output
        }
        throw RenderError.binaryMissing
    }

    private func build() throws {
        let startCompiling = currentTimestamp()
        let sourcesDir = buildDir + Path("Sources")
        let templateFilesDir = sourcesDir + Path("SwiftTemplate")
        let mainFile = templateFilesDir + Path("main.swift")
        let manifestFile = buildDir + Path("Package.swift")

        try sourcesDir.mkpath()
        try? templateFilesDir.delete()
        try templateFilesDir.mkpath()

        try copyRuntimePackage(to: sourcesDir)
        if !manifestFile.exists {
            try manifestFile.write(manifestCode)
        }
        try mainFile.write(mainFileCodeRaw)

        try includedFiles.forEach { includedFile in
            try includedFile.copy(templateFilesDir + Path(includedFile.lastComponent))
        }
#if os(macOS)
        let arguments = [
            "xcrun",
            "--sdk", "macosx",
            "swift",
            "build",
            "-c", "release",
            "-Xswiftc", "-Onone",
            "-Xswiftc", "-suppress-warnings",
            "--disable-sandbox"
        ]
#else
        let arguments = [
            "swift",
            "build",
            "-c", "release",
            "-Xswiftc", "-Onone",
            "-Xswiftc", "-suppress-warnings",
            "--disable-sandbox"
        ]
#endif
        let compilationResult = try Process.runCommand(path: "/usr/bin/env",
                                                       arguments: arguments,
                                                       currentDirectoryPath: buildDir)
        if compilationResult.exitCode != EXIT_SUCCESS {
            throw [compilationResult.output, compilationResult.error]
                .filter { !$0.isEmpty }
                .joined(separator: "\n")
        }
        Log.benchmark("\tRaw compilation of SwiftTemplate took: \(currentTimestamp() - startCompiling)")
    }

#if os(macOS)
    private var manifestCode: String {
        return """
        // swift-tools-version:5.7
        // The swift-tools-version declares the minimum version of Swift required to build this package.

        import PackageDescription

        let package = Package(
            name: "SwiftTemplate",
            platforms: [
                .macOS(.v10_15)
            ],
            products: [
                .executable(name: "SwiftTemplate", targets: ["SwiftTemplate"])
            ],
            targets: [
                .target(name: "SourceryRuntime"),
                .executableTarget(name: "SwiftTemplate", dependencies: ["SourceryRuntime"])
            ]
        )
        """
    }
#else
    private var manifestCode: String {
        return """
        // swift-tools-version:5.7
        // The swift-tools-version declares the minimum version of Swift required to build this package.

        import PackageDescription

        let package = Package(
            name: "SwiftTemplate",
            products: [
                .executable(name: "SwiftTemplate", targets: ["SwiftTemplate"])
            ],
            targets: [
                .target(name: "SourceryRuntime"),
                .executableTarget(name: "SwiftTemplate", dependencies: ["SourceryRuntime"])
            ]
        )
        """
    }
#endif

    /// Brief:
    ///   - Executable cache key is calculated solely on the contents of the SwiftTemplate ephemeral package.
    /// Rationale:
    ///   1. cache key is used to find SwiftTemplate `executable` file from a previous compilation
    ///   2. `SwiftTemplate` contains types from `SourceryRuntime` and `main.swift`
    ///   3. `main.swift` in `SwiftTemplate` contains `only .swifttemplate file processing result`
    ///   4. Copied `includeFile` directives from the given `.swifttemplate` are also included into `SwiftTemplate` ephemeral package
    ///
    /// Due to this reason, the correct logic for calculating `executableCacheKey` is to only consider contents of `SwiftTemplate` ephemeral package,
    /// because `main.swift` is **the only file** which changes in `SwiftTemplate` ephemeral binary, and `includeFiles` are the only files that may
    /// be changed between executions of Sourcery.
    var executableCacheKey: String? {
        var contents = mainFileCodeRaw
        let files = includedFiles.map({ $0.absolute() }).sorted(by: { $0.string < $1.string })
        for file in files {
            let hash = (try? file.read().sha256().base64EncodedString()) ?? ""
            contents += "\n// \(file.string)-\(hash)"
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

        init(name: String, content: String) {
            assert(name.isEmpty == false)
            self.name = name
            self.content = content
        }
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
