import Foundation

/// This is the element for the sources compilation build phase.
final public class PBXSourcesBuildPhase: PBXBuildPhase {

    public override var buildPhase: BuildPhase {
        return .sources
    }

    // MARK: - Hashable
    
    public override func isEqual(to object: PBXObject) -> Bool {
        guard let rhs = object as? PBXSourcesBuildPhase,
            super.isEqual(to: rhs) else {
                return false
        }
        let lhs = self
        return lhs.buildActionMask == rhs.buildActionMask &&
        lhs.files == rhs.files &&
        lhs.runOnlyForDeploymentPostprocessing == rhs.runOnlyForDeploymentPostprocessing
    }
}

extension PBXSourcesBuildPhase: PlistSerializable {

    // MARK: - PlistSerializable
    
    func plistKeyAndValue(proj: PBXProj, reference: String) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = plistValues(proj: proj, reference: reference)
        dictionary["isa"] = .string(CommentedString(PBXSourcesBuildPhase.isa))
        return (key: CommentedString(reference, comment: "Sources"), value: .dictionary(dictionary))
    }
    
}
