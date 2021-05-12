import Foundation
import PathKit
import XcodeProj
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
            return try toGroup.addGroupFixed(named: groupName, options: options).last
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

    func createGroupIfNeeded(named group: String? = nil, sourceRoot: Path) -> PBXGroup? {

        guard let rootGroup = rootGroup else {
            Log.warning("Unable to find rootGroup for the project")
            return nil
        }

        guard let group = group else {
            return rootGroup
        }

        var fileGroup: PBXGroup = rootGroup
        var parentGroup: PBXGroup = rootGroup
        let components = group.components(separatedBy: "/")

        // Find existing group to reuse
        // Having `ProjectRoot/Data/` exists and given group to create `ProjectRoot/Data/Generated`
        // will create `Generated` group under ProjectRoot/Data to link files to
        var existingGroup = components.reduce((group: fileGroup as PBXGroup?, components: components)) { current, name in
            let first = current.group?.children.first { $0.path == name } as? PBXGroup
            let result = first ?? current.group
            return (result, current.components.filter { $0 != result?.path })
        }

        var groupName: String?

        switch existingGroup {
        case let (group, components) where group != nil:
            if components.isEmpty {
                // Group path is already exists
                fileGroup = group!
            } else {
                // Create rest of the group and attach to last found parent
                groupName = components.joined(separator: "/")
                parentGroup = group!
            }
        default:
            // Create new group from scratch
            groupName = group
        }

        if let groupName = groupName {
            do {
                if let addedGroup = addGroup(named: groupName, to: parentGroup),
                   let groupPath = fullPath(fileElement: addedGroup, sourceRoot: sourceRoot) {
                    fileGroup = addedGroup
                    try groupPath.mkpath()
                }
            } catch {
                Log.warning("Failed to create a folder for group '\(fileGroup.name ?? "")'. \(error)")
            }
        }
        return fileGroup
    }
}

fileprivate extension PBXGroup {
    // FIXME: Replace with XcodeProj's method when it's fixed
    // addGroup from XcodeProj has a bug, see: https://github.com/tuist/XcodeProj/issues/613
    // This is workaround to add groups one by one
    func addGroupFixed(named groupName: String, options: GroupAddingOptions = []) throws -> [PBXGroup] {
        return try groupName.components(separatedBy: "/").reduce(into: [PBXGroup]()) { groups, name in
            let group = groups.last ?? self
            if let newGroup = (try group.addGroup(named: name, options: options)).last {
                groups.append(newGroup)
            }
        }
    }
}
