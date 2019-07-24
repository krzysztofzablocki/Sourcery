//
//  library_wrapper.swift
//  sourcekitten
//
//  Created by Norio Nomura on 2/20/16.
//  Copyright © 2016 SourceKitten. All rights reserved.
//

import Foundation

struct DynamicLinkLibrary {
    let path: String
    let handle: UnsafeMutableRawPointer

    func load<T>(symbol: String) -> T {
        if let sym = dlsym(handle, symbol) {
            return unsafeBitCast(sym, to: T.self)
        }
        let errorString = String(validatingUTF8: dlerror())
        fatalError("Finding symbol \(symbol) failed: \(errorString ?? "unknown error")")
    }
}

#if os(Linux)
let toolchainLoader = Loader(searchPaths: [
    linuxSourceKitLibPath,
    linuxFindSwiftenvActiveLibPath,
    linuxFindSwiftInstallationLibPath,
    linuxDefaultLibPath
].compactMap({ $0 }))
#else
let toolchainLoader = Loader(searchPaths: [
    xcodeDefaultToolchainOverride,
    toolchainDir,
    xcrunFindPath,
    /*
    These search paths are used when `xcode-select -p` points to
    "Command Line Tools OS X for Xcode", but Xcode.app exists.
    */
    applicationsDir?.xcodeDeveloperDir.toolchainDir,
    applicationsDir?.xcodeBetaDeveloperDir.toolchainDir,
    userApplicationsDir?.xcodeDeveloperDir.toolchainDir,
    userApplicationsDir?.xcodeBetaDeveloperDir.toolchainDir
].compactMap { path in
    if let fullPath = path?.usrLibDir, FileManager.default.fileExists(atPath: fullPath) {
        return fullPath
    }
    return nil
})
#endif

struct Loader {
    let searchPaths: [String]

    func load(path: String) -> DynamicLinkLibrary {
        let fullPaths = searchPaths.map { $0.appending(pathComponent: path) }.filter { $0.isFile }

        // try all fullPaths that contains target file,
        // then try loading with simple path that depends resolving to DYLD
        for fullPath in fullPaths + [path] {
            if let handle = dlopen(fullPath, RTLD_LAZY) {
                return DynamicLinkLibrary(path: path, handle: handle)
            }
        }

        fatalError("Loading \(path) failed")
    }
}

private func env(_ name: String) -> String? {
    return ProcessInfo.processInfo.environment[name]
}

/// Run a process at the given (absolute) path, capture output, return outupt.
private func runCommand(_ path: String, _ args: String...) -> String? {
    let process = Process()
    process.arguments = args

    let pipe = Pipe()
    process.standardOutput = pipe
    // FileHandle.nullDevice does not work here, as it consists of an invalid file descriptor,
    // causing process.launch() to abort with an EBADF.
    process.standardError = FileHandle(forWritingAtPath: "/dev/null")!
    do {
    #if canImport(Darwin)
        if #available(macOS 10.13, *) {
            process.executableURL = URL(fileURLWithPath: path)
            try process.run()
        } else {
            process.launchPath = path
            process.launch()
        }
    #elseif compiler(>=5)
        process.executableURL = URL(fileURLWithPath: path)
        try process.run()
    #else
        process.launchPath = path
        process.launch()
    #endif
    } catch {
        return nil
    }

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    guard let encoded = String(data: data, encoding: String.Encoding.utf8) else {
        return nil
    }

    let trimmed = encoded.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    if trimmed.isEmpty {
        return nil
    }
    return trimmed
}

/// Returns "LINUX_SOURCEKIT_LIB_PATH" environment variable.
internal let linuxSourceKitLibPath = env("LINUX_SOURCEKIT_LIB_PATH")

/// If available, uses `swiftenv` to determine the user's active Swift root.
internal let linuxFindSwiftenvActiveLibPath: String? = {
    guard let swiftenvPath = runCommand("/usr/bin/which", "swiftenv") else {
        return nil
    }

    guard let swiftenvRoot = runCommand(swiftenvPath, "prefix") else {
        return nil
    }

    return swiftenvRoot + "/usr/lib"
}()

