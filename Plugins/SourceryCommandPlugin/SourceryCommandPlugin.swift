import PackagePlugin
import Foundation

@main
struct SourceryCommandPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        let configFilePath = context.package.directory.appending(subpath: ".sourcery.yml").string
        guard FileManager.default.fileExists(atPath: configFilePath) else {
            Diagnostics.error("🤷‍♂️ Could not find config at: \(configFilePath)")
            return
        }
        
        let sourceryExecutable = try context.tool(named: "SourceryExecutable")
        let sourceryURL = URL(fileURLWithPath: sourceryExecutable.path.string)
        
        let process = Process()
        process.executableURL = sourceryURL
        process.arguments = [
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
