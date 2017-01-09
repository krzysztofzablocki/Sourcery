//
//  Protocol.swift
//  Sourcery
//
//  Created by Krzysztof Zablocki on 09/12/2016.
//  Copyright © 2016 Pixle. All rights reserved.
//

import Foundation

/// sourcery: skipDescription
final class Protocol: Type {
    override var kind: String { return "protocol" }

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

    // Protocol.NSCoding {
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }

        override func encode(with aCoder: NSCoder) {
            super.encode(with: aCoder)

        }
        // } Protocol.NSCoding
}
