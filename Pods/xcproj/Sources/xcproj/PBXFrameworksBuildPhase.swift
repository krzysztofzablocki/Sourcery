import Foundation

/// This is the element for the framework link build phase.
final public class PBXFrameworksBuildPhase: PBXBuildPhase {

    public override var buildPhase: BuildPhase {
        return .frameworks
    }
    
    public override func isEqual(to object: PBXObject) -> Bool {
        guard let rhs = object as? PBXFrameworksBuildPhase,
            super.isEqual(to: rhs) else {
                return false
        }
        let lhs = self
        return lhs.files == rhs.files &&
            lhs.runOnlyForDeploymentPostprocessing == rhs.runOnlyForDeploymentPostprocessing
    }
}

// MARK: - PBXFrameworksBuildPhase Extension (PlistSerializable)

extension PBXFrameworksBuildPhase: PlistSerializable {
    
    func plistKeyAndValue(proj: PBXProj, reference: String) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = plistValues(proj: proj, reference: reference)
        dictionary["isa"] = .string(CommentedString(PBXFrameworksBuildPhase.isa))
        return (key: CommentedString(reference, comment: "Frameworks"), value: .dictionary(dictionary))
    }
    
}
