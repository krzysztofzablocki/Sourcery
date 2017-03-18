import Xcode

extension String: Error {}

extension XCProjectFile {

    convenience init(path: String) throws {
        try self.init(xcodeprojURL: URL(fileURLWithPath: path))
    }

    func sourceFilesPaths(targetName: String, sourceRoot: String) throws -> [Path] {
        let allTargets = project.targets
        guard let target = allTargets.filter({ $0.name == targetName }).first else {
            throw "Missing target \(targetName)."
        }

        let sourceFileRefs = target.buildPhases
            .flatMap({ $0 as? PBXSourcesBuildPhase })
            .flatMap({ $0.files })
            .map({ $0.fileRef })

        let fileRefPaths = sourceFileRefs
            .flatMap({ $0 as? PBXFileReference })
            .map({ $0.fullPath })

        let swiftFilesPaths = fileRefPaths.flatMap(pathResolver(sourceRoot: sourceRoot))
        return swiftFilesPaths
    }

}

private func pathResolver(sourceRoot: String) -> (Xcode.Path) -> Path? {
    return { path in
        switch path {
        case let .absolute(absolutePath):
            return Path(URL(fileURLWithPath: absolutePath).path)
        case let .relativeTo(sourceTreeFolder, relativePath):
            switch sourceTreeFolder {
            case .sourceRoot:
                let sourceTreeURL = URL(fileURLWithPath: sourceRoot)
                return Path(sourceTreeURL.appendingPathComponent(relativePath).path)
            default:
                return nil
            }
        }
    }
}
