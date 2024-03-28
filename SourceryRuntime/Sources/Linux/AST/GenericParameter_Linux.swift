#if !canImport(ObjectiveC)
import Foundation

/// Descibes Swift generic parameter
public final class GenericParameter: NSObject, SourceryModel, Diffable, SourceryDynamicMemberLookup {
    public subscript(dynamicMember member: String) -> Any? {
        switch member {
            case "name":
                return name
            case "inheritedTypeName":
                return inheritedTypeName
            default:
                fatalError("unable to lookup: \(member) in \(self)")
        }
    }

    /// Generic parameter name
    public var name: String

    /// Generic parameter inherited type
    public var inheritedTypeName: TypeName?

    /// :nodoc:
    public init(name: String, inheritedTypeName: TypeName? = nil) {
        self.name = name
        self.inheritedTypeName = inheritedTypeName
    }

    /// :nodoc:
    // sourcery: skipJSExport
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string.append("name = \(String(describing: self.name)), ")
        string.append("inheritedTypeName = \(String(describing: self.inheritedTypeName))")
        return string
    }

    public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? GenericParameter else {
            results.append("Incorrect type <expected: GenericParameter, received: \(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: castObject.name))
        results.append(contentsOf: DiffableResult(identifier: "inheritedTypeName").trackDifference(actual: self.inheritedTypeName, expected: castObject.inheritedTypeName))
        return results
    }

    /// :nodoc:
    // sourcery: skipJSExport
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.inheritedTypeName)
        return hasher.finalize()
    }

    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? GenericParameter else { return false }
        if self.name != rhs.name { return false }
        if self.inheritedTypeName != rhs.inheritedTypeName { return false }
        return true
    }

// sourcery:inline:GenericParameter.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { 
                withVaList(["name"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.name = name
            self.inheritedTypeName = aDecoder.decode(forKey: "inheritedTypeName")
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.inheritedTypeName, forKey: "inheritedTypeName")
        }

// sourcery:end
}
#endif
