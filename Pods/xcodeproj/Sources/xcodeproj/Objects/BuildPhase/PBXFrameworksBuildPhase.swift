import Foundation

/// This is the element for the framework link build phase.
public final class PBXFrameworksBuildPhase: PBXBuildPhase {
    override public var buildPhase: BuildPhase {
        .frameworks
    }

    override func isEqual(to object: Any?) -> Bool {
        guard let rhs = object as? PBXFrameworksBuildPhase else { return false }
        return isEqual(to: rhs)
    }
}

// MARK: - PBXFrameworksBuildPhase Extension (PlistSerializable)

extension PBXFrameworksBuildPhase: PlistSerializable {
    func plistKeyAndValue(proj: PBXProj, reference: String) throws -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = try plistValues(proj: proj, reference: reference)
        dictionary["isa"] = .string(CommentedString(PBXFrameworksBuildPhase.isa))
        return (key: CommentedString(reference, comment: "Frameworks"), value: .dictionary(dictionary))
    }
}
