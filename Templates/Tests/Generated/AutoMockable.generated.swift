// Generated using Sourcery 0.13.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable line_length
// swiftlint:disable variable_name

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif













class AnnotatedProtocolMock: AnnotatedProtocol {

    //MARK: - sayHelloWith

    var sayHelloWithNameCallsCount = 0
    var sayHelloWithNameCalled: Bool {
        return sayHelloWithNameCallsCount > 0
    }
    var sayHelloWithNameReceivedName: String?
    var sayHelloWithNameClosure: ((String) -> Void)?

    func sayHelloWith(name: String) {
        sayHelloWithNameCallsCount += 1
        sayHelloWithNameReceivedName = name
        sayHelloWithNameClosure?(name)
    }

}
class BasicProtocolMock: BasicProtocol {

    //MARK: - loadConfiguration

    var loadConfigurationCallsCount = 0
    var loadConfigurationCalled: Bool {
        return loadConfigurationCallsCount > 0
    }
    var loadConfigurationReturnValue: String?
    var loadConfigurationClosure: (() -> String?)?

    func loadConfiguration() -> String? {
        loadConfigurationCallsCount += 1
        return loadConfigurationClosure.map({ $0() }) ?? loadConfigurationReturnValue
    }

    //MARK: - save

    var saveConfigurationCallsCount = 0
    var saveConfigurationCalled: Bool {
        return saveConfigurationCallsCount > 0
    }
    var saveConfigurationReceivedConfiguration: String?
    var saveConfigurationClosure: ((String) -> Void)?

    func save(configuration: String) {
        saveConfigurationCallsCount += 1
        saveConfigurationReceivedConfiguration = configuration
        saveConfigurationClosure?(configuration)
    }

}
class ClosureProtocolMock: ClosureProtocol {

    //MARK: - setClosure

    var setClosureCallsCount = 0
    var setClosureCalled: Bool {
        return setClosureCallsCount > 0
    }
    var setClosureReceivedClosure: (() -> Void)?
    var setClosureClosure: ((@escaping () -> Void) -> Void)?

    func setClosure(_ closure: @escaping () -> Void) {
        setClosureCallsCount += 1
        setClosureReceivedClosure = closure
        setClosureClosure?(closure)
    }

}
class CurrencyPresenterMock: CurrencyPresenter {

    //MARK: - showSourceCurrency

    var showSourceCurrencyCallsCount = 0
    var showSourceCurrencyCalled: Bool {
        return showSourceCurrencyCallsCount > 0
    }
    var showSourceCurrencyReceivedCurrency: String?
    var showSourceCurrencyClosure: ((String) -> Void)?

    func showSourceCurrency(_ currency: String) {
        showSourceCurrencyCallsCount += 1
        showSourceCurrencyReceivedCurrency = currency
        showSourceCurrencyClosure?(currency)
    }

}
class ExtendableProtocolMock: ExtendableProtocol {
    var canReport: Bool {
        get { return underlyingCanReport }
        set(value) { underlyingCanReport = value }
    }
    var underlyingCanReport: Bool!

    //MARK: - report

    var reportMessageCallsCount = 0
    var reportMessageCalled: Bool {
        return reportMessageCallsCount > 0
    }
    var reportMessageReceivedMessage: String?
    var reportMessageClosure: ((String) -> Void)?

    func report(message: String) {
        reportMessageCallsCount += 1
        reportMessageReceivedMessage = message
        reportMessageClosure?(message)
    }

}
class InitializationProtocolMock: InitializationProtocol {

    //MARK: - init

    var initIntParameterStringParameterOptionalParameterReceivedArguments: (intParameter: Int, stringParameter: String, optionalParameter: String?)?
    var initIntParameterStringParameterOptionalParameterClosure: ((Int, String, String?) -> Void)?

