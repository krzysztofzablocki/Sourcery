//
//  Protocol.swift
//  Sourcery
//
//  Created by Krzysztof Zablocki on 09/12/2016.
//  Copyright © 2016 Pixle. All rights reserved.
//

import Foundation

/// Describes Swift protocol
public final class Protocol: Type {

    /// Returns "protocol"
    public override var kind: String { return "protocol" }

    override init(name: String = "",
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

    override func extend(_ type: Type) {
        type.variables = type.variables.filter({ v in !variables.contains(where: { $0.name == v.name && $0.isStatic == v.isStatic }) })
        type.methods = type.methods.filter({ !methods.contains($0) })
        super.extend(type)
    }

    // sourcery:inline:Protocol.AutoCoding
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
