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
    /// Asks a Duck to quack
    ///
    /// - Parameter times: How many times the Duck will quack
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

protocol SameShortMethodNamesProtocol: AutoMockable {
    func start(car: String, of model: String)
    func start(plane: String, of model: String)
}

protocol ExtendableProtocol: AutoMockable {
    var canReport: Bool { get }
    func report(message: String)
}

protocol ReservedWordsProtocol: AutoMockable {
    func `continue`(with message: String) -> String
}

protocol ThrowableProtocol: AutoMockable {
    func doOrThrow() throws -> String
    func doOrThrowVoid() throws
}

protocol CurrencyPresenter: AutoMockable {
    func showSourceCurrency(_ currency: String)
}

extension ExtendableProtocol {
    var canReport: Bool { return true }

    func report(message: String = "Test") {
        print(message)
    }
}

protocol ClosureProtocol: AutoMockable {
    func setClosure(_ closure: @escaping () -> Void)
}

/// sourcery: AutoMockable
protocol AnnotatedProtocol {
    func sayHelloWith(name: String)
}
