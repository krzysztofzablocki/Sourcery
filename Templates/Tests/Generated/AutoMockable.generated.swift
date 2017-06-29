// Generated using Sourcery 0.7.2 — https://github.com/krzysztofzablocki/Sourcery
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

    var saveconfigurationCalled = false
    var saveconfigurationReceivedConfiguration: String?

    func save(configuration: String) {
        saveconfigurationCalled = true
        saveconfigurationReceivedConfiguration = configuration
    }
}
class InitializationProtocolMock: InitializationProtocol {

    //MARK: - init

    var initintParameterstringParameteroptionalParameterReceivedArguments: (intParameter: Int, stringParameter: String, optionalParameter: String?)?

    required init(intParameter: Int, stringParameter: String, optionalParameter: String?) {
        initintParameterstringParameteroptionalParameterReceivedArguments = (intParameter: intParameter, stringParameter: stringParameter, optionalParameter: optionalParameter)
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
class SameShortMethodNamesProtocolMock: SameShortMethodNamesProtocol {

    //MARK: - start

    var startcarofCalled = false
    var startcarofReceivedArguments: (car: String, model: String)?

    func start(car: String, of model: String) {
        startcarofCalled = true
        startcarofReceivedArguments = (car: car, model: model)
    }
    //MARK: - start

    var startplaneofCalled = false
    var startplaneofReceivedArguments: (plane: String, model: String)?

    func start(plane: String, of model: String) {
        startplaneofCalled = true
        startplaneofReceivedArguments = (plane: plane, model: model)
    }
}
class VariablesProtocolMock: VariablesProtocol {
    var company: String?
    var name: String!
    var age: Int!
    var kids: [String] = []
    var universityMarks: [String: Int] = [:]

}
