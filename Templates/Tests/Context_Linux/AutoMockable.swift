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

protocol ImplicitlyUnwrappedOptionalReturnValueProtocol: AutoMockable {
  func implicitReturn() -> String!
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

protocol MultiClosureProtocol: AutoMockable {
    func setClosure(name: String, _ closure: @escaping () -> Void)
}

protocol NonEscapingClosureProtocol: AutoMockable {
    func executeClosure(_ closure: () -> Void)
}

protocol MultiNonEscapingClosureProtocol: AutoMockable {
    func executeClosure(name: String, _ closure: () -> Void)
}

/// sourcery: AutoMockable
protocol AnnotatedProtocol {
    func sayHelloWith(name: String)
}

protocol SingleOptionalParameterFunction: AutoMockable {
    func send(message: String?)
}

protocol FunctionWithClosureReturnType: AutoMockable {
    func get() -> () -> Void
    func getOptional() -> (() -> Void)?
}

protocol FunctionWithMultilineDeclaration: AutoMockable {
    func start(car: String,
               of model: String)
}

protocol ThrowingVariablesProtocol: AutoMockable {
    var title: String? { get throws }
    var firstName: String { get throws }
}

protocol AsyncVariablesProtocol: AutoMockable {
    var title: String? { get async }
    var firstName: String { get async }
}

protocol AsyncThrowingVariablesProtocol: AutoMockable {
    var title: String? { get async throws }
    var firstName: String { get async throws }
}

protocol AsyncProtocol: AutoMockable {
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func callAsync(parameter: Int) async -> String
    func callAsyncAndThrow(parameter: Int) async throws -> String
    func callAsyncVoid(parameter: Int) async -> Void
    func callAsyncAndThrowVoid(parameter: Int) async throws -> Void
}

protocol FunctionWithAttributes: AutoMockable {
    @discardableResult
    func callOneAttribute() -> String
    
    @discardableResult
    @available(macOS 10.15, *)
    func callTwoAttributes() -> Int
    
    @discardableResult
    @available(iOS 13.0, *)
    @available(macOS 10.15, *)
    func callRepeatedAttributes() -> Bool
}

public protocol AccessLevelProtocol: AutoMockable {
    var company: String? { get set }
    var name: String { get }
    
    func loadConfiguration() -> String?
}

protocol StaticMethodProtocol: AutoMockable {
    static func staticFunction(_: String) -> String
}

protocol StubProtocol {}
protocol StubWithAnyNameProtocol {}

protocol AnyProtocol: AutoMockable {
    var a: any StubProtocol { get }
    var b: (any StubProtocol)? { get }
    var c: (any StubProtocol)! { get }
    var d: (((any StubProtocol)?) -> Void) { get }
    var e: [(any StubProtocol)?] { get }
    func f(_ x: (any StubProtocol)?, y: (any StubProtocol)!, z: any StubProtocol)
    var g: any StubProtocol { get }
    var h: (any StubProtocol)? { get }
    var i: (any StubProtocol)! { get }
    func j(x: (any StubProtocol)?, y: (any StubProtocol)!, z: any StubProtocol) async -> String
    func k(x: ((any StubProtocol)?) -> Void, y: (any StubProtocol) -> Void)
    func l(x: (((any StubProtocol)?) -> Void), y: ((any StubProtocol) -> Void))
    var anyConfusingPropertyName: any StubProtocol { get }
    func m(anyConfusingArgumentName: any StubProtocol)
    func n(x: @escaping ((any StubProtocol)?) -> Void)
    var o: any StubWithAnyNameProtocol { get }
    func p(_ x: (any StubWithAnyNameProtocol)?)
    func q() -> any StubProtocol
    func r() -> (any StubProtocol)?
    func s() -> () -> any StubProtocol
    func t() -> () -> (any StubProtocol)?
    func u() -> (Int, () -> (any StubProtocol)?)
    func v() -> (Int, (() -> any StubProtocol)?)
    func w() -> [(any StubProtocol)?]
    func x() -> [String: (any StubProtocol)?]
    func y() -> (any StubProtocol, (any StubProtocol)?)
    func z() -> any StubProtocol & CustomStringConvertible
}

protocol StubWithSomeNameProtocol {}

protocol SomeProtocol: AutoMockable {
    func a(_ x: (some StubProtocol)?, y: (some StubProtocol)!, z: some StubProtocol)
    func b(x: (some StubProtocol)?, y: (some StubProtocol)!, z: some StubProtocol) async -> String
    func someConfusingFuncName(x: some StubProtocol)
    func c(someConfusingArgumentName: some StubProtocol)
    func d(_ x: (some StubWithSomeNameProtocol)?)
}

protocol PersonProtocol {}
class GenericType<A, B, C>{}

protocol HouseProtocol: AutoMockable {
    var aPublisher: AnyPublisher<any PersonProtocol, Never>? { get }
    var bPublisher: AnyPublisher<(any PersonProtocol)?, Never>? { get }
    var cPublisher: CurrentValueSubject<(any PersonProtocol)?, Never>? { get }
    var dPublisher: PassthroughSubject<(any PersonProtocol)?, Never>? { get }
    var e1Publisher: GenericType<(any PersonProtocol)?, Never, Never>? { get }
    var e2Publisher: GenericType<Never, (any PersonProtocol)?, Never>? { get }
    var e3Publisher: GenericType<Never, Never, (any PersonProtocol)?>? { get }
    var e4Publisher: GenericType<(any PersonProtocol)?, (any PersonProtocol)?, (any PersonProtocol)?>? { get }
    var f1Publisher: GenericType<any PersonProtocol, Never, Never>? { get }
    var f2Publisher: GenericType<Never, any PersonProtocol, Never>? { get }
    var f3Publisher: GenericType<Never, Never, any PersonProtocol>? { get }
    var f4Publisher: GenericType<any PersonProtocol, any PersonProtocol, any PersonProtocol>? { get }
}

// sourcery: AutoMockable
protocol ExampleVararg {
    func string(key: String, args: CVarArg...) -> String
}

// sourcery: AutoMockable
public protocol ProtocolWithOverrides {
    func doSomething(_ data: Int) -> [String]
    func doSomething(_ data: String) -> [String]
    func doSomething(_ data: String) -> [Int]
    func doSomething(_ data: String) -> ([Int], [String])
    func doSomething(_ data: String) throws -> ([Int], [Any])
    func doSomething(_ data: String) -> (([Int], [String]) -> Void)
    func doSomething(_ data: String) throws -> (([Int], [Any]) -> Void)
}

// sourcery: AutoMockable
protocol SubscriptProtocol {
    subscript(arg: Int) -> String { get set }
    subscript<T>(arg: T) -> Int { get }
    subscript<T>(arg: T) -> String { get async }
    subscript<T: Hashable>(arg: T) -> T? { get set }
    subscript<T>(arg: String) -> T? where T: Cancellable { get throws }
}
