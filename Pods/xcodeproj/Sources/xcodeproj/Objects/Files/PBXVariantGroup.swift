import Foundation

// This is the element for referencing localized resources.
public final class PBXVariantGroup: PBXGroup {
    override func isEqual(to object: Any?) -> Bool {
        guard let rhs = object as? PBXVariantGroup else { return false }
        return isEqual(to: rhs)
    }
}
