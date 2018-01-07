import Foundation

/// This is the element for a build target that produces a binary content (application or library).
final public class PBXNativeTarget: PBXTarget {

}

// MARK: - PBXNativeTarget Extension (PlistSerializable)

extension PBXNativeTarget: PlistSerializable {
    
    func plistKeyAndValue(proj: PBXProj, reference: String) -> (key: CommentedString, value: PlistValue) {
        return plistValues(proj: proj, isa: PBXNativeTarget.isa, reference: reference)
    }
    
}
