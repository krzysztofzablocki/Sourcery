import Foundation

// sourcery: skipJSExport
/// :nodoc:
#if canImport(ObjectiveC)
@objcMembers
#endif
public final class Typealias: NSObject, Typed, SourceryModel, Diffable {
    // New typealias name
    public let aliasName: String

    // Target name
    public let typeName: TypeName

    // sourcery: skipEquality, skipDescription
    public var type: Type?

    /// module in which this typealias was declared
    public var module: String?

    // sourcery: skipEquality, skipDescription
    public var parent: Type? {
        didSet {
            parentName = parent?.name
        }
    }

    /// Type access level, i.e. `internal`, `private`, `fileprivate`, `public`, `open`
    public let accessLevel: String

    var parentName: String?

    public var name: String {
        if let parentName = parent?.name {
            return "\(module != nil ? "\(module!)." : "")\(parentName).\(aliasName)"
        } else {
            return "\(module != nil ? "\(module!)." : "")\(aliasName)"
        }
    }

    public init(aliasName: String = "", typeName: TypeName, accessLevel: AccessLevel = .internal, parent: Type? = nil, module: String? = nil) {
        self.aliasName = aliasName
        self.typeName = typeName
        self.accessLevel = accessLevel.rawValue
        self.parent = parent
        self.parentName = parent?.name
        self.module = module
    }

    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "aliasName = \(String(describing: self.aliasName)), "
        string += "typeName = \(String(describing: self.typeName)), "
        string += "module = \(String(describing: self.module)), "
        string += "accessLevel = \(String(describing: self.accessLevel)), "
        string += "parentName = \(String(describing: self.parentName)), "
        string += "name = \(String(describing: self.name))"
        return string
    }

    public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? Typealias else {
            results.append("Incorrect type <expected: Typealias, received: \(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "aliasName").trackDifference(actual: self.aliasName, expected: castObject.aliasName))
        results.append(contentsOf: DiffableResult(identifier: "typeName").trackDifference(actual: self.typeName, expected: castObject.typeName))
        results.append(contentsOf: DiffableResult(identifier: "module").trackDifference(actual: self.module, expected: castObject.module))
        results.append(contentsOf: DiffableResult(identifier: "accessLevel").trackDifference(actual: self.accessLevel, expected: castObject.accessLevel))
        results.append(contentsOf: DiffableResult(identifier: "parentName").trackDifference(actual: self.parentName, expected: castObject.parentName))
        return results
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.aliasName)
        hasher.combine(self.typeName)
        hasher.combine(self.module)
        hasher.combine(self.accessLevel)
        hasher.combine(self.parentName)
        return hasher.finalize()
    }

    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Typealias else { return false }
        if self.aliasName != rhs.aliasName { return false }
        if self.typeName != rhs.typeName { return false }
        if self.module != rhs.module { return false }
        if self.accessLevel != rhs.accessLevel { return false }
        if self.parentName != rhs.parentName { return false }
        return true
    }
    
// sourcery:inline:Typealias.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let aliasName: String = aDecoder.decode(forKey: "aliasName") else { 
                withVaList(["aliasName"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.aliasName = aliasName
            guard let typeName: TypeName = aDecoder.decode(forKey: "typeName") else { 
                withVaList(["typeName"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.typeName = typeName
            self.type = aDecoder.decode(forKey: "type")
            self.module = aDecoder.decode(forKey: "module")
            self.parent = aDecoder.decode(forKey: "parent")
            guard let accessLevel: String = aDecoder.decode(forKey: "accessLevel") else { 
                withVaList(["accessLevel"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.accessLevel = accessLevel
            self.parentName = aDecoder.decode(forKey: "parentName")
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.aliasName, forKey: "aliasName")
            aCoder.encode(self.typeName, forKey: "typeName")
            aCoder.encode(self.type, forKey: "type")
            aCoder.encode(self.module, forKey: "module")
            aCoder.encode(self.parent, forKey: "parent")
            aCoder.encode(self.accessLevel, forKey: "accessLevel")
            aCoder.encode(self.parentName, forKey: "parentName")
        }
// sourcery:end
}
