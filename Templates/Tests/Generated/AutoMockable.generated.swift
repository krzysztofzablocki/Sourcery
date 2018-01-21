// Generated using Sourcery 0.10.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable line_length
// swiftlint:disable variable_name

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif














class BasicProtocolMock: BasicProtocol {

    //MARK: - loadConfiguration

    var loadConfigurationCallsCount = 0
    var loadConfigurationCalled: Bool {
        return loadConfigurationCallsCount > 0
    }
    var loadConfigurationReturnValue: String?!

    func loadConfiguration() -> String? {
        loadConfigurationCallsCount += 1
        return loadConfigurationReturnValue
    }

    //MARK: - save

    var saveConfigurationCallsCount = 0
    var saveConfigurationCalled: Bool {
        return saveConfigurationCallsCount > 0
    }
    var saveConfigurationReceivedConfiguration: String?

    func save(configuration: String) {
        saveConfigurationCallsCount += 1
        saveConfigurationReceivedConfiguration = configuration
    }

}
class ClosureProtocolMock: ClosureProtocol {

    //MARK: - setClosure

    var setClosureCallsCount = 0
    var setClosureCalled: Bool {
        return setClosureCallsCount > 0
    }
    var setClosureReceivedClosure: (() -> Void)?

    func setClosure(_ closure: @escaping () -> Void) {
        setClosureCallsCount += 1
        setClosureReceivedClosure = closure
    }

}
class CurrencyPresenterMock: CurrencyPresenter {

    //MARK: - showSourceCurrency

    var showSourceCurrencyCallsCount = 0
    var showSourceCurrencyCalled: Bool {
        return showSourceCurrencyCallsCount > 0
    }
    var showSourceCurrencyReceivedCurrency: String?

    func showSourceCurrency(_ currency: String) {
        showSourceCurrencyCallsCount += 1
        showSourceCurrencyReceivedCurrency = currency
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

    func report(message: String) {
        reportMessageCallsCount += 1
        reportMessageReceivedMessage = message
    }

    //MARK: - extension_report

    var extensionReportMessageCallsCount = 0
    var extensionReportMessageCalled: Bool {
        return extensionReportMessageCallsCount > 0
    }
    var extensionReportMessageReceivedMessage: String?

    func report(message: String = "Test") {
        extensionReportMessageCallsCount += 1
        extensionReportMessageReceivedMessage = message
    }

}
class InitializationProtocolMock: InitializationProtocol {

    //MARK: - init

    var initIntParameterStringParameterOptionalParameterReceivedArguments: (intParameter: Int, stringParameter: String, optionalParameter: String?)?

    required init(intParameter: Int, stringParameter: String, optionalParameter: String?) {
        initIntParameterStringParameterOptionalParameterReceivedArguments = (intParameter: intParameter, stringParameter: stringParameter, optionalParameter: optionalParameter)
    }
    //MARK: - start

    var startCallsCount = 0
    var startCalled: Bool {
        return startCallsCount > 0
    }

    func start() {
        startCallsCount += 1
    }

    //MARK: - stop

    var stopCallsCount = 0
    var stopCalled: Bool {
        return stopCallsCount > 0
    }

    func stop() {
        stopCallsCount += 1
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

    func `continue`(with message: String) -> String {
        continueWithCallsCount += 1
        continueWithReceivedMessage = message
        return continueWithReturnValue
    }

}
class SameShortMethodNamesProtocolMock: SameShortMethodNamesProtocol {

    //MARK: - start

    var startCarOfCallsCount = 0
    var startCarOfCalled: Bool {
        return startCarOfCallsCount > 0
    }
    var startCarOfReceivedArguments: (car: String, model: String)?

    func start(car: String, of model: String) {
        startCarOfCallsCount += 1
        startCarOfReceivedArguments = (car: car, model: model)
    }

    //MARK: - start

    var startPlaneOfCallsCount = 0
    var startPlaneOfCalled: Bool {
        return startPlaneOfCallsCount > 0
    }
    var startPlaneOfReceivedArguments: (plane: String, model: String)?

    func start(plane: String, of model: String) {
        startPlaneOfCallsCount += 1
        startPlaneOfReceivedArguments = (plane: plane, model: model)
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

    func doOrThrow() throws -> String {
        if let error = doOrThrowThrowableError {
            throw error
        }
        doOrThrowCallsCount += 1
        return doOrThrowReturnValue
    }

    //MARK: - doOrThrowVoid

    var doOrThrowVoidThrowableError: Error?
    var doOrThrowVoidCallsCount = 0
    var doOrThrowVoidCalled: Bool {
        return doOrThrowVoidCallsCount > 0
    }

    func doOrThrowVoid() throws {
        if let error = doOrThrowVoidThrowableError {
            throw error
        }
        doOrThrowVoidCallsCount += 1
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
