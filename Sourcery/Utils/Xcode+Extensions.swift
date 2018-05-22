import Foundation
import xcproj

extension XcodeProj {

    func target(named targetName: String) -> PBXTarget? {
        return pbxproj.objects.targets(named: targetName).first?.object
    }

    func fullPath<E: PBXFileElement>(fileElement: ObjectReference<E>, sourceRoot: Path) -> Path? {
        return pbxproj.objects.fullPath(fileElement: fileElement.object, reference: fileElement.reference, sourceRoot: sourceRoot)
    }

    func sourceFilesPaths(target: PBXTarget, sourceRoot: Path) -> [Path] {
        return pbxproj.objects.sourceFiles(target: target)
            .compactMap({ fullPath(fileElement: $0, sourceRoot: sourceRoot) })
    }

    var rootGroup: PBXGroup {
        return pbxproj.rootGroup
    }

    func addGroup(named groupName: String, to toGroup: PBXGroup, options: GroupAddingOptions = []) -> ObjectReference<PBXGroup> {
        // swiftlint:disable:next force_unwrapping
        return pbxproj.objects.addGroup(named: groupName, to: toGroup, options: options).last!
    }

    func addSourceFile(at filePath: Path, toGroup: PBXGroup, target: PBXTarget, sourceRoot: Path) throws {
        let file = try pbxproj.objects.addFile(at: filePath, toGroup: toGroup, sourceRoot: sourceRoot)
        _ = pbxproj.objects.addBuildFile(toTarget: target, reference: file.reference)
    }

}
