import Foundation
import PathKit
import xcodeproj

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
        return try? pbxproj.rootGroup()
    }

    func addGroup(named groupName: String, to toGroup: PBXGroup, options: GroupAddingOptions = []) -> PBXGroup {
        // swiftlint:disable:next force_unwrapping
        let group = try? toGroup.addGroup(named: groupName, options: options).last
        return group!
    }

    func addSourceFile(at filePath: Path, toGroup: PBXGroup, target: PBXTarget, sourceRoot: Path) throws {
        let fileReference = try toGroup.addFile(at: filePath, sourceRoot: sourceRoot)

        let file = PBXBuildFile(file: fileReference, product: nil, settings: nil)
        pbxproj.add(object: file)
    }

}
