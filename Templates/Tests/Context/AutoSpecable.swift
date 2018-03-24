//
//  File.swift
//  TemplatesTests
//
//  Created by Stijn on 22/03/2018.
//  Copyright © 2018 Pixle. All rights reserved.
//

import Foundation

protocol AutoSpecable { }

struct BusService: AutoSpecable {
    // sourcery: testValue = ""Johny safely""
    // sourcery: customMock = ""Johny safely""
    let name: String

    init(name: String) {
        self.name = name
    }
}
