import Foundation

// sourcery: skipDescription
/// Descibes Swift class
@objc(SwiftClass) public final class Class: Type {
    /// Returns "class"
    public override var kind: String { return "class" }

    /// :nodoc:
    public override init(name: String = "",
                  parent: Type? = nil,
                  accessLevel: AccessLevel = .internal,
                  isExtension: Bool = false,
                  variables: [Variable] = [],
                  methods: [Method] = [],
                  inheritedTypes: [String] = [],
                  containedTypes: [Type] = [],
                  typealiases: [Typealias] = [],
                  attributes: [String: Attribute] = [:],
                  annotations: [String: NSObject] = [:],
                  isGeneric: Bool = false) {
        super.init(
            name: name,
            parent: parent,
            accessLevel: accessLevel,
            isExtension: isExtension,
            variables: variables,
            methods: methods,
            inheritedTypes: inheritedTypes,
            containedTypes: containedTypes,
            typealiases: typealiases,
            annotations: annotations,
            isGeneric: isGeneric
        )
    }

    // sourcery:inline:Class.AutoCoding
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
