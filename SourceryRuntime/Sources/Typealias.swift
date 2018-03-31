import Foundation

// sourcery: skipJSExport
/// :nodoc:
@objcMembers public final class Typealias: NSObject, Typed, SourceryModel {
    // New typealias name
    public let aliasName: String

    // Target name
    public let typeName: TypeName

    // sourcery: skipEquality, skipDescription
    public var type: Type?

    // sourcery: skipEquality, skipDescription
    public var parent: Type? {
        didSet {
            parentName = parent?.name
        }
    }

    var parentName: String?

    public var name: String {
        if let parentName = parent?.name {
            return "\(parentName).\(aliasName)"
        } else {
            return aliasName
        }
    }

    // TODO: access level

    public init(aliasName: String = "", typeName: TypeName, parent: Type? = nil) {
        self.aliasName = aliasName
        self.typeName = typeName
        self.parent = parent
        self.parentName = parent?.name
    }

    // sourcery:inline:Typealias.AutoCoding
        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let aliasName: String = aDecoder.decode(forKey: "aliasName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["aliasName"])); fatalError() }; self.aliasName = aliasName
            guard let typeName: TypeName = aDecoder.decode(forKey: "typeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typeName"])); fatalError() }; self.typeName = typeName
            self.type = aDecoder.decode(forKey: "type")
            self.parent = aDecoder.decode(forKey: "parent")
            self.parentName = aDecoder.decode(forKey: "parentName")
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.aliasName, forKey: "aliasName")
            aCoder.encode(self.typeName, forKey: "typeName")
            aCoder.encode(self.type, forKey: "type")
            aCoder.encode(self.parent, forKey: "parent")
            aCoder.encode(self.parentName, forKey: "parentName")
        }
        // sourcery:end
}
