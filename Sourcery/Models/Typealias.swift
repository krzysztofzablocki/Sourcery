import Foundation

final class Typealias: NSObject, AutoDiffable, Typed {
    /// New typealias name
    let aliasName: String

    /// Target name
    let typeName: TypeName

    // sourcery: skipEquality, skipDescription
    var type: Type?

    // sourcery: skipEquality, skipDescription
    var parent: Type? {
        didSet {
            parentName = parent?.name
        }
    }

    private(set) var parentName: String?

    var name: String {
        if let parentName = parent?.name {
            return "\(parentName).\(aliasName)"
        } else {
            return aliasName
        }
    }

    init(aliasName: String, typeName: String, parent: Type? = nil) {
        self.aliasName = aliasName
        self.typeName = TypeName(typeName)
        self.parent = parent
        self.parentName = parent?.name
    }
}
