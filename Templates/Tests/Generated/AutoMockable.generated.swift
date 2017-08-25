// Generated using Sourcery 0.8.0 — https://github.com/krzysztofzablocki/Sourcery
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

    var loadConfigurationCalled = false
    var loadConfigurationReturnValue: String?!

    func loadConfiguration() -> String? {
        loadConfigurationCalled = true
        return loadConfigurationReturnValue
    }

    //MARK: - save

    var saveConfigurationCalled = false
    var saveConfigurationReceivedConfiguration: String?

    func save(configuration: String) {
        saveConfigurationCalled = true
        saveConfigurationReceivedConfiguration = configuration
    }

}
class CurrencyPresenterMock: CurrencyPresenter {

    //MARK: - showSourceCurrency

    var showSourceCurrencyCalled = false
    var showSourceCurrencyReceivedCurrency: String?

    func showSourceCurrency(_ currency: String) {
        showSourceCurrencyCalled = true
        showSourceCurrencyReceivedCurrency = currency
    }

}
class ExtendableProtocolMock: ExtendableProtocol {
    var canReport: Bool!

    //MARK: - report

    var reportMessageCalled = false
    var reportMessageReceivedMessage: String?

    func report(message: String) {
        reportMessageCalled = true
        reportMessageReceivedMessage = message
    }

    //MARK: - extension_report

    var extensionReportMessageCalled = false
    var extensionReportMessageReceivedMessage: String?

    func report(message: String = "Test") {
        extensionReportMessageCalled = true
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

    var startCalled = false

    func start() {
        startCalled = true
    }

    //MARK: - stop

    var stopCalled = false

    func stop() {
        stopCalled = true
    }

}
class ReservedWordsProtocolMock: ReservedWordsProtocol {

    //MARK: - `continue`

    var continue_with_Called = false
    var continue_with_ReceivedMessage: String?
    var continue_with_ReturnValue: String!

    func `continue`(with message: String) -> String {
        continue_with_Called = true
        continue_with_ReceivedMessage = message
        return continue_with_ReturnValue
    }

}
class SameShortMethodNamesProtocolMock: SameShortMethodNamesProtocol {

    //MARK: - start

    var startCarOfCalled = false
    var startCarOfReceivedArguments: (car: String, model: String)?

    func start(car: String, of model: String) {
        startCarOfCalled = true
        startCarOfReceivedArguments = (car: car, model: model)
    }

    //MARK: - start

    var startPlaneOfCalled = false
    var startPlaneOfReceivedArguments: (plane: String, model: String)?

    func start(plane: String, of model: String) {
        startPlaneOfCalled = true
        startPlaneOfReceivedArguments = (plane: plane, model: model)
    }

}
class ThrowableProtocolMock: ThrowableProtocol {

    //MARK: - doOrThrow

    var doOrThrow_ThrowableError: Error?
    var doOrThrow_Called = false
    var doOrThrow_ReturnValue: String!

    func doOrThrow() throws -> String {
        if let error = doOrThrow_ThrowableError {
            throw error
        }
        doOrThrow_Called = true
        return doOrThrow_ReturnValue
    }

}
class VariablesProtocolMock: VariablesProtocol {
    var company: String?
    var name: String!
    var age: Int!
    var kids: [String] = []
    var universityMarks: [String: Int] = [:]

}
