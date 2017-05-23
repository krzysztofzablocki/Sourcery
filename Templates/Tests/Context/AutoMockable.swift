//
//  AutoMockable.swift
//  Templates
//
//  Created by Anton Domashnev on 17.05.17.
//  Copyright © 2017 Pixle. All rights reserved.
//

import Foundation

protocol AutoMockable {}

protocol BasicProtocol: AutoMockable {
    func loadConfiguration() -> String?
    func save(configuration: String)
}

protocol InitializationProtocol: AutoMockable {
    init(intParameter: Int, stringParameter: String, optionalParameter: String?)
    func start()
    func stop()
}

protocol VariablesProtocol: AutoMockable {
    var company: String? { get set }
    var name: String { get }
    var age: Int { get }
    var kids: [String] { get }
    var universityMarks: [String: Int] { get }
}
