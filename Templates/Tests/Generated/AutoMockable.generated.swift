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

    var loadConfiguration_Called = false
    var loadConfiguration_ReturnValue: String?!

    func loadConfiguration() -> String? {
        loadConfiguration_Called = true
        return loadConfiguration_ReturnValue
    }

    //MARK: - save

    var save_configuration_Called = false
    var save_configuration_ReceivedConfiguration: String?

    func save(configuration: String) {
        save_configuration_Called = true
        save_configuration_ReceivedConfiguration = configuration
    }

}
class ExtendableProtocolMock: ExtendableProtocol {
    var canReport: Bool!

    //MARK: - report

    var report_message_Called = false
    var report_message_ReceivedMessage: String?

    func report(message: String) {
        report_message_Called = true
        report_message_ReceivedMessage = message
    }

    //MARK: - extension_report

    var extension_report_message_Called = false
    var extension_report_message_ReceivedMessage: String?

    func report(message: String = "Test") {
        extension_report_message_Called = true
        extension_report_message_ReceivedMessage = message
    }

}
class InitializationProtocolMock: InitializationProtocol {

    //MARK: - init

    var init_intParameter_stringParameter_optionalParameter_ReceivedArguments: (intParameter: Int, stringParameter: String, optionalParameter: String?)?

    required init(intParameter: Int, stringParameter: String, optionalParameter: String?) {
        init_intParameter_stringParameter_optionalParameter_ReceivedArguments = (intParameter: intParameter, stringParameter: stringParameter, optionalParameter: optionalParameter)
    }
    //MARK: - start

    var start_Called = false

    func start() {
        start_Called = true
    }

    //MARK: - stop

    var stop_Called = false

    func stop() {
        stop_Called = true
    }

}
class SameShortMethodNamesProtocolMock: SameShortMethodNamesProtocol {

    //MARK: - start

    var start_car_of_Called = false
    var start_car_of_ReceivedArguments: (car: String, model: String)?

    func start(car: String, of model: String) {
        start_car_of_Called = true
        start_car_of_ReceivedArguments = (car: car, model: model)
    }

    //MARK: - start

    var start_plane_of_Called = false
    var start_plane_of_ReceivedArguments: (plane: String, model: String)?

    func start(plane: String, of model: String) {
        start_plane_of_Called = true
        start_plane_of_ReceivedArguments = (plane: plane, model: model)
    }

}
class VariablesProtocolMock: VariablesProtocol {
    var company: String?
    var name: String!
    var age: Int!
    var kids: [String] = []
    var universityMarks: [String: Int] = [:]

}
