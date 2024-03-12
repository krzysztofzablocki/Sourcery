// Created by eric_horacek on 2/12/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import Foundation

/// Describes a Swift [protocol composition](https://docs.swift.org/swift-book/ReferenceManual/Types.html#ID454).
#if canImport(ObjectiveC)
@objcMembers
#endif
public final class ProtocolComposition: Type {

    /// Returns "protocolComposition"
    public override var kind: String { return "protocolComposition" }

    /// The names of the types composed to form this composition
    public let composedTypeNames: [TypeName]

    // sourcery: skipEquality, skipDescription
    /// The types composed to form this composition, if known
    public var composedTypes: [Type]?

    /// :nodoc:
    public init(name: String = "",
                parent: Type? = nil,
                accessLevel: AccessLevel = .internal,
                isExtension: Bool = false,
                variables: [Variable] = [],
                methods: [Method] = [],
                subscripts: [Subscript] = [],
                inheritedTypes: [String] = [],
                containedTypes: [Type] = [],
                typealiases: [Typealias] = [],
                attributes: AttributeList = [:],
                annotations: [String: NSObject] = [:],
                isGeneric: Bool = false,
                composedTypeNames: [TypeName] = [],
                composedTypes: [Type]? = nil,
                implements: [String: Type] = [:]) {
        self.composedTypeNames = composedTypeNames
        self.composedTypes = composedTypes
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
            annotations: annotations,
            isGeneric: isGeneric,
            implements: implements
        )
    }

    /// :nodoc:
    // sourcery: skipJSExport
    override public var description: String {
        var string = super.description
        string += ", "
        string += "kind = \(String(describing: self.kind)), "
        string += "composedTypeNames = \(String(describing: self.composedTypeNames))"
        return string
    }

    override public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? ProtocolComposition else {
            results.append("Incorrect type <expected: ProtocolComposition, received: \(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "composedTypeNames").trackDifference(actual: self.composedTypeNames, expected: castObject.composedTypeNames))
        results.append(contentsOf: super.diffAgainst(castObject))
        return results
    }

    /// :nodoc:
    // sourcery: skipJSExport
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.composedTypeNames)
        hasher.combine(super.hash)
        return hasher.finalize()
    }

    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? ProtocolComposition else { return false }
        if self.composedTypeNames != rhs.composedTypeNames { return false }
        return super.isEqual(rhs)
    }

// sourcery:inline:ProtocolComposition.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let composedTypeNames: [TypeName] = aDecoder.decode(forKey: "composedTypeNames") else { 
                withVaList(["composedTypeNames"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.composedTypeNames = composedTypeNames
            self.composedTypes = aDecoder.decode(forKey: "composedTypes")
            super.init(coder: aDecoder)
        }

        /// :nodoc:
        override public func encode(with aCoder: NSCoder) {
            super.encode(with: aCoder)
            aCoder.encode(self.composedTypeNames, forKey: "composedTypeNames")
            aCoder.encode(self.composedTypes, forKey: "composedTypes")
        }
// sourcery:end

}
