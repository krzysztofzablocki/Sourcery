import Foundation

/// This is the element for a build target that aggregates several others.
public final class PBXAggregateTarget: PBXTarget {}

// MARK: - PBXAggregateTarget Extension (PlistSerializable)

extension PBXAggregateTarget: PlistSerializable {
    func plistKeyAndValue(proj: PBXProj, reference: String) throws -> (key: CommentedString, value: PlistValue) {
        return try plistValues(proj: proj, isa: PBXAggregateTarget.isa, reference: reference)
    }
}
