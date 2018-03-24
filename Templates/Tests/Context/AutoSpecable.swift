//
//  File.swift
//  TemplatesTests
//
//  Created by Stijn on 22/03/2018.
//  Copyright © 2018 Pixle. All rights reserved.
//

import Foundation

protocol AutoSpecable { }

protocol ServiceProtocol: AutoMockable {
    func fetch()
}

struct BusService: AutoSpecable {
    // sourcery: testValue = ""Johny safely""
    // sourcery: customMock = ""Johny safely""
    let name: String

    private let service: ServiceProtocol

    init(name: String, service: ServiceProtocol) {
        self.name = name
        self.service = service
    }
}
