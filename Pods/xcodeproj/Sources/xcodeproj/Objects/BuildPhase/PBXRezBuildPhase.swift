import Foundation

/// This is the element for the Build Carbon Resources build phase.
/// These are legacy .r files from the Classic Mac OS era.
public final class PBXRezBuildPhase: PBXBuildPhase {
    override public var buildPhase: BuildPhase {
        .carbonResources
    }

    override func isEqual(to object: Any?) -> Bool {
        guard let rhs = object as? PBXRezBuildPhase else { return false }
        return isEqual(to: rhs)
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