/// Attempts to discover the location of libsourcekitdInProc.so by looking at
/// the `swift` binary on the path.
internal let linuxFindSwiftInstallationLibPath: String? = {
    guard let swiftPath = runCommand("/usr/bin/which", "swift") else {
        return nil
    }

    if linuxSourceKitLibPath == nil && linuxFindSwiftenvActiveLibPath == nil &&
       swiftPath.hasSuffix("/shims/swift") {
        /// If we hit this path, the user is invoking Swift via swiftenv shims and has not set the
        /// environment variable; this means we're going to end up trying to load from `/usr/lib`
        /// which will fail - and instead, we can give a more useful error message.
        fatalError("Swift is installed via swiftenv but swiftenv is not initialized.")
    }

    if !swiftPath.hasSuffix("/bin/swift") {
        return nil
    }

    /// .../bin/swift -> .../lib
    return swiftPath.deleting(lastPathComponents: 2).appending(pathComponent: "/lib")
}()

/// Fallback path on Linux if no better option is available.
internal let linuxDefaultLibPath = "/usr/lib"

/// Returns "XCODE_DEFAULT_TOOLCHAIN_OVERRIDE" environment variable
///
/// `launch-with-toolchain` sets the toolchain path to the
/// "XCODE_DEFAULT_TOOLCHAIN_OVERRIDE" environment variable.
private let xcodeDefaultToolchainOverride = env("XCODE_DEFAULT_TOOLCHAIN_OVERRIDE")

/// Returns "TOOLCHAIN_DIR" environment variable
///
/// `Xcode`/`xcodebuild` sets the toolchain path to the
/// "TOOLCHAIN_DIR" environment variable.
private let toolchainDir = env("TOOLCHAIN_DIR")

/// Returns toolchain directory that parsed from result of `xcrun -find swift`
///
/// This is affected by "DEVELOPER_DIR", "TOOLCHAINS" environment variables.
private let xcrunFindPath: String? = {
    let pathOfXcrun = "/usr/bin/xcrun"

    if !FileManager.default.isExecutableFile(atPath: pathOfXcrun) {
        return nil
    }

    let task = Process()
    task.arguments = ["-find", "swift"]

    let pipe = Pipe()
    task.standardOutput = pipe
    do {
    #if canImport(Darwin)
        if #available(macOS 10.13, *) {
            task.executableURL = URL(fileURLWithPath: pathOfXcrun)
            try task.run()
        } else {
            task.launchPath = pathOfXcrun
            task.launch() // if xcode-select does not exist, crash with `NSInvalidArgumentException`.
        }
    #elseif compiler(>=5)
        task.executableURL = URL(fileURLWithPath: pathOfXcrun)
        try task.run()
    #else
        task.launchPath = pathOfXcrun
        task.launch() // if xcode-select does not exist, crash with `NSInvalidArgumentException`.
    #endif
    } catch {
        return nil
    }

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    guard let output = String(data: data, encoding: .utf8) else {
        return nil
    }

    var start = output.startIndex
    var end = output.startIndex
    var contentsEnd = output.startIndex
    output.getLineStart(&start, end: &end, contentsEnd: &contentsEnd, for: start..<start)
    let xcrunFindSwiftPath = String(output[start..<contentsEnd])
    guard xcrunFindSwiftPath.hasSuffix("/usr/bin/swift") else {
        return nil
    }
    let xcrunFindPath = xcrunFindSwiftPath.deleting(lastPathComponents: 3)
    // Return nil if xcrunFindPath points to "Command Line Tools OS X for Xcode"
    // because it doesn't contain `sourcekitd.framework`.
    if xcrunFindPath == "/Library/Developer/CommandLineTools" {
        return nil
    }
    return xcrunFindPath
}()

private let applicationsDir: String? =
    NSSearchPathForDirectoriesInDomains(.applicationDirectory, .systemDomainMask, true).first

private let userApplicationsDir: String? =
    NSSearchPathForDirectoriesInDomains(.applicationDirectory, .userDomainMask, true).first

private extension String {
    var toolchainDir: String {
        return appending(pathComponent: "Toolchains/XcodeDefault.xctoolchain")
    }

    var xcodeDeveloperDir: String {
        return appending(pathComponent: "Xcode.app/Contents/Developer")
    }

    var xcodeBetaDeveloperDir: String {
        return appending(pathComponent: "Xcode-beta.app/Contents/Developer")
    }

    var usrLibDir: String {
        return appending(pathComponent: "/usr/lib")
    }

    func appending(pathComponent: String) -> String {
        return URL(fileURLWithPath: self).appendingPathComponent(pathComponent).path
    }

    func deleting(lastPathComponents numberOfPathComponents: Int) -> String {
        var url = URL(fileURLWithPath: self)
        for _ in 0..<numberOfPathComponents {
            url = url.deletingLastPathComponent()
        }
        return url.path
    }
}
