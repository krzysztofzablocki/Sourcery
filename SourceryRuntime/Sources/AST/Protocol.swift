//
//  Protocol.swift
//  Sourcery
//
//  Created by Krzysztof Zablocki on 09/12/2016.
//  Copyright © 2016 Pixle. All rights reserved.
//

import Foundation

/// :nodoc:
public typealias SourceryProtocol = Protocol

/// Describes Swift protocol
#if canImport(ObjectiveC)
@objcMembers
#endif
public final class Protocol: Type {

    /// Returns "protocol"
    public override var kind: String { return "protocol" }

    /// list of all declared associated types with their names as keys
    public var associatedTypes: [String: AssociatedType] {
        didSet {
            isGeneric = !associatedTypes.isEmpty || !genericRequirements.isEmpty
        }
    }

    /// list of generic requirements
    public var genericRequirements: [GenericRequirement] {
        didSet {
            isGeneric = !associatedTypes.isEmpty || !genericRequirements.isEmpty
        }
    }

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
                associatedTypes: [String: AssociatedType] = [:],
                genericRequirements: [GenericRequirement] = [],
                attributes: AttributeList = [:],
                modifiers: [SourceryModifier] = [],
                annotations: [String: NSObject] = [:],
                documentation: [String] = []) {
        self.genericRequirements = genericRequirements
        self.associatedTypes = associatedTypes
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
            attributes: attributes,
            modifiers: modifiers,
            annotations: annotations,
            documentation: documentation,
            isGeneric: !associatedTypes.isEmpty || !genericRequirements.isEmpty
        )
    }

    override public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? Protocol else {
            results.append("Incorrect type <expected: Protocol, received: \(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "associatedTypes").trackDifference(actual: self.associatedTypes, expected: castObject.associatedTypes))
        results.append(contentsOf: DiffableResult(identifier: "genericRequirements").trackDifference(actual: self.genericRequirements, expected: castObject.genericRequirements))
        results.append(contentsOf: super.diffAgainst(castObject))
        return results
    }

    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Protocol else { return false }
        if self.associatedTypes != rhs.associatedTypes { return false }
        if self.genericRequirements != rhs.genericRequirements { return false }
        return super.isEqual(rhs)
    }

// sourcery:inline:Protocol.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let associatedTypes: [String: AssociatedType] = aDecoder.decode(forKey: "associatedTypes") else { 
                withVaList(["associatedTypes"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.associatedTypes = associatedTypes
            guard let genericRequirements: [GenericRequirement] = aDecoder.decode(forKey: "genericRequirements") else { 
                withVaList(["genericRequirements"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.genericRequirements = genericRequirements
            super.init(coder: aDecoder)
        }

        /// :nodoc:
        override public func encode(with aCoder: NSCoder) {
            super.encode(with: aCoder)
            aCoder.encode(self.associatedTypes, forKey: "associatedTypes")
            aCoder.encode(self.genericRequirements, forKey: "genericRequirements")
        }
// sourcery:end
}
