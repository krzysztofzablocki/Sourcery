#if !canImport(ObjectiveC)
import Foundation

/// Descibes Swift generic requirement
public class GenericRequirement: NSObject, SourceryModel, Diffable, SourceryDynamicMemberLookup {
    public subscript(dynamicMember member: String) -> Any? {
        switch member {
            case "leftType":
                return leftType
            case "rightType":
                return rightType
            case "relationship":
                return relationship
            case "relationshipSyntax":
                return relationshipSyntax
            default:
                fatalError("unable to lookup: \(member) in \(self)")
        }
    }

    public enum Relationship: String {
        case equals
        case conformsTo

        var syntax: String {
            switch self {
            case .equals:
                return "=="
            case .conformsTo:
                return ":"
            }
        }
    }

    public var leftType: AssociatedType
    public let rightType: GenericTypeParameter

    /// relationship name
    public let relationship: String

    /// Syntax e.g. `==` or `:`
    public let relationshipSyntax: String

    public init(leftType: AssociatedType, rightType: GenericTypeParameter, relationship: Relationship) {
        self.leftType = leftType
        self.rightType = rightType
        self.relationship = relationship.rawValue
        self.relationshipSyntax = relationship.syntax
    }

    /// :nodoc:
    // sourcery: skipJSExport
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string.append("leftType = \(String(describing: self.leftType)), ")
        string.append("rightType = \(String(describing: self.rightType)), ")
        string.append("relationship = \(String(describing: self.relationship)), ")
        string.append("relationshipSyntax = \(String(describing: self.relationshipSyntax))")
        return string
    }

    public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? GenericRequirement else {
            results.append("Incorrect type <expected: GenericRequirement, received: \(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "leftType").trackDifference(actual: self.leftType, expected: castObject.leftType))
        results.append(contentsOf: DiffableResult(identifier: "rightType").trackDifference(actual: self.rightType, expected: castObject.rightType))
        results.append(contentsOf: DiffableResult(identifier: "relationship").trackDifference(actual: self.relationship, expected: castObject.relationship))
        results.append(contentsOf: DiffableResult(identifier: "relationshipSyntax").trackDifference(actual: self.relationshipSyntax, expected: castObject.relationshipSyntax))
        return results
    }

    /// :nodoc:
    // sourcery: skipJSExport
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.leftType)
        hasher.combine(self.rightType)
        hasher.combine(self.relationship)
        hasher.combine(self.relationshipSyntax)
        return hasher.finalize()
    }

    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? GenericRequirement else { return false }
        if self.leftType != rhs.leftType { return false }
        if self.rightType != rhs.rightType { return false }
        if self.relationship != rhs.relationship { return false }
        if self.relationshipSyntax != rhs.relationshipSyntax { return false }
        return true
    }

    // sourcery:inline:GenericRequirement.AutoCoding

            /// :nodoc:
            required public init?(coder aDecoder: NSCoder) {
                guard let leftType: AssociatedType = aDecoder.decode(forKey: "leftType") else { 
                    withVaList(["leftType"]) { arguments in
                        NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                    }
                    fatalError()
                 }; self.leftType = leftType
                guard let rightType: GenericTypeParameter = aDecoder.decode(forKey: "rightType") else { 
                    withVaList(["rightType"]) { arguments in
                        NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                    }
                    fatalError()
                 }; self.rightType = rightType
                guard let relationship: String = aDecoder.decode(forKey: "relationship") else { 
                    withVaList(["relationship"]) { arguments in
                        NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                    }
                    fatalError()
                 }; self.relationship = relationship
                guard let relationshipSyntax: String = aDecoder.decode(forKey: "relationshipSyntax") else { 
                    withVaList(["relationshipSyntax"]) { arguments in
                        NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                    }
                    fatalError()
                 }; self.relationshipSyntax = relationshipSyntax
            }

            /// :nodoc:
            public func encode(with aCoder: NSCoder) {
                aCoder.encode(self.leftType, forKey: "leftType")
                aCoder.encode(self.rightType, forKey: "rightType")
                aCoder.encode(self.relationship, forKey: "relationship")
                aCoder.encode(self.relationshipSyntax, forKey: "relationshipSyntax")
            }
    // sourcery:end
}
#endif
