import Foundation
import PathKit
import xcodeproj
import SourceryRuntime

private struct UnableToAddSourceFile: Error {
    var targetName: String
    var path: String
}

extension XcodeProj {

    func target(named targetName: String) -> PBXTarget? {
        return pbxproj.targets(named: targetName).first
    }

    func fullPath<E: PBXFileElement>(fileElement: E, sourceRoot: Path) -> Path? {
        return try? fileElement.fullPath(sourceRoot: sourceRoot)
    }

    func sourceFilesPaths(target: PBXTarget, sourceRoot: Path) -> [Path] {
        let sourceFiles = (try? target.sourceFiles()) ?? []
        return sourceFiles
            .compactMap({ fullPath(fileElement: $0, sourceRoot: sourceRoot) })
    }

    var rootGroup: PBXGroup? {
        do {
            return try pbxproj.rootGroup()
        } catch {
            Log.error("Can't find root group for pbxproj")
            return nil
        }
    }

    func addGroup(named groupName: String, to toGroup: PBXGroup, options: GroupAddingOptions = []) -> PBXGroup? {
        do {
            return try toGroup.addGroup(named: groupName, options: options).last
        } catch {
            Log.error("Can't add group \(groupName) to group (uuid: \(toGroup.uuid), name: \(String(describing: toGroup.name))")
            return nil
        }
    }

    func addSourceFile(at filePath: Path, toGroup: PBXGroup, target: PBXTarget, sourceRoot: Path) throws {
        let fileReference = try toGroup.addFile(at: filePath, sourceRoot: sourceRoot)
        let file = PBXBuildFile(file: fileReference, product: nil, settings: nil)

        guard let fileElement = file.file, let sourcePhase = try target.sourcesBuildPhase() else {
            throw UnableToAddSourceFile(targetName: target.name, path: filePath.string)
        }
        let buildFile = try sourcePhase.add(file: fileElement)
        pbxproj.add(object: buildFile)
    }

}
