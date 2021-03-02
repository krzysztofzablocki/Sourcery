import Foundation

/// modifier can be thing like `private`, `class`, `nonmutating`
/// if a declaration has modifier like `private(set)` it's name will be `private` and detail will be `set`
@objcMembers public class GenericRequirement: NSObject, SourceryModel {

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

    // sourcery:inline:GenericRequirement.AutoCoding

            /// :nodoc:
            required public init?(coder aDecoder: NSCoder) {
                guard let leftType: AssociatedType = aDecoder.decode(forKey: "leftType") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["leftType"])); fatalError() }; self.leftType = leftType
                guard let rightType: GenericTypeParameter = aDecoder.decode(forKey: "rightType") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["rightType"])); fatalError() }; self.rightType = rightType
                guard let relationship: String = aDecoder.decode(forKey: "relationship") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["relationship"])); fatalError() }; self.relationship = relationship
                guard let relationshipSyntax: String = aDecoder.decode(forKey: "relationshipSyntax") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["relationshipSyntax"])); fatalError() }; self.relationshipSyntax = relationshipSyntax
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
