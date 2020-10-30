import Foundation

/// This is the element for the Build Carbon Resources build phase.
/// These are legacy .r files from the Classic Mac OS era.
public final class PBXRezBuildPhase: PBXBuildPhase {
    public override var buildPhase: BuildPhase {
        return .carbonResources
    }
}

// MARK: - PBXRezBuildPhase Extension (PlistSerializable)

extension PBXRezBuildPhase: PlistSerializable {
    func plistKeyAndValue(proj: PBXProj, reference: String) throws -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = try plistValues(proj: proj, reference: reference)
        dictionary["isa"] = .string(CommentedString(PBXRezBuildPhase.isa))
        return (key: CommentedString(reference, comment: "Rez"), value: .dictionary(dictionary))
    }
}