    required init(intParameter: Int, stringParameter: String, optionalParameter: String?) {
        initIntParameterStringParameterOptionalParameterReceivedArguments = (intParameter: intParameter, stringParameter: stringParameter, optionalParameter: optionalParameter)
        initIntParameterStringParameterOptionalParameterClosure?(intParameter, stringParameter, optionalParameter)
    }
    //MARK: - start

    var startCallsCount = 0
    var startCalled: Bool {
        return startCallsCount > 0
    }
    var startClosure: (() -> Void)?

    func start() {
        startCallsCount += 1
        startClosure?()
    }

    //MARK: - stop

    var stopCallsCount = 0
    var stopCalled: Bool {
        return stopCallsCount > 0
    }
    var stopClosure: (() -> Void)?

    func stop() {
        stopCallsCount += 1
        stopClosure?()
    }

}
class ReservedWordsProtocolMock: ReservedWordsProtocol {

    //MARK: - `continue`

    var continueWithCallsCount = 0
    var continueWithCalled: Bool {
        return continueWithCallsCount > 0
    }
    var continueWithReceivedMessage: String?
    var continueWithReturnValue: String!
    var continueWithClosure: ((String) -> String)?

    func `continue`(with message: String) -> String {
        continueWithCallsCount += 1
        continueWithReceivedMessage = message
        return continueWithClosure.map({ $0(message) }) ?? continueWithReturnValue
    }

}
class SameShortMethodNamesProtocolMock: SameShortMethodNamesProtocol {

    //MARK: - start

    var startCarOfCallsCount = 0
    var startCarOfCalled: Bool {
        return startCarOfCallsCount > 0
    }
    var startCarOfReceivedArguments: (car: String, model: String)?
    var startCarOfClosure: ((String, String) -> Void)?

    func start(car: String, of model: String) {
        startCarOfCallsCount += 1
        startCarOfReceivedArguments = (car: car, model: model)
        startCarOfClosure?(car, model)
    }

    //MARK: - start

    var startPlaneOfCallsCount = 0
    var startPlaneOfCalled: Bool {
        return startPlaneOfCallsCount > 0
    }
    var startPlaneOfReceivedArguments: (plane: String, model: String)?
    var startPlaneOfClosure: ((String, String) -> Void)?

    func start(plane: String, of model: String) {
        startPlaneOfCallsCount += 1
        startPlaneOfReceivedArguments = (plane: plane, model: model)
        startPlaneOfClosure?(plane, model)
    }

}
class ThrowableProtocolMock: ThrowableProtocol {

    //MARK: - doOrThrow

    var doOrThrowThrowableError: Error?
    var doOrThrowCallsCount = 0
    var doOrThrowCalled: Bool {
        return doOrThrowCallsCount > 0
    }
    var doOrThrowReturnValue: String!
    var doOrThrowClosure: (() throws -> String)?

    func doOrThrow() throws -> String {
        if let error = doOrThrowThrowableError {
            throw error
        }
        doOrThrowCallsCount += 1
        return try doOrThrowClosure.map({ try $0() }) ?? doOrThrowReturnValue
    }

    //MARK: - doOrThrowVoid

    var doOrThrowVoidThrowableError: Error?
    var doOrThrowVoidCallsCount = 0
    var doOrThrowVoidCalled: Bool {
        return doOrThrowVoidCallsCount > 0
    }
    var doOrThrowVoidClosure: (() throws -> Void)?

    func doOrThrowVoid() throws {
        if let error = doOrThrowVoidThrowableError {
            throw error
        }
        doOrThrowVoidCallsCount += 1
        try doOrThrowVoidClosure?()
    }

}
class VariablesProtocolMock: VariablesProtocol {
    var company: String?
    var name: String {
        get { return underlyingName }
        set(value) { underlyingName = value }
    }
    var underlyingName: String!
    var age: Int {
        get { return underlyingAge }
        set(value) { underlyingAge = value }
    }
    var underlyingAge: Int!
    var kids: [String] = []
    var universityMarks: [String: Int] = [:]

}
