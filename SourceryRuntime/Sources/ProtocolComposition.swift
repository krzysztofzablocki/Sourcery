// Created by eric_horacek on 2/12/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

import Foundation

// sourcery: skipJSExport
/// Describes a Swift [protocol composition](https://docs.swift.org/swift-book/ReferenceManual/Types.html#ID454).
@objcMembers public final class ProtocolComposition: Type {

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
                composedTypes: [Type]? = nil) {
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
            isGeneric: isGeneric
        )
    }

// sourcery:inline:ProtocolComposition.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let composedTypeNames: [TypeName] = aDecoder.decode(forKey: "composedTypeNames") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["composedTypeNames"])); fatalError() }; self.composedTypeNames = composedTypeNames
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
