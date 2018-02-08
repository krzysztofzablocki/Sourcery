import Foundation

/// This is the element for a build target that aggregates several others.
final public class PBXAggregateTarget: PBXTarget {

}

// MARK: - PBXAggregateTarget Extension (PlistSerializable)

extension PBXAggregateTarget: PlistSerializable {
    
    func plistKeyAndValue(proj: PBXProj, reference: String) -> (key: CommentedString, value: PlistValue) {
        return plistValues(proj: proj, isa: PBXAggregateTarget.isa, reference: reference)
    }
    
}
