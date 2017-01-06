import Foundation

final class Typealias: NSObject, AutoDiffable, NSCoding {
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

    // serialization {
    required init?(coder aDecoder: NSCoder) {

        self.aliasName = aDecoder.decode(forKey: "aliasName")
        self.typeName = aDecoder.decode(forKey: "typeName")
        self.parent = aDecoder.decode(forKey: "parent")
        self.parentName = aDecoder.decode(forKey: "parentName")

    }

    func encode(with aCoder: NSCoder) {

        aCoder.encode(self.aliasName, forKey: "aliasName")
        aCoder.encode(self.typeName, forKey: "typeName")
        aCoder.encode(self.parent, forKey: "parent")
        aCoder.encode(self.parentName, forKey: "parentName")

    }
    // }
}
