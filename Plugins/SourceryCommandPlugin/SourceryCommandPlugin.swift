import PackagePlugin
import Foundation

@main
struct SourceryCommandPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        // Run one per target
        for target in context.package.targets {
            let configFilePath = target.directory.appending(subpath: ".sourcery.yml").string
            
            guard FileManager.default.fileExists(atPath: configFilePath) else {
                Diagnostics.warning("⚠️ Could not find `.sourcery.yml` for the given target")
                return
            }
            
            
            let sourceryExecutable = try context.tool(named: "SourceryExecutable")
            let sourceryURL = URL(fileURLWithPath: sourceryExecutable.path.string)
            
            let process = Process()
            process.executableURL = sourceryURL
            process.arguments = [
                "--config",
                configFilePath,
                "--disableCache"
            ]
            
            try process.run()
            process.waitUntilExit()
            
            let gracefulExit = process.terminationReason == .exit && process.terminationStatus == 0
            if !gracefulExit {
                Diagnostics.error("🛑 The plugin execution failed")
            }
        }
    }
}

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

            let sourceryExecutable = try context.tool(named: "SourceryExecutable")
            let sourceryURL = URL(fileURLWithPath: sourceryExecutable.path.string)
            
            let process = Process()
            process.executableURL = sourceryURL
            process.arguments = [
                "--config",
                configFilePath,
                "--disableCache"
            ]
            
            try process.run()
            process.waitUntilExit()
            
            let gracefulExit = process.terminationReason == .exit && process.terminationStatus == 0
            if !gracefulExit {
                Diagnostics.error("🛑 The plugin execution failed")
            }
        }
        debugPrint(context)
    }
}
#endif
