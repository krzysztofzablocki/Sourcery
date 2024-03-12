import Foundation

// sourcery: skipDescription
/// Descibes Swift actor
#if canImport(ObjectiveC)
@objc(SwiftActor) @objcMembers
#endif
public final class Actor: Type {
    /// Returns "actor"
    public override var kind: String { return "actor" }

    /// Whether type is final
    public var isFinal: Bool {
        modifiers.contains { $0.name == "final" }
    }

    /// :nodoc:
    public override init(name: String = "",
                         parent: Type? = nil,
                         accessLevel: AccessLevel = .internal,
                         isExtension: Bool = false,
                         variables: [Variable] = [],
                         methods: [Method] = [],
                         subscripts: [Subscript] = [],
                         inheritedTypes: [String] = [],
                         containedTypes: [Type] = [],
                         typealiases: [Typealias] = [],
                         genericRequirements: [GenericRequirement] = [],
                         attributes: AttributeList = [:],
                         modifiers: [SourceryModifier] = [],
                         annotations: [String: NSObject] = [:],
                         documentation: [String] = [],
                         isGeneric: Bool = false,
                         implements: [String: Type] = [:]) {
        super.init(
            name: name,
            parent: parent,
            accessLevel: accessLevel,
            isExtension: isExtension,
            variables: variables,
            methods: methods,
            subscripts: subscripts,
            inheritedTypes: inheritedTypes,
            containedTypes: containedTypes,
            typealiases: typealiases,
            genericRequirements: genericRequirements,
            attributes: attributes,
            modifiers: modifiers,
            annotations: annotations,
            documentation: documentation,
            isGeneric: isGeneric,
            implements: implements
        )
    }

    /// :nodoc:
    // sourcery: skipJSExport
    override public var description: String {
        var string = super.description
        string.append(", ")
        string.append("kind = \(String(describing: self.kind)), ")
        string.append("isFinal = \(String(describing: self.isFinal))")
        return string
    }

    override public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? Actor else {
            results.append("Incorrect type <expected: Actor, received: \(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: super.diffAgainst(castObject))
        return results
    }

    /// :nodoc:
    // sourcery: skipJSExport
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(super.hash)
        return hasher.finalize()
    }

    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Actor else { return false }
        return super.isEqual(rhs)
    }

// sourcery:inline:Actor.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }

        /// :nodoc:
        override public func encode(with aCoder: NSCoder) {
            super.encode(with: aCoder)
        }
// sourcery:end
    
}
