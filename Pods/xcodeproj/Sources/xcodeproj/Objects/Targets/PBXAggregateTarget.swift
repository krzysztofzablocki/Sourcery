import Foundation

/// This is the element for a build target that aggregates several others.
public final class PBXAggregateTarget: PBXTarget {
    override func isEqual(to object: Any?) -> Bool {
        guard let rhs = object as? PBXAggregateTarget else { return false }
        return isEqual(to: rhs)
    }
}

// MARK: - PBXAggregateTarget Extension (PlistSerializable)

extension PBXAggregateTarget: PlistSerializable {
    func plistKeyAndValue(proj: PBXProj, reference: String) throws -> (key: CommentedString, value: PlistValue) {
        return try plistValues(proj: proj, isa: PBXAggregateTarget.isa, reference: reference)
    }
}
