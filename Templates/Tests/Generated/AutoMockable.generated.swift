// Generated using Sourcery 0.6.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable line_length

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

    var saveCalled = false
    var saveReceivedConfiguration: String?

    func save(configuration: String) {
        saveCalled = true
        saveReceivedConfiguration = configuration
    }
}
class InitializationProtocolMock: InitializationProtocol {

    //MARK: - init

    var initReceivedArguments: (intParameter: Int, stringParameter: String, optionalParameter: String?)?

    required init(intParameter: Int, stringParameter: String, optionalParameter: String?) {
        initReceivedArguments = (intParameter: intParameter, stringParameter: stringParameter, optionalParameter: optionalParameter)
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
class VariablesProtocolMock: VariablesProtocol {
    var company: String?
    var name: String!
    var age: Int!
    var kids: [String] = []
    var universityMarks: [String: Int] = [:]

}
