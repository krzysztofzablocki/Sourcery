import Foundation
import PathKit

/// This is the element for the framework headers build phase.
public final class PBXHeadersBuildPhase: PBXBuildPhase {
    public override var buildPhase: BuildPhase {
        return .headers
    }
}

// MARK: - PBXHeadersBuildPhase Extension (PlistSerializable)

extension PBXHeadersBuildPhase: PlistSerializable {
    func plistKeyAndValue(proj: PBXProj, reference: String) throws -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = try plistValues(proj: proj, reference: reference)
        dictionary["isa"] = .string(CommentedString(PBXHeadersBuildPhase.isa))
        return (key: CommentedString(reference, comment: "Headers"), value: .dictionary(dictionary))
    }
}
