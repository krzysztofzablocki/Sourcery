import PackagePlugin
import Foundation

@main
struct SourceryCommandPlugin {
    private func run(_ sourcery: String, withConfig configFilePath: String, cacheBasePath: String) throws {
        let sourceryURL = URL(fileURLWithPath: sourcery)
        
        let process = Process()
        process.executableURL = sourceryURL
        process.arguments = [
            "--config",
            configFilePath,
            "--cacheBasePath",
            cacheBasePath
        ]
        
        try process.run()
        process.waitUntilExit()
        
        let gracefulExit = process.terminationReason == .exit && process.terminationStatus == 0
        if !gracefulExit {
            throw "🛑 The plugin execution failed with reason: \(process.terminationReason.rawValue) and status: \(process.terminationStatus) "
        }
    }
}

// MARK: - CommandPlugin

extension SourceryCommandPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        // Run one per target
        for target in context.package.targets {
            let configFilePath = target.directory.appending(subpath: ".sourcery.yml").string
            let sourcery = try context.tool(named: "SourceryExecutable").path.string
            
            guard FileManager.default.fileExists(atPath: configFilePath) else {
                Diagnostics.warning("⚠️ Could not find `.sourcery.yml` for the given target")
                return
            }
            
            try run(sourcery, withConfig: configFilePath, cacheBasePath: context.pluginWorkDirectory.string)
        }
    }
}

// MARK: - XcodeProjectPlugin

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SourceryCommandPlugin: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        for target in context.xcodeProject.targets {
            guard let configFilePath = target
                .inputFiles
                .filter({ $0.path.lastComponent == ".sourcery.yml" })
                .first?
                .path
                .string else {
                Diagnostics.warning("⚠️ Could not find `.sourcery.yml` in Xcode's input file list")
                return
            }
            let sourcery = try context.tool(named: "SourceryExecutable").path.string
            
            try run(sourcery, withConfig: configFilePath, cacheBasePath: context.pluginWorkDirectory.string)
        }
    }
}
#endif

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
