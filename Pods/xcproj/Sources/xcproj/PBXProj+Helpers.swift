import Foundation
import PathKit

// MARK: - PBXProj Extension (Public)

public extension PBXProj {

    /// Returns root project.
    public var rootProject: PBXProject? {
        return objects.projects[rootObject]
    }

    /// Returns root project's root group.
    public var rootGroup: PBXGroup {
        guard let rootProject = self.rootProject else {
            fatalError("Missing root project")
        }
        guard let rootGroup = objects.groups[rootProject.mainGroup] else {
            fatalError("Root project has no root group")
        }
        return rootGroup
    }

}

// MARK: - PBXProj Extension (Getters)

extension PBXProj {

    /// Infers project name from Path and sets it as project name
    ///
    /// Project name is needed for certain comments when serialising PBXProj
    ///
    /// - Parameters:
    ///   - path: path to .xcodeproj directory.
    func updateProjectName(path: Path) {
        guard path.parent().extension == "xcodeproj" else {
            return
        }
        let projectName = path.parent().lastComponentWithoutExtension
        let rootProject = objects.projects.getReference(rootObject)
        rootProject?.name = projectName
    }

}

// MARK: - PBXProj extension (Writable)

extension PBXProj: Writable {

    public func write(path: Path, override: Bool) throws {
        let encoder = PBXProjEncoder()
        let output = encoder.encode(proj: self)
        if override && path.exists {
            try path.delete()
        }
        try path.write(output)
    }

}
