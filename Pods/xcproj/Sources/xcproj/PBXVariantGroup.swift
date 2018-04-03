import Foundation

// This is the element for referencing localized resources.
final public class PBXVariantGroup: PBXGroup {

    // MARK: - Hashable

    public override func isEqual(to object: PBXObject) -> Bool {
        guard let rhs = object as? PBXVariantGroup else {
                return false
        }
        return super.isEqual(to: rhs)
    }

}
