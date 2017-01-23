//
//  Struct.swift
//  Sourcery
//
//  Created by Krzysztof Zablocki on 13/09/2016.
//  Copyright © 2016 Pixle. All rights reserved.
//

import Foundation

/// sourcery: skipDescription
final class Struct: Type {
    override var kind: String { return "struct" }

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

    // Struct.NSCoding {
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }

        override func encode(with aCoder: NSCoder) {
            super.encode(with: aCoder)

        }
        // } Struct.NSCoding
}
