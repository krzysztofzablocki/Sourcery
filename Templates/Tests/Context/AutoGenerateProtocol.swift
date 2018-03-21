//
//  AutoGenerateProtocol.swift
//  TemplatesTests
//
//  Created by Stijn on 21/03/2018.
//  Copyright © 2018 Pixle. All rights reserved.
//

import Foundation

protocol AutoGenerateProtocol {}

struct AutoGenerate: AutoGenerateProtocol {

    var mutable: String
    let immutable: String

    // private variables will be ignored
    private let privateImmutable: String

    init(privateParam: String) {
        self.mutable = ""
        self.immutable = "immutable"
        self.privateImmutable = privateParam
    }

    // sourcery:includeInitInProtocol
    init() {
        self.init(privateParam: "convenience init")
    }

    func foo() {
        // nothing
    }

    // sourcery:skipProtocol
    func skippedFuntion() {

    }
}
