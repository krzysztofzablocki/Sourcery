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
@objcMembers public final class Protocol: Type {

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

// sourcery:inline:Protocol.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let associatedTypes: [String: AssociatedType] = aDecoder.decode(forKey: "associatedTypes") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["associatedTypes"])); fatalError() }; self.associatedTypes = associatedTypes
            guard let genericRequirements: [GenericRequirement] = aDecoder.decode(forKey: "genericRequirements") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["genericRequirements"])); fatalError() }; self.genericRequirements = genericRequirements
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
