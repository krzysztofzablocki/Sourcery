import Foundation

#if !canImport(ObjectiveC)
public class NSException {
    static func raise(_ name: String, format: String, arguments: CVaListPointer) {
        fatalError ("\(name) exception: \(NSString(format: format, arguments: arguments))")
    }

    static func raise(_ name: String) {
        fatalError("\(name) exception")
    }
}
#endif

/// Describes Swift AssociatedType
#if canImport(ObjectiveC)
@objcMembers
#endif
public final class AssociatedType: NSObject, SourceryModel {
    /// Associated type name
    public let name: String

    /// Associated type type constraint name, if specified
    public let typeName: TypeName?

    // sourcery: skipEquality, skipDescription
    /// Associated type constrained type, if known, i.e. if the type is declared in the scanned sources.
    public var type: Type?

    /// :nodoc:
    public init(name: String, typeName: TypeName? = nil, type: Type? = nil) {
        self.name = name
        self.typeName = typeName
        self.type = type
    }

    public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? AssociatedType else {
            results.append("Incorrect type <expected: AssociatedType, received: \(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: castObject.name))
        results.append(contentsOf: DiffableResult(identifier: "typeName").trackDifference(actual: self.typeName, expected: castObject.typeName))
        return results
    }

    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? AssociatedType else { return false }
        if self.name != rhs.name { return false }
        if self.typeName != rhs.typeName { return false }
        return true
    }

// sourcery:inline:AssociatedType.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { 
                withVaList(["name"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.name = name
            self.typeName = aDecoder.decode(forKey: "typeName")
            self.type = aDecoder.decode(forKey: "type")
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.typeName, forKey: "typeName")
            aCoder.encode(self.type, forKey: "type")
        }
// sourcery:end
}
