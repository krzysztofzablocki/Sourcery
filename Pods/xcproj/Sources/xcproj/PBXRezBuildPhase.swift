import Foundation

/// This is the element for the Build Carbon Resources build phase.
/// These are legacy .r files from the Classic Mac OS era.
final public class PBXRezBuildPhase: PBXBuildPhase {

    public override var buildPhase: BuildPhase {
        return .carbonResources
    }

    public override func isEqual(to object: PBXObject) -> Bool {
        guard let rhs = object as? PBXRezBuildPhase,
            super.isEqual(to: rhs) else {
                return false
        }
        let lhs = self
        return lhs.buildActionMask == rhs.buildActionMask &&
            lhs.files == rhs.files &&
            lhs.runOnlyForDeploymentPostprocessing == rhs.runOnlyForDeploymentPostprocessing
    }
}

// MARK: - PBXRezBuildPhase Extension (PlistSerializable)

extension PBXRezBuildPhase: PlistSerializable {

    func plistKeyAndValue(proj: PBXProj, reference: String) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = plistValues(proj: proj, reference: reference)
        dictionary["isa"] = .string(CommentedString(PBXRezBuildPhase.isa))
        return (key: CommentedString(reference, comment: "Rez"), value: .dictionary(dictionary))
    }

}
