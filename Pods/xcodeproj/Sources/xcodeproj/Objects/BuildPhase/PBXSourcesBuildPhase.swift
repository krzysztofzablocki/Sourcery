import Foundation

/// This is the element for the sources compilation build phase.
public final class PBXSourcesBuildPhase: PBXBuildPhase {
    public override var buildPhase: BuildPhase {
        return .sources
    }
}

extension PBXSourcesBuildPhase: PlistSerializable {
    // MARK: - PlistSerializable

    func plistKeyAndValue(proj: PBXProj, reference: String) throws -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = try plistValues(proj: proj, reference: reference)
        dictionary["isa"] = .string(CommentedString(PBXSourcesBuildPhase.isa))
        return (key: CommentedString(reference, comment: "Sources"), value: .dictionary(dictionary))
    }
}
