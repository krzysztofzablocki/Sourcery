import Foundation
import PathKit
import XcodeProj

extension XcodeProj {

    public func target(named targetName: String) -> PBXTarget? {
        return pbxproj.targets(named: targetName).first
    }

    public func fullPath<E: PBXFileElement>(fileElement: E, sourceRoot: Path) -> Path? {
        return try? fileElement.fullPath(sourceRoot: sourceRoot)
    }

    public func sourceFilesPaths(target: PBXTarget, sourceRoot: Path) -> [Path] {
        let sourceFiles = (try? target.sourceFiles()) ?? []
        return sourceFiles
            .compactMap({ fullPath(fileElement: $0, sourceRoot: sourceRoot) })
    }
    
}
