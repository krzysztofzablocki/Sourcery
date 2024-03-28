// Generated using Sourcery 2.1.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable line_length
// swiftlint:disable variable_name

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif
























public class AccessLevelProtocolMock: AccessLevelProtocol {

    public init() {}

    public var company: String?
    public var name: String {
        get { return underlyingName }
        set(value) { underlyingName = value }
    }
    public var underlyingName: (String)!


    //MARK: - loadConfiguration

    public var loadConfigurationStringCallsCount = 0
    public var loadConfigurationStringCalled: Bool {
        return loadConfigurationStringCallsCount > 0
    }
    public var loadConfigurationStringReturnValue: String?
    public var loadConfigurationStringClosure: (() -> String?)?

    public func loadConfiguration() -> String? {
        loadConfigurationStringCallsCount += 1
        if let loadConfigurationStringClosure = loadConfigurationStringClosure {
            return loadConfigurationStringClosure()
        } else {
            return loadConfigurationStringReturnValue
        }
    }


}
class AnnotatedProtocolMock: AnnotatedProtocol {




    //MARK: - sayHelloWith

    var sayHelloWithNameStringVoidCallsCount = 0
    var sayHelloWithNameStringVoidCalled: Bool {
        return sayHelloWithNameStringVoidCallsCount > 0
    }
    var sayHelloWithNameStringVoidReceivedName: (String)?
    var sayHelloWithNameStringVoidReceivedInvocations: [(String)] = []
    var sayHelloWithNameStringVoidClosure: ((String) -> Void)?

    func sayHelloWith(name: String) {
        sayHelloWithNameStringVoidCallsCount += 1
        sayHelloWithNameStringVoidReceivedName = name
        sayHelloWithNameStringVoidReceivedInvocations.append(name)
        sayHelloWithNameStringVoidClosure?(name)
    }


}
class AnyProtocolMock: AnyProtocol {


    var a: any StubProtocol {
        get { return underlyingA }
        set(value) { underlyingA = value }
    }
    var underlyingA: (any StubProtocol)!
    var b: (any StubProtocol)?
    var c: (any StubProtocol)!
    var d: (((any StubProtocol)?) -> Void) {
        get { return underlyingD }
        set(value) { underlyingD = value }
    }
    var underlyingD: ((((any StubProtocol)?) -> Void))!
    var e: [(any StubProtocol)?] = []
    var g: any StubProtocol {
        get { return underlyingG }
        set(value) { underlyingG = value }
    }
    var underlyingG: (any StubProtocol)!
    var h: (any StubProtocol)?
    var i: (any StubProtocol)!
    var anyConfusingPropertyName: any StubProtocol {
        get { return underlyingAnyConfusingPropertyName }
        set(value) { underlyingAnyConfusingPropertyName = value }
    }
    var underlyingAnyConfusingPropertyName: (any StubProtocol)!
    var o: any StubWithAnyNameProtocol {
        get { return underlyingO }
        set(value) { underlyingO = value }
    }
    var underlyingO: (any StubWithAnyNameProtocol)!


    //MARK: - f

    var fXAnyStubProtocolYAnyStubProtocolZAnyStubProtocolVoidCallsCount = 0
    var fXAnyStubProtocolYAnyStubProtocolZAnyStubProtocolVoidCalled: Bool {
        return fXAnyStubProtocolYAnyStubProtocolZAnyStubProtocolVoidCallsCount > 0
    }
    var fXAnyStubProtocolYAnyStubProtocolZAnyStubProtocolVoidReceivedArguments: (x: (any StubProtocol)?, y: (any StubProtocol)?, z: any StubProtocol)?
    var fXAnyStubProtocolYAnyStubProtocolZAnyStubProtocolVoidReceivedInvocations: [(x: (any StubProtocol)?, y: (any StubProtocol)?, z: any StubProtocol)] = []
    var fXAnyStubProtocolYAnyStubProtocolZAnyStubProtocolVoidClosure: (((any StubProtocol)?, (any StubProtocol)?, any StubProtocol) -> Void)?

    func f(_ x: (any StubProtocol)?, y: (any StubProtocol)!, z: any StubProtocol) {
        fXAnyStubProtocolYAnyStubProtocolZAnyStubProtocolVoidCallsCount += 1
        fXAnyStubProtocolYAnyStubProtocolZAnyStubProtocolVoidReceivedArguments = (x: x, y: y, z: z)
        fXAnyStubProtocolYAnyStubProtocolZAnyStubProtocolVoidReceivedInvocations.append((x: x, y: y, z: z))
        fXAnyStubProtocolYAnyStubProtocolZAnyStubProtocolVoidClosure?(x, y, z)
    }

    //MARK: - j

    var jXAnyStubProtocolYAnyStubProtocolZAnyStubProtocolStringCallsCount = 0
    var jXAnyStubProtocolYAnyStubProtocolZAnyStubProtocolStringCalled: Bool {
        return jXAnyStubProtocolYAnyStubProtocolZAnyStubProtocolStringCallsCount > 0
    }
    var jXAnyStubProtocolYAnyStubProtocolZAnyStubProtocolStringReceivedArguments: (x: (any StubProtocol)?, y: (any StubProtocol)?, z: any StubProtocol)?
    var jXAnyStubProtocolYAnyStubProtocolZAnyStubProtocolStringReceivedInvocations: [(x: (any StubProtocol)?, y: (any StubProtocol)?, z: any StubProtocol)] = []
    var jXAnyStubProtocolYAnyStubProtocolZAnyStubProtocolStringReturnValue: String!
    var jXAnyStubProtocolYAnyStubProtocolZAnyStubProtocolStringClosure: (((any StubProtocol)?, (any StubProtocol)?, any StubProtocol) async -> String)?

    func j(x: (any StubProtocol)?, y: (any StubProtocol)!, z: any StubProtocol) async -> String {
        jXAnyStubProtocolYAnyStubProtocolZAnyStubProtocolStringCallsCount += 1
        jXAnyStubProtocolYAnyStubProtocolZAnyStubProtocolStringReceivedArguments = (x: x, y: y, z: z)
        jXAnyStubProtocolYAnyStubProtocolZAnyStubProtocolStringReceivedInvocations.append((x: x, y: y, z: z))
        if let jXAnyStubProtocolYAnyStubProtocolZAnyStubProtocolStringClosure = jXAnyStubProtocolYAnyStubProtocolZAnyStubProtocolStringClosure {
            return await jXAnyStubProtocolYAnyStubProtocolZAnyStubProtocolStringClosure(x, y, z)
        } else {
            return jXAnyStubProtocolYAnyStubProtocolZAnyStubProtocolStringReturnValue
        }
    }

    //MARK: - k

    var kXAnyStubProtocolVoidYAnyStubProtocolVoidVoidCallsCount = 0
    var kXAnyStubProtocolVoidYAnyStubProtocolVoidVoidCalled: Bool {
        return kXAnyStubProtocolVoidYAnyStubProtocolVoidVoidCallsCount > 0
    }
    var kXAnyStubProtocolVoidYAnyStubProtocolVoidVoidClosure: ((((any StubProtocol)?) -> Void, (any StubProtocol) -> Void) -> Void)?

    func k(x: ((any StubProtocol)?) -> Void, y: (any StubProtocol) -> Void) {
        kXAnyStubProtocolVoidYAnyStubProtocolVoidVoidCallsCount += 1
        kXAnyStubProtocolVoidYAnyStubProtocolVoidVoidClosure?(x, y)
    }

    //MARK: - l

    var lXAnyStubProtocolVoidYAnyStubProtocolVoidVoidCallsCount = 0
    var lXAnyStubProtocolVoidYAnyStubProtocolVoidVoidCalled: Bool {
        return lXAnyStubProtocolVoidYAnyStubProtocolVoidVoidCallsCount > 0
    }
    var lXAnyStubProtocolVoidYAnyStubProtocolVoidVoidClosure: ((((any StubProtocol)?) -> Void, (any StubProtocol) -> Void) -> Void)?

    func l(x: ((any StubProtocol)?) -> Void, y: (any StubProtocol) -> Void) {
        lXAnyStubProtocolVoidYAnyStubProtocolVoidVoidCallsCount += 1
        lXAnyStubProtocolVoidYAnyStubProtocolVoidVoidClosure?(x, y)
    }

    //MARK: - m

    var mAnyConfusingArgumentNameAnyStubProtocolVoidCallsCount = 0
    var mAnyConfusingArgumentNameAnyStubProtocolVoidCalled: Bool {
        return mAnyConfusingArgumentNameAnyStubProtocolVoidCallsCount > 0
    }
    var mAnyConfusingArgumentNameAnyStubProtocolVoidReceivedAnyConfusingArgumentName: (any StubProtocol)?
    var mAnyConfusingArgumentNameAnyStubProtocolVoidReceivedInvocations: [(any StubProtocol)] = []
    var mAnyConfusingArgumentNameAnyStubProtocolVoidClosure: ((any StubProtocol) -> Void)?

    func m(anyConfusingArgumentName: any StubProtocol) {
        mAnyConfusingArgumentNameAnyStubProtocolVoidCallsCount += 1
        mAnyConfusingArgumentNameAnyStubProtocolVoidReceivedAnyConfusingArgumentName = anyConfusingArgumentName
        mAnyConfusingArgumentNameAnyStubProtocolVoidReceivedInvocations.append(anyConfusingArgumentName)
        mAnyConfusingArgumentNameAnyStubProtocolVoidClosure?(anyConfusingArgumentName)
    }

    //MARK: - n

    var nXEscapingAnyStubProtocolVoidVoidCallsCount = 0
    var nXEscapingAnyStubProtocolVoidVoidCalled: Bool {
        return nXEscapingAnyStubProtocolVoidVoidCallsCount > 0
    }
    var nXEscapingAnyStubProtocolVoidVoidReceivedX: ((((any StubProtocol)?) -> Void))?
    var nXEscapingAnyStubProtocolVoidVoidReceivedInvocations: [((((any StubProtocol)?) -> Void))] = []
    var nXEscapingAnyStubProtocolVoidVoidClosure: ((@escaping ((any StubProtocol)?) -> Void) -> Void)?

    func n(x: @escaping ((any StubProtocol)?) -> Void) {
        nXEscapingAnyStubProtocolVoidVoidCallsCount += 1
        nXEscapingAnyStubProtocolVoidVoidReceivedX = x
        nXEscapingAnyStubProtocolVoidVoidReceivedInvocations.append(x)
        nXEscapingAnyStubProtocolVoidVoidClosure?(x)
    }

    //MARK: - p

    var pXAnyStubWithAnyNameProtocolVoidCallsCount = 0
    var pXAnyStubWithAnyNameProtocolVoidCalled: Bool {
        return pXAnyStubWithAnyNameProtocolVoidCallsCount > 0
    }
    var pXAnyStubWithAnyNameProtocolVoidReceivedX: (any StubWithAnyNameProtocol)?
    var pXAnyStubWithAnyNameProtocolVoidReceivedInvocations: [(any StubWithAnyNameProtocol)?] = []
    var pXAnyStubWithAnyNameProtocolVoidClosure: (((any StubWithAnyNameProtocol)?) -> Void)?

    func p(_ x: (any StubWithAnyNameProtocol)?) {
        pXAnyStubWithAnyNameProtocolVoidCallsCount += 1
        pXAnyStubWithAnyNameProtocolVoidReceivedX = x
        pXAnyStubWithAnyNameProtocolVoidReceivedInvocations.append(x)
        pXAnyStubWithAnyNameProtocolVoidClosure?(x)
    }

    //MARK: - q

    var qAnyStubProtocolCallsCount = 0
    var qAnyStubProtocolCalled: Bool {
        return qAnyStubProtocolCallsCount > 0
    }
    var qAnyStubProtocolReturnValue: (any StubProtocol)!
    var qAnyStubProtocolClosure: (() -> any StubProtocol)?

    func q() -> any StubProtocol {
        qAnyStubProtocolCallsCount += 1
        if let qAnyStubProtocolClosure = qAnyStubProtocolClosure {
            return qAnyStubProtocolClosure()
        } else {
            return qAnyStubProtocolReturnValue
        }
    }

    //MARK: - r

    var rAnyStubProtocolCallsCount = 0
    var rAnyStubProtocolCalled: Bool {
        return rAnyStubProtocolCallsCount > 0
    }
    var rAnyStubProtocolReturnValue: ((any StubProtocol)?)
    var rAnyStubProtocolClosure: (() -> (any StubProtocol)?)?

    func r() -> (any StubProtocol)? {
        rAnyStubProtocolCallsCount += 1
        if let rAnyStubProtocolClosure = rAnyStubProtocolClosure {
            return rAnyStubProtocolClosure()
        } else {
            return rAnyStubProtocolReturnValue
        }
    }

    //MARK: - s

    var s____AnyStubProtocolCallsCount = 0
    var s____AnyStubProtocolCalled: Bool {
        return s____AnyStubProtocolCallsCount > 0
    }
    var s____AnyStubProtocolReturnValue: ((() -> any StubProtocol))!
    var s____AnyStubProtocolClosure: (() -> (() -> any StubProtocol))?

    func s() -> (() -> any StubProtocol) {
        s____AnyStubProtocolCallsCount += 1
        if let s____AnyStubProtocolClosure = s____AnyStubProtocolClosure {
            return s____AnyStubProtocolClosure()
        } else {
            return s____AnyStubProtocolReturnValue
        }
    }

    //MARK: - t

    var t____AnyStubProtocolCallsCount = 0
    var t____AnyStubProtocolCalled: Bool {
        return t____AnyStubProtocolCallsCount > 0
    }
    var t____AnyStubProtocolReturnValue: ((() -> (any StubProtocol)?))!
    var t____AnyStubProtocolClosure: (() -> (() -> (any StubProtocol)?))?

    func t() -> (() -> (any StubProtocol)?) {
        t____AnyStubProtocolCallsCount += 1
        if let t____AnyStubProtocolClosure = t____AnyStubProtocolClosure {
            return t____AnyStubProtocolClosure()
        } else {
            return t____AnyStubProtocolReturnValue
        }
    }

    //MARK: - u

    var u_IntAnyStubProtocolCallsCount = 0
    var u_IntAnyStubProtocolCalled: Bool {
        return u_IntAnyStubProtocolCallsCount > 0
    }
    var u_IntAnyStubProtocolReturnValue: ((Int, () -> (any StubProtocol)?))!
    var u_IntAnyStubProtocolClosure: (() -> (Int, () -> (any StubProtocol)?))?

    func u() -> (Int, () -> (any StubProtocol)?) {
        u_IntAnyStubProtocolCallsCount += 1
        if let u_IntAnyStubProtocolClosure = u_IntAnyStubProtocolClosure {
            return u_IntAnyStubProtocolClosure()
        } else {
            return u_IntAnyStubProtocolReturnValue
        }
    }

    //MARK: - v

    var v_IntAnyStubProtocolCallsCount = 0
    var v_IntAnyStubProtocolCalled: Bool {
        return v_IntAnyStubProtocolCallsCount > 0
    }
    var v_IntAnyStubProtocolReturnValue: ((Int, (() -> any StubProtocol)?))!
    var v_IntAnyStubProtocolClosure: (() -> (Int, (() -> any StubProtocol)?))?

    func v() -> (Int, (() -> any StubProtocol)?) {
        v_IntAnyStubProtocolCallsCount += 1
        if let v_IntAnyStubProtocolClosure = v_IntAnyStubProtocolClosure {
            return v_IntAnyStubProtocolClosure()
        } else {
            return v_IntAnyStubProtocolReturnValue
        }
    }

    //MARK: - w

    var w_AnyStubProtocolCallsCount = 0
    var w_AnyStubProtocolCalled: Bool {
        return w_AnyStubProtocolCallsCount > 0
    }
    var w_AnyStubProtocolReturnValue: ([(any StubProtocol)?])!
    var w_AnyStubProtocolClosure: (() -> [(any StubProtocol)?])?

    func w() -> [(any StubProtocol)?] {
        w_AnyStubProtocolCallsCount += 1
        if let w_AnyStubProtocolClosure = w_AnyStubProtocolClosure {
            return w_AnyStubProtocolClosure()
        } else {
            return w_AnyStubProtocolReturnValue
        }
    }

    //MARK: - x

    var xStringAnyStubProtocolCallsCount = 0
    var xStringAnyStubProtocolCalled: Bool {
        return xStringAnyStubProtocolCallsCount > 0
    }
    var xStringAnyStubProtocolReturnValue: ([String: (any StubProtocol)?])!
    var xStringAnyStubProtocolClosure: (() -> [String: (any StubProtocol)?])?

    func x() -> [String: (any StubProtocol)?] {
        xStringAnyStubProtocolCallsCount += 1
        if let xStringAnyStubProtocolClosure = xStringAnyStubProtocolClosure {
            return xStringAnyStubProtocolClosure()
        } else {
            return xStringAnyStubProtocolReturnValue
        }
    }

    //MARK: - y

    var y_AnyStubProtocolAnyStubProtocolCallsCount = 0
    var y_AnyStubProtocolAnyStubProtocolCalled: Bool {
        return y_AnyStubProtocolAnyStubProtocolCallsCount > 0
    }
    var y_AnyStubProtocolAnyStubProtocolReturnValue: ((any StubProtocol, (any StubProtocol)?))!
    var y_AnyStubProtocolAnyStubProtocolClosure: (() -> (any StubProtocol, (any StubProtocol)?))?

    func y() -> (any StubProtocol, (any StubProtocol)?) {
        y_AnyStubProtocolAnyStubProtocolCallsCount += 1
        if let y_AnyStubProtocolAnyStubProtocolClosure = y_AnyStubProtocolAnyStubProtocolClosure {
            return y_AnyStubProtocolAnyStubProtocolClosure()
        } else {
            return y_AnyStubProtocolAnyStubProtocolReturnValue
        }
    }

    //MARK: - z

    var zAnyStubProtocolCustomStringConvertibleCallsCount = 0
    var zAnyStubProtocolCustomStringConvertibleCalled: Bool {
        return zAnyStubProtocolCustomStringConvertibleCallsCount > 0
    }
    var zAnyStubProtocolCustomStringConvertibleReturnValue: (any StubProtocol & CustomStringConvertible)!
    var zAnyStubProtocolCustomStringConvertibleClosure: (() -> any StubProtocol & CustomStringConvertible)?

    func z() -> any StubProtocol & CustomStringConvertible {
        zAnyStubProtocolCustomStringConvertibleCallsCount += 1
        if let zAnyStubProtocolCustomStringConvertibleClosure = zAnyStubProtocolCustomStringConvertibleClosure {
            return zAnyStubProtocolCustomStringConvertibleClosure()
        } else {
            return zAnyStubProtocolCustomStringConvertibleReturnValue
        }
    }


}
class AsyncProtocolMock: AsyncProtocol {




    //MARK: - callAsync

    var callAsyncParameterIntStringCallsCount = 0
    var callAsyncParameterIntStringCalled: Bool {
        return callAsyncParameterIntStringCallsCount > 0
    }
    var callAsyncParameterIntStringReceivedParameter: (Int)?
    var callAsyncParameterIntStringReceivedInvocations: [(Int)] = []
    var callAsyncParameterIntStringReturnValue: String!
    var callAsyncParameterIntStringClosure: ((Int) async -> String)?

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func callAsync(parameter: Int) async -> String {
        callAsyncParameterIntStringCallsCount += 1
        callAsyncParameterIntStringReceivedParameter = parameter
        callAsyncParameterIntStringReceivedInvocations.append(parameter)
        if let callAsyncParameterIntStringClosure = callAsyncParameterIntStringClosure {
            return await callAsyncParameterIntStringClosure(parameter)
        } else {
            return callAsyncParameterIntStringReturnValue
        }
    }

    //MARK: - callAsyncAndThrow

    var callAsyncAndThrowParameterIntStringThrowableError: (any Error)?
    var callAsyncAndThrowParameterIntStringCallsCount = 0
    var callAsyncAndThrowParameterIntStringCalled: Bool {
        return callAsyncAndThrowParameterIntStringCallsCount > 0
    }
    var callAsyncAndThrowParameterIntStringReceivedParameter: (Int)?
    var callAsyncAndThrowParameterIntStringReceivedInvocations: [(Int)] = []
    var callAsyncAndThrowParameterIntStringReturnValue: String!
    var callAsyncAndThrowParameterIntStringClosure: ((Int) async throws -> String)?

    func callAsyncAndThrow(parameter: Int) async throws -> String {
        callAsyncAndThrowParameterIntStringCallsCount += 1
        callAsyncAndThrowParameterIntStringReceivedParameter = parameter
        callAsyncAndThrowParameterIntStringReceivedInvocations.append(parameter)
        if let error = callAsyncAndThrowParameterIntStringThrowableError {
            throw error
        }
        if let callAsyncAndThrowParameterIntStringClosure = callAsyncAndThrowParameterIntStringClosure {
            return try await callAsyncAndThrowParameterIntStringClosure(parameter)
        } else {
            return callAsyncAndThrowParameterIntStringReturnValue
        }
    }

    //MARK: - callAsyncVoid

    var callAsyncVoidParameterIntVoidCallsCount = 0
    var callAsyncVoidParameterIntVoidCalled: Bool {
        return callAsyncVoidParameterIntVoidCallsCount > 0
    }
    var callAsyncVoidParameterIntVoidReceivedParameter: (Int)?
    var callAsyncVoidParameterIntVoidReceivedInvocations: [(Int)] = []
    var callAsyncVoidParameterIntVoidClosure: ((Int) async -> Void)?

    func callAsyncVoid(parameter: Int) async {
        callAsyncVoidParameterIntVoidCallsCount += 1
        callAsyncVoidParameterIntVoidReceivedParameter = parameter
        callAsyncVoidParameterIntVoidReceivedInvocations.append(parameter)
        await callAsyncVoidParameterIntVoidClosure?(parameter)
    }

    //MARK: - callAsyncAndThrowVoid

    var callAsyncAndThrowVoidParameterIntVoidThrowableError: (any Error)?
    var callAsyncAndThrowVoidParameterIntVoidCallsCount = 0
    var callAsyncAndThrowVoidParameterIntVoidCalled: Bool {
        return callAsyncAndThrowVoidParameterIntVoidCallsCount > 0
    }
    var callAsyncAndThrowVoidParameterIntVoidReceivedParameter: (Int)?
    var callAsyncAndThrowVoidParameterIntVoidReceivedInvocations: [(Int)] = []
    var callAsyncAndThrowVoidParameterIntVoidClosure: ((Int) async throws -> Void)?

    func callAsyncAndThrowVoid(parameter: Int) async throws {
        callAsyncAndThrowVoidParameterIntVoidCallsCount += 1
        callAsyncAndThrowVoidParameterIntVoidReceivedParameter = parameter
        callAsyncAndThrowVoidParameterIntVoidReceivedInvocations.append(parameter)
        if let error = callAsyncAndThrowVoidParameterIntVoidThrowableError {
            throw error
        }
        try await callAsyncAndThrowVoidParameterIntVoidClosure?(parameter)
    }


}
class AsyncThrowingVariablesProtocolMock: AsyncThrowingVariablesProtocol {


    var titleCallsCount = 0
    var titleCalled: Bool {
        return titleCallsCount > 0
    }

    var title: String? {
        get async throws {
            titleCallsCount += 1
            if let error = titleThrowableError {
                throw error
            }
            if let titleClosure = titleClosure {
                return try await titleClosure()
            } else {
                return underlyingTitle
            }
        }
    }
    var underlyingTitle: String?
    var titleThrowableError: Error?
    var titleClosure: (() async throws -> String?)?
    var firstNameCallsCount = 0
    var firstNameCalled: Bool {
        return firstNameCallsCount > 0
    }

    var firstName: String {
        get async throws {
            firstNameCallsCount += 1
            if let error = firstNameThrowableError {
                throw error
            }
            if let firstNameClosure = firstNameClosure {
                return try await firstNameClosure()
            } else {
                return underlyingFirstName
            }
        }
    }
    var underlyingFirstName: String!
    var firstNameThrowableError: Error?
    var firstNameClosure: (() async throws -> String)?



}
class AsyncVariablesProtocolMock: AsyncVariablesProtocol {


    var titleCallsCount = 0
    var titleCalled: Bool {
        return titleCallsCount > 0
    }

    var title: String? {
        get async {
            titleCallsCount += 1
            if let titleClosure = titleClosure {
                return await titleClosure()
            } else {
                return underlyingTitle
            }
        }
    }
    var underlyingTitle: String?
    var titleClosure: (() async -> String?)?
    var firstNameCallsCount = 0
    var firstNameCalled: Bool {
        return firstNameCallsCount > 0
    }

    var firstName: String {
        get async {
            firstNameCallsCount += 1
            if let firstNameClosure = firstNameClosure {
                return await firstNameClosure()
            } else {
                return underlyingFirstName
            }
        }
    }
    var underlyingFirstName: String!
    var firstNameClosure: (() async -> String)?



}
class BasicProtocolMock: BasicProtocol {




    //MARK: - loadConfiguration

    var loadConfigurationStringCallsCount = 0
    var loadConfigurationStringCalled: Bool {
        return loadConfigurationStringCallsCount > 0
    }
    var loadConfigurationStringReturnValue: String?
    var loadConfigurationStringClosure: (() -> String?)?

    func loadConfiguration() -> String? {
        loadConfigurationStringCallsCount += 1
        if let loadConfigurationStringClosure = loadConfigurationStringClosure {
            return loadConfigurationStringClosure()
        } else {
            return loadConfigurationStringReturnValue
        }
    }

    //MARK: - save

    var saveConfigurationStringVoidCallsCount = 0
    var saveConfigurationStringVoidCalled: Bool {
        return saveConfigurationStringVoidCallsCount > 0
    }
    var saveConfigurationStringVoidReceivedConfiguration: (String)?
    var saveConfigurationStringVoidReceivedInvocations: [(String)] = []
    var saveConfigurationStringVoidClosure: ((String) -> Void)?

    func save(configuration: String) {
        saveConfigurationStringVoidCallsCount += 1
        saveConfigurationStringVoidReceivedConfiguration = configuration
        saveConfigurationStringVoidReceivedInvocations.append(configuration)
        saveConfigurationStringVoidClosure?(configuration)
    }


}
class ClosureProtocolMock: ClosureProtocol {




    //MARK: - setClosure

    var setClosureClosureEscapingVoidVoidCallsCount = 0
    var setClosureClosureEscapingVoidVoidCalled: Bool {
        return setClosureClosureEscapingVoidVoidCallsCount > 0
    }
    var setClosureClosureEscapingVoidVoidReceivedClosure: ((() -> Void))?
    var setClosureClosureEscapingVoidVoidReceivedInvocations: [((() -> Void))] = []
    var setClosureClosureEscapingVoidVoidClosure: ((@escaping () -> Void) -> Void)?

    func setClosure(_ closure: @escaping () -> Void) {
        setClosureClosureEscapingVoidVoidCallsCount += 1
        setClosureClosureEscapingVoidVoidReceivedClosure = closure
        setClosureClosureEscapingVoidVoidReceivedInvocations.append(closure)
        setClosureClosureEscapingVoidVoidClosure?(closure)
    }


}
class CurrencyPresenterMock: CurrencyPresenter {




    //MARK: - showSourceCurrency

    var showSourceCurrencyCurrencyStringVoidCallsCount = 0
    var showSourceCurrencyCurrencyStringVoidCalled: Bool {
        return showSourceCurrencyCurrencyStringVoidCallsCount > 0
    }
    var showSourceCurrencyCurrencyStringVoidReceivedCurrency: (String)?
    var showSourceCurrencyCurrencyStringVoidReceivedInvocations: [(String)] = []
    var showSourceCurrencyCurrencyStringVoidClosure: ((String) -> Void)?

    func showSourceCurrency(_ currency: String) {
        showSourceCurrencyCurrencyStringVoidCallsCount += 1
        showSourceCurrencyCurrencyStringVoidReceivedCurrency = currency
        showSourceCurrencyCurrencyStringVoidReceivedInvocations.append(currency)
        showSourceCurrencyCurrencyStringVoidClosure?(currency)
    }


}
class ExampleVarargMock: ExampleVararg {




    //MARK: - string

    var stringKeyStringArgsCVarArgStringCallsCount = 0
    var stringKeyStringArgsCVarArgStringCalled: Bool {
        return stringKeyStringArgsCVarArgStringCallsCount > 0
    }
    var stringKeyStringArgsCVarArgStringReceivedArguments: (key: String, args: [CVarArg])?
    var stringKeyStringArgsCVarArgStringReceivedInvocations: [(key: String, args: [CVarArg])] = []
    var stringKeyStringArgsCVarArgStringReturnValue: String!
    var stringKeyStringArgsCVarArgStringClosure: ((String, CVarArg...) -> String)?

    func string(key: String, args: CVarArg...) -> String {
        stringKeyStringArgsCVarArgStringCallsCount += 1
        stringKeyStringArgsCVarArgStringReceivedArguments = (key: key, args: args)
        stringKeyStringArgsCVarArgStringReceivedInvocations.append((key: key, args: args))
        if let stringKeyStringArgsCVarArgStringClosure = stringKeyStringArgsCVarArgStringClosure {
            return stringKeyStringArgsCVarArgStringClosure(key, args)
        } else {
            return stringKeyStringArgsCVarArgStringReturnValue
        }
    }


}
class ExampleVarargFourMock: ExampleVarargFour {




    //MARK: - toto

    var totoArgStringAnyCollectionVoidVoidCallsCount = 0
    var totoArgStringAnyCollectionVoidVoidCalled: Bool {
        return totoArgStringAnyCollectionVoidVoidCallsCount > 0
    }
    var totoArgStringAnyCollectionVoidVoidClosure: (((String, any Collection...) -> Void) -> Void)?

    func toto(arg: ((String, any Collection...) -> Void)) {
        totoArgStringAnyCollectionVoidVoidCallsCount += 1
        totoArgStringAnyCollectionVoidVoidClosure?(arg)
    }


}
class ExampleVarargThreeMock: ExampleVarargThree {




    //MARK: - toto

    var totoArgStringAnyCollectionAnyCollectionVoidCallsCount = 0
    var totoArgStringAnyCollectionAnyCollectionVoidCalled: Bool {
        return totoArgStringAnyCollectionAnyCollectionVoidCallsCount > 0
    }
    var totoArgStringAnyCollectionAnyCollectionVoidClosure: (((String, any Collection...) -> any Collection) -> Void)?

    func toto(arg: ((String, any Collection...) -> any Collection)) {
        totoArgStringAnyCollectionAnyCollectionVoidCallsCount += 1
        totoArgStringAnyCollectionAnyCollectionVoidClosure?(arg)
    }


}
class ExampleVarargTwoMock: ExampleVarargTwo {




    //MARK: - toto

    var totoArgsAnyStubWithSomeNameProtocolVoidCallsCount = 0
    var totoArgsAnyStubWithSomeNameProtocolVoidCalled: Bool {
        return totoArgsAnyStubWithSomeNameProtocolVoidCallsCount > 0
    }
    var totoArgsAnyStubWithSomeNameProtocolVoidReceivedArgs: ([(any StubWithSomeNameProtocol)])?
    var totoArgsAnyStubWithSomeNameProtocolVoidReceivedInvocations: [([(any StubWithSomeNameProtocol)])] = []
    var totoArgsAnyStubWithSomeNameProtocolVoidClosure: (([(any StubWithSomeNameProtocol)]) -> Void)?

    func toto(args: any StubWithSomeNameProtocol...) {
        totoArgsAnyStubWithSomeNameProtocolVoidCallsCount += 1
        totoArgsAnyStubWithSomeNameProtocolVoidReceivedArgs = args
        totoArgsAnyStubWithSomeNameProtocolVoidReceivedInvocations.append(args)
        totoArgsAnyStubWithSomeNameProtocolVoidClosure?(args)
    }


}
class ExtendableProtocolMock: ExtendableProtocol {


    var canReport: Bool {
        get { return underlyingCanReport }
        set(value) { underlyingCanReport = value }
    }
    var underlyingCanReport: (Bool)!


    //MARK: - report

    var reportMessageStringVoidCallsCount = 0
    var reportMessageStringVoidCalled: Bool {
        return reportMessageStringVoidCallsCount > 0
    }
    var reportMessageStringVoidReceivedMessage: (String)?
    var reportMessageStringVoidReceivedInvocations: [(String)] = []
    var reportMessageStringVoidClosure: ((String) -> Void)?

    func report(message: String) {
        reportMessageStringVoidCallsCount += 1
        reportMessageStringVoidReceivedMessage = message
        reportMessageStringVoidReceivedInvocations.append(message)
        reportMessageStringVoidClosure?(message)
    }


}
class FunctionWithAttributesMock: FunctionWithAttributes {




    //MARK: - callOneAttribute

    var callOneAttributeStringCallsCount = 0
    var callOneAttributeStringCalled: Bool {
        return callOneAttributeStringCallsCount > 0
    }
    var callOneAttributeStringReturnValue: String!
    var callOneAttributeStringClosure: (() -> String)?

    @discardableResult
    func callOneAttribute() -> String {
        callOneAttributeStringCallsCount += 1
        if let callOneAttributeStringClosure = callOneAttributeStringClosure {
            return callOneAttributeStringClosure()
        } else {
            return callOneAttributeStringReturnValue
        }
    }

    //MARK: - callTwoAttributes

    var callTwoAttributesIntCallsCount = 0
    var callTwoAttributesIntCalled: Bool {
        return callTwoAttributesIntCallsCount > 0
    }
    var callTwoAttributesIntReturnValue: Int!
    var callTwoAttributesIntClosure: (() -> Int)?

    @available(macOS 10.15, *)
    @discardableResult
    func callTwoAttributes() -> Int {
        callTwoAttributesIntCallsCount += 1
        if let callTwoAttributesIntClosure = callTwoAttributesIntClosure {
            return callTwoAttributesIntClosure()
        } else {
            return callTwoAttributesIntReturnValue
        }
    }

    //MARK: - callRepeatedAttributes

    var callRepeatedAttributesBoolCallsCount = 0
    var callRepeatedAttributesBoolCalled: Bool {
        return callRepeatedAttributesBoolCallsCount > 0
    }
    var callRepeatedAttributesBoolReturnValue: Bool!
    var callRepeatedAttributesBoolClosure: (() -> Bool)?

    @available(iOS 13.0, *)
    @available(macOS 10.15, *)
    @discardableResult
    func callRepeatedAttributes() -> Bool {
        callRepeatedAttributesBoolCallsCount += 1
        if let callRepeatedAttributesBoolClosure = callRepeatedAttributesBoolClosure {
            return callRepeatedAttributesBoolClosure()
        } else {
            return callRepeatedAttributesBoolReturnValue
        }
    }


}
class FunctionWithClosureReturnTypeMock: FunctionWithClosureReturnType {




    //MARK: - get

    var get____VoidCallsCount = 0
    var get____VoidCalled: Bool {
        return get____VoidCallsCount > 0
    }
    var get____VoidReturnValue: ((() -> Void))!
    var get____VoidClosure: (() -> (() -> Void))?

    func get() -> (() -> Void) {
        get____VoidCallsCount += 1
        if let get____VoidClosure = get____VoidClosure {
            return get____VoidClosure()
        } else {
            return get____VoidReturnValue
        }
    }

    //MARK: - getOptional

    var getOptional_____VoidCallsCount = 0
    var getOptional_____VoidCalled: Bool {
        return getOptional_____VoidCallsCount > 0
    }
    var getOptional_____VoidReturnValue: ((() -> Void)?)
    var getOptional_____VoidClosure: (() -> ((() -> Void)?))?

    func getOptional() -> ((() -> Void)?) {
        getOptional_____VoidCallsCount += 1
        if let getOptional_____VoidClosure = getOptional_____VoidClosure {
            return getOptional_____VoidClosure()
        } else {
            return getOptional_____VoidReturnValue
        }
    }


}
class FunctionWithMultilineDeclarationMock: FunctionWithMultilineDeclaration {




    //MARK: - start

    var startCarStringOfModelStringVoidCallsCount = 0
    var startCarStringOfModelStringVoidCalled: Bool {
        return startCarStringOfModelStringVoidCallsCount > 0
    }
    var startCarStringOfModelStringVoidReceivedArguments: (car: String, model: String)?
    var startCarStringOfModelStringVoidReceivedInvocations: [(car: String, model: String)] = []
    var startCarStringOfModelStringVoidClosure: ((String, String) -> Void)?

    func start(car: String, of model: String) {
        startCarStringOfModelStringVoidCallsCount += 1
        startCarStringOfModelStringVoidReceivedArguments = (car: car, model: model)
        startCarStringOfModelStringVoidReceivedInvocations.append((car: car, model: model))
        startCarStringOfModelStringVoidClosure?(car, model)
    }


}
class FunctionWithNullableCompletionThatHasNullableAnyParameterProtocolMock: FunctionWithNullableCompletionThatHasNullableAnyParameterProtocol {




    //MARK: - add

    var addRequestIntWithCompletionHandlerCompletionHandlerAnyErrorVoidVoidCallsCount = 0
    var addRequestIntWithCompletionHandlerCompletionHandlerAnyErrorVoidVoidCalled: Bool {
        return addRequestIntWithCompletionHandlerCompletionHandlerAnyErrorVoidVoidCallsCount > 0
    }
    var addRequestIntWithCompletionHandlerCompletionHandlerAnyErrorVoidVoidClosure: ((Int, ((((any Error)?) -> Void))?) -> Void)?

    func add(_ request: Int, withCompletionHandler completionHandler: ((((any Error)?) -> Void))?) {
        addRequestIntWithCompletionHandlerCompletionHandlerAnyErrorVoidVoidCallsCount += 1
        addRequestIntWithCompletionHandlerCompletionHandlerAnyErrorVoidVoidClosure?(request, completionHandler)
    }


}
class HouseProtocolMock: HouseProtocol {


    var aPublisher: AnyPublisher<any PersonProtocol, Never>?
    var bPublisher: AnyPublisher<(any PersonProtocol)?, Never>?
    var cPublisher: CurrentValueSubject<(any PersonProtocol)?, Never>?
    var dPublisher: PassthroughSubject<(any PersonProtocol)?, Never>?
    var e1Publisher: GenericType<(any PersonProtocol)?, Never, Never>?
    var e2Publisher: GenericType<Never, (any PersonProtocol)?, Never>?
    var e3Publisher: GenericType<Never, Never, (any PersonProtocol)?>?
    var e4Publisher: GenericType<(any PersonProtocol)?, (any PersonProtocol)?, (any PersonProtocol)?>?
    var f1Publisher: GenericType<any PersonProtocol, Never, Never>?
    var f2Publisher: GenericType<Never, any PersonProtocol, Never>?
    var f3Publisher: GenericType<Never, Never, any PersonProtocol>?
    var f4Publisher: GenericType<any PersonProtocol, any PersonProtocol, any PersonProtocol>?



}
class ImplicitlyUnwrappedOptionalReturnValueProtocolMock: ImplicitlyUnwrappedOptionalReturnValueProtocol {




    //MARK: - implicitReturn

    var implicitReturnStringCallsCount = 0
    var implicitReturnStringCalled: Bool {
        return implicitReturnStringCallsCount > 0
    }
    var implicitReturnStringReturnValue: String!
    var implicitReturnStringClosure: (() -> String)?

    func implicitReturn() -> String! {
        implicitReturnStringCallsCount += 1
        if let implicitReturnStringClosure = implicitReturnStringClosure {
            return implicitReturnStringClosure()
        } else {
            return implicitReturnStringReturnValue
        }
    }


}
class InitializationProtocolMock: InitializationProtocol {




    //MARK: - init

    var initIntParameterIntStringParameterStringOptionalParameterStringInitializationProtocolReceivedArguments: (intParameter: Int, stringParameter: String, optionalParameter: String?)?
    var initIntParameterIntStringParameterStringOptionalParameterStringInitializationProtocolReceivedInvocations: [(intParameter: Int, stringParameter: String, optionalParameter: String?)] = []
    var initIntParameterIntStringParameterStringOptionalParameterStringInitializationProtocolClosure: ((Int, String, String?) -> Void)?

    required init(intParameter: Int, stringParameter: String, optionalParameter: String?) {
        initIntParameterIntStringParameterStringOptionalParameterStringInitializationProtocolReceivedArguments = (intParameter: intParameter, stringParameter: stringParameter, optionalParameter: optionalParameter)
        initIntParameterIntStringParameterStringOptionalParameterStringInitializationProtocolReceivedInvocations.append((intParameter: intParameter, stringParameter: stringParameter, optionalParameter: optionalParameter))
        initIntParameterIntStringParameterStringOptionalParameterStringInitializationProtocolClosure?(intParameter, stringParameter, optionalParameter)
    }
    //MARK: - start

    var startVoidCallsCount = 0
    var startVoidCalled: Bool {
        return startVoidCallsCount > 0
    }
    var startVoidClosure: (() -> Void)?

    func start() {
        startVoidCallsCount += 1
        startVoidClosure?()
    }

    //MARK: - stop

    var stopVoidCallsCount = 0
    var stopVoidCalled: Bool {
        return stopVoidCallsCount > 0
    }
    var stopVoidClosure: (() -> Void)?

    func stop() {
        stopVoidCallsCount += 1
        stopVoidClosure?()
    }


}
class MultiClosureProtocolMock: MultiClosureProtocol {




    //MARK: - setClosure

    var setClosureNameStringClosureEscapingVoidVoidCallsCount = 0
    var setClosureNameStringClosureEscapingVoidVoidCalled: Bool {
        return setClosureNameStringClosureEscapingVoidVoidCallsCount > 0
    }
    var setClosureNameStringClosureEscapingVoidVoidReceivedArguments: (name: String, closure: () -> Void)?
    var setClosureNameStringClosureEscapingVoidVoidReceivedInvocations: [(name: String, closure: () -> Void)] = []
    var setClosureNameStringClosureEscapingVoidVoidClosure: ((String, @escaping () -> Void) -> Void)?

    func setClosure(name: String, _ closure: @escaping () -> Void) {
        setClosureNameStringClosureEscapingVoidVoidCallsCount += 1
        setClosureNameStringClosureEscapingVoidVoidReceivedArguments = (name: name, closure: closure)
        setClosureNameStringClosureEscapingVoidVoidReceivedInvocations.append((name: name, closure: closure))
        setClosureNameStringClosureEscapingVoidVoidClosure?(name, closure)
    }


}
class MultiExistentialArgumentsClosureProtocolMock: MultiExistentialArgumentsClosureProtocol {




    //MARK: - execute

    var executeCompletionAnyStubWithSomeNameProtocolAnyStubWithSomeNameProtocolAnyStubWithSomeNameProtocolVoidCallsCount = 0
    var executeCompletionAnyStubWithSomeNameProtocolAnyStubWithSomeNameProtocolAnyStubWithSomeNameProtocolVoidCalled: Bool {
        return executeCompletionAnyStubWithSomeNameProtocolAnyStubWithSomeNameProtocolAnyStubWithSomeNameProtocolVoidCallsCount > 0
    }
    var executeCompletionAnyStubWithSomeNameProtocolAnyStubWithSomeNameProtocolAnyStubWithSomeNameProtocolVoidClosure: ((((any StubWithSomeNameProtocol)?, (any StubWithSomeNameProtocol)) -> (any StubWithSomeNameProtocol)?) -> Void)?

    func execute(completion: (((any StubWithSomeNameProtocol)?, (any StubWithSomeNameProtocol)) -> (any StubWithSomeNameProtocol)?)) {
        executeCompletionAnyStubWithSomeNameProtocolAnyStubWithSomeNameProtocolAnyStubWithSomeNameProtocolVoidCallsCount += 1
        executeCompletionAnyStubWithSomeNameProtocolAnyStubWithSomeNameProtocolAnyStubWithSomeNameProtocolVoidClosure?(completion)
    }


}
class MultiNonEscapingClosureProtocolMock: MultiNonEscapingClosureProtocol {




    //MARK: - executeClosure

    var executeClosureNameStringClosureVoidVoidCallsCount = 0
    var executeClosureNameStringClosureVoidVoidCalled: Bool {
        return executeClosureNameStringClosureVoidVoidCallsCount > 0
    }
    var executeClosureNameStringClosureVoidVoidClosure: ((String, () -> Void) -> Void)?

    func executeClosure(name: String, _ closure: () -> Void) {
        executeClosureNameStringClosureVoidVoidCallsCount += 1
        executeClosureNameStringClosureVoidVoidClosure?(name, closure)
    }


}
class NonEscapingClosureProtocolMock: NonEscapingClosureProtocol {




    //MARK: - executeClosure

    var executeClosureClosureVoidVoidCallsCount = 0
    var executeClosureClosureVoidVoidCalled: Bool {
        return executeClosureClosureVoidVoidCallsCount > 0
    }
    var executeClosureClosureVoidVoidClosure: ((() -> Void) -> Void)?

    func executeClosure(_ closure: () -> Void) {
        executeClosureClosureVoidVoidCallsCount += 1
        executeClosureClosureVoidVoidClosure?(closure)
    }


}
public class ProtocolWithMethodWithGenericParametersMock: ProtocolWithMethodWithGenericParameters {

    public init() {}



    //MARK: - execute

    public var executeParamResultIntErrorResultStringErrorCallsCount = 0
    public var executeParamResultIntErrorResultStringErrorCalled: Bool {
        return executeParamResultIntErrorResultStringErrorCallsCount > 0
    }
    public var executeParamResultIntErrorResultStringErrorReceivedParam: (Result<Int, Error>)?
    public var executeParamResultIntErrorResultStringErrorReceivedInvocations: [(Result<Int, Error>)] = []
    public var executeParamResultIntErrorResultStringErrorReturnValue: Result<String, Error>!
    public var executeParamResultIntErrorResultStringErrorClosure: ((Result<Int, Error>) -> Result<String, Error>)?

    public func execute(param: Result<Int, Error>) -> Result<String, Error> {
        executeParamResultIntErrorResultStringErrorCallsCount += 1
        executeParamResultIntErrorResultStringErrorReceivedParam = param
        executeParamResultIntErrorResultStringErrorReceivedInvocations.append(param)
        if let executeParamResultIntErrorResultStringErrorClosure = executeParamResultIntErrorResultStringErrorClosure {
            return executeParamResultIntErrorResultStringErrorClosure(param)
        } else {
            return executeParamResultIntErrorResultStringErrorReturnValue
        }
    }


}
public class ProtocolWithMethodWithInoutParameterMock: ProtocolWithMethodWithInoutParameter {

    public init() {}



    //MARK: - execute

    public var executeParamInoutStringVoidCallsCount = 0
    public var executeParamInoutStringVoidCalled: Bool {
        return executeParamInoutStringVoidCallsCount > 0
    }
    public var executeParamInoutStringVoidReceivedParam: (String)?
    public var executeParamInoutStringVoidReceivedInvocations: [(String)] = []
    public var executeParamInoutStringVoidClosure: ((inout String) -> Void)?

    public func execute(param: inout String) {
        executeParamInoutStringVoidCallsCount += 1
        executeParamInoutStringVoidReceivedParam = param
        executeParamInoutStringVoidReceivedInvocations.append(param)
        executeParamInoutStringVoidClosure?(&param)
    }

    //MARK: - execute

    public var executeParamInoutStringBarIntVoidCallsCount = 0
    public var executeParamInoutStringBarIntVoidCalled: Bool {
        return executeParamInoutStringBarIntVoidCallsCount > 0
    }
    public var executeParamInoutStringBarIntVoidReceivedArguments: (param: String, bar: Int)?
    public var executeParamInoutStringBarIntVoidReceivedInvocations: [(param: String, bar: Int)] = []
    public var executeParamInoutStringBarIntVoidClosure: ((inout String, Int) -> Void)?

    public func execute(param: inout String, bar: Int) {
        executeParamInoutStringBarIntVoidCallsCount += 1
        executeParamInoutStringBarIntVoidReceivedArguments = (param: param, bar: bar)
        executeParamInoutStringBarIntVoidReceivedInvocations.append((param: param, bar: bar))
        executeParamInoutStringBarIntVoidClosure?(&param, bar)
    }


}
public class ProtocolWithOverridesMock: ProtocolWithOverrides {

    public init() {}



    //MARK: - doSomething

    public var doSomethingDataIntStringCallsCount = 0
    public var doSomethingDataIntStringCalled: Bool {
        return doSomethingDataIntStringCallsCount > 0
    }
    public var doSomethingDataIntStringReceivedData: (Int)?
    public var doSomethingDataIntStringReceivedInvocations: [(Int)] = []
    public var doSomethingDataIntStringReturnValue: [String]!
    public var doSomethingDataIntStringClosure: ((Int) -> [String])?

    public func doSomething(_ data: Int) -> [String] {
        doSomethingDataIntStringCallsCount += 1
        doSomethingDataIntStringReceivedData = data
        doSomethingDataIntStringReceivedInvocations.append(data)
        if let doSomethingDataIntStringClosure = doSomethingDataIntStringClosure {
            return doSomethingDataIntStringClosure(data)
        } else {
            return doSomethingDataIntStringReturnValue
        }
    }

    //MARK: - doSomething

    public var doSomethingDataStringStringCallsCount = 0
    public var doSomethingDataStringStringCalled: Bool {
        return doSomethingDataStringStringCallsCount > 0
    }
    public var doSomethingDataStringStringReceivedData: (String)?
    public var doSomethingDataStringStringReceivedInvocations: [(String)] = []
    public var doSomethingDataStringStringReturnValue: [String]!
    public var doSomethingDataStringStringClosure: ((String) -> [String])?

    public func doSomething(_ data: String) -> [String] {
        doSomethingDataStringStringCallsCount += 1
        doSomethingDataStringStringReceivedData = data
        doSomethingDataStringStringReceivedInvocations.append(data)
        if let doSomethingDataStringStringClosure = doSomethingDataStringStringClosure {
            return doSomethingDataStringStringClosure(data)
        } else {
            return doSomethingDataStringStringReturnValue
        }
    }

    //MARK: - doSomething

    public var doSomethingDataStringIntCallsCount = 0
    public var doSomethingDataStringIntCalled: Bool {
        return doSomethingDataStringIntCallsCount > 0
    }
    public var doSomethingDataStringIntReceivedData: (String)?
    public var doSomethingDataStringIntReceivedInvocations: [(String)] = []
    public var doSomethingDataStringIntReturnValue: [Int]!
    public var doSomethingDataStringIntClosure: ((String) -> [Int])?

    public func doSomething(_ data: String) -> [Int] {
        doSomethingDataStringIntCallsCount += 1
        doSomethingDataStringIntReceivedData = data
        doSomethingDataStringIntReceivedInvocations.append(data)
        if let doSomethingDataStringIntClosure = doSomethingDataStringIntClosure {
            return doSomethingDataStringIntClosure(data)
        } else {
            return doSomethingDataStringIntReturnValue
        }
    }

    //MARK: - doSomething

    public var doSomethingDataString_IntStringCallsCount = 0
    public var doSomethingDataString_IntStringCalled: Bool {
        return doSomethingDataString_IntStringCallsCount > 0
    }
    public var doSomethingDataString_IntStringReceivedData: (String)?
    public var doSomethingDataString_IntStringReceivedInvocations: [(String)] = []
    public var doSomethingDataString_IntStringReturnValue: ([Int], [String])!
    public var doSomethingDataString_IntStringClosure: ((String) -> ([Int], [String]))?

    public func doSomething(_ data: String) -> ([Int], [String]) {
        doSomethingDataString_IntStringCallsCount += 1
        doSomethingDataString_IntStringReceivedData = data
        doSomethingDataString_IntStringReceivedInvocations.append(data)
        if let doSomethingDataString_IntStringClosure = doSomethingDataString_IntStringClosure {
            return doSomethingDataString_IntStringClosure(data)
        } else {
            return doSomethingDataString_IntStringReturnValue
        }
    }

    //MARK: - doSomething

    public var doSomethingDataString_IntAnyThrowableError: (any Error)?
    public var doSomethingDataString_IntAnyCallsCount = 0
    public var doSomethingDataString_IntAnyCalled: Bool {
        return doSomethingDataString_IntAnyCallsCount > 0
    }
    public var doSomethingDataString_IntAnyReceivedData: (String)?
    public var doSomethingDataString_IntAnyReceivedInvocations: [(String)] = []
    public var doSomethingDataString_IntAnyReturnValue: ([Int], [Any])!
    public var doSomethingDataString_IntAnyClosure: ((String) throws -> ([Int], [Any]))?

    public func doSomething(_ data: String) throws -> ([Int], [Any]) {
        doSomethingDataString_IntAnyCallsCount += 1
        doSomethingDataString_IntAnyReceivedData = data
        doSomethingDataString_IntAnyReceivedInvocations.append(data)
        if let error = doSomethingDataString_IntAnyThrowableError {
            throw error
        }
        if let doSomethingDataString_IntAnyClosure = doSomethingDataString_IntAnyClosure {
            return try doSomethingDataString_IntAnyClosure(data)
        } else {
            return doSomethingDataString_IntAnyReturnValue
        }
    }

    //MARK: - doSomething

    public var doSomethingDataString_IntStringVoidCallsCount = 0
    public var doSomethingDataString_IntStringVoidCalled: Bool {
        return doSomethingDataString_IntStringVoidCallsCount > 0
    }
    public var doSomethingDataString_IntStringVoidReceivedData: (String)?
    public var doSomethingDataString_IntStringVoidReceivedInvocations: [(String)] = []
    public var doSomethingDataString_IntStringVoidReturnValue: ((([Int], [String]) -> Void))!
    public var doSomethingDataString_IntStringVoidClosure: ((String) -> (([Int], [String]) -> Void))?

    public func doSomething(_ data: String) -> (([Int], [String]) -> Void) {
        doSomethingDataString_IntStringVoidCallsCount += 1
        doSomethingDataString_IntStringVoidReceivedData = data
        doSomethingDataString_IntStringVoidReceivedInvocations.append(data)
        if let doSomethingDataString_IntStringVoidClosure = doSomethingDataString_IntStringVoidClosure {
            return doSomethingDataString_IntStringVoidClosure(data)
        } else {
            return doSomethingDataString_IntStringVoidReturnValue
        }
    }

    //MARK: - doSomething

    public var doSomethingDataString_IntAnyVoidThrowableError: (any Error)?
    public var doSomethingDataString_IntAnyVoidCallsCount = 0
    public var doSomethingDataString_IntAnyVoidCalled: Bool {
        return doSomethingDataString_IntAnyVoidCallsCount > 0
    }
    public var doSomethingDataString_IntAnyVoidReceivedData: (String)?
    public var doSomethingDataString_IntAnyVoidReceivedInvocations: [(String)] = []
    public var doSomethingDataString_IntAnyVoidReturnValue: ((([Int], [Any]) -> Void))!
    public var doSomethingDataString_IntAnyVoidClosure: ((String) throws -> (([Int], [Any]) -> Void))?

    public func doSomething(_ data: String) throws -> (([Int], [Any]) -> Void) {
        doSomethingDataString_IntAnyVoidCallsCount += 1
        doSomethingDataString_IntAnyVoidReceivedData = data
        doSomethingDataString_IntAnyVoidReceivedInvocations.append(data)
        if let error = doSomethingDataString_IntAnyVoidThrowableError {
            throw error
        }
        if let doSomethingDataString_IntAnyVoidClosure = doSomethingDataString_IntAnyVoidClosure {
            return try doSomethingDataString_IntAnyVoidClosure(data)
        } else {
            return doSomethingDataString_IntAnyVoidReturnValue
        }
    }


}
class ReservedWordsProtocolMock: ReservedWordsProtocol {




    //MARK: - `continue`

    var continueWithMessageStringStringCallsCount = 0
    var continueWithMessageStringStringCalled: Bool {
        return continueWithMessageStringStringCallsCount > 0
    }
    var continueWithMessageStringStringReceivedMessage: (String)?
    var continueWithMessageStringStringReceivedInvocations: [(String)] = []
    var continueWithMessageStringStringReturnValue: String!
    var continueWithMessageStringStringClosure: ((String) -> String)?

    func `continue`(with message: String) -> String {
        continueWithMessageStringStringCallsCount += 1
        continueWithMessageStringStringReceivedMessage = message
        continueWithMessageStringStringReceivedInvocations.append(message)
        if let continueWithMessageStringStringClosure = continueWithMessageStringStringClosure {
            return continueWithMessageStringStringClosure(message)
        } else {
            return continueWithMessageStringStringReturnValue
        }
    }


}
class SameShortMethodNamesProtocolMock: SameShortMethodNamesProtocol {




    //MARK: - start

    var startCarStringOfModelStringVoidCallsCount = 0
    var startCarStringOfModelStringVoidCalled: Bool {
        return startCarStringOfModelStringVoidCallsCount > 0
    }
    var startCarStringOfModelStringVoidReceivedArguments: (car: String, model: String)?
    var startCarStringOfModelStringVoidReceivedInvocations: [(car: String, model: String)] = []
    var startCarStringOfModelStringVoidClosure: ((String, String) -> Void)?

    func start(car: String, of model: String) {
        startCarStringOfModelStringVoidCallsCount += 1
        startCarStringOfModelStringVoidReceivedArguments = (car: car, model: model)
        startCarStringOfModelStringVoidReceivedInvocations.append((car: car, model: model))
        startCarStringOfModelStringVoidClosure?(car, model)
    }

    //MARK: - start

    var startPlaneStringOfModelStringVoidCallsCount = 0
    var startPlaneStringOfModelStringVoidCalled: Bool {
        return startPlaneStringOfModelStringVoidCallsCount > 0
    }
    var startPlaneStringOfModelStringVoidReceivedArguments: (plane: String, model: String)?
    var startPlaneStringOfModelStringVoidReceivedInvocations: [(plane: String, model: String)] = []
    var startPlaneStringOfModelStringVoidClosure: ((String, String) -> Void)?

    func start(plane: String, of model: String) {
        startPlaneStringOfModelStringVoidCallsCount += 1
        startPlaneStringOfModelStringVoidReceivedArguments = (plane: plane, model: model)
        startPlaneStringOfModelStringVoidReceivedInvocations.append((plane: plane, model: model))
        startPlaneStringOfModelStringVoidClosure?(plane, model)
    }


}
class SingleOptionalParameterFunctionMock: SingleOptionalParameterFunction {




    //MARK: - send

    var sendMessageStringVoidCallsCount = 0
    var sendMessageStringVoidCalled: Bool {
        return sendMessageStringVoidCallsCount > 0
    }
    var sendMessageStringVoidReceivedMessage: (String)?
    var sendMessageStringVoidReceivedInvocations: [(String)?] = []
    var sendMessageStringVoidClosure: ((String?) -> Void)?

    func send(message: String?) {
        sendMessageStringVoidCallsCount += 1
        sendMessageStringVoidReceivedMessage = message
        sendMessageStringVoidReceivedInvocations.append(message)
        sendMessageStringVoidClosure?(message)
    }


}
class SomeProtocolMock: SomeProtocol {




    //MARK: - a

    var aXSomeStubProtocolYSomeStubProtocolZSomeStubProtocolVoidCallsCount = 0
    var aXSomeStubProtocolYSomeStubProtocolZSomeStubProtocolVoidCalled: Bool {
        return aXSomeStubProtocolYSomeStubProtocolZSomeStubProtocolVoidCallsCount > 0
    }
    var aXSomeStubProtocolYSomeStubProtocolZSomeStubProtocolVoidReceivedArguments: (x: (any StubProtocol)?, y: (any StubProtocol)?, z: any StubProtocol)?
    var aXSomeStubProtocolYSomeStubProtocolZSomeStubProtocolVoidReceivedInvocations: [(x: (any StubProtocol)?, y: (any StubProtocol)?, z: any StubProtocol)] = []
    var aXSomeStubProtocolYSomeStubProtocolZSomeStubProtocolVoidClosure: (((any StubProtocol)?, (any StubProtocol)?, any StubProtocol) -> Void)?

    func a(_ x: (some StubProtocol)?, y: (some StubProtocol)!, z: some StubProtocol) {
        aXSomeStubProtocolYSomeStubProtocolZSomeStubProtocolVoidCallsCount += 1
        aXSomeStubProtocolYSomeStubProtocolZSomeStubProtocolVoidReceivedArguments = (x: x, y: y, z: z)
        aXSomeStubProtocolYSomeStubProtocolZSomeStubProtocolVoidReceivedInvocations.append((x: x, y: y, z: z))
        aXSomeStubProtocolYSomeStubProtocolZSomeStubProtocolVoidClosure?(x, y, z)
    }

    //MARK: - b

    var bXSomeStubProtocolYSomeStubProtocolZSomeStubProtocolStringCallsCount = 0
    var bXSomeStubProtocolYSomeStubProtocolZSomeStubProtocolStringCalled: Bool {
        return bXSomeStubProtocolYSomeStubProtocolZSomeStubProtocolStringCallsCount > 0
    }
    var bXSomeStubProtocolYSomeStubProtocolZSomeStubProtocolStringReceivedArguments: (x: (any StubProtocol)?, y: (any StubProtocol)?, z: any StubProtocol)?
    var bXSomeStubProtocolYSomeStubProtocolZSomeStubProtocolStringReceivedInvocations: [(x: (any StubProtocol)?, y: (any StubProtocol)?, z: any StubProtocol)] = []
    var bXSomeStubProtocolYSomeStubProtocolZSomeStubProtocolStringReturnValue: String!
    var bXSomeStubProtocolYSomeStubProtocolZSomeStubProtocolStringClosure: (((any StubProtocol)?, (any StubProtocol)?, any StubProtocol) async -> String)?

    func b(x: (some StubProtocol)?, y: (some StubProtocol)!, z: some StubProtocol) async -> String {
        bXSomeStubProtocolYSomeStubProtocolZSomeStubProtocolStringCallsCount += 1
        bXSomeStubProtocolYSomeStubProtocolZSomeStubProtocolStringReceivedArguments = (x: x, y: y, z: z)
        bXSomeStubProtocolYSomeStubProtocolZSomeStubProtocolStringReceivedInvocations.append((x: x, y: y, z: z))
        if let bXSomeStubProtocolYSomeStubProtocolZSomeStubProtocolStringClosure = bXSomeStubProtocolYSomeStubProtocolZSomeStubProtocolStringClosure {
            return await bXSomeStubProtocolYSomeStubProtocolZSomeStubProtocolStringClosure(x, y, z)
        } else {
            return bXSomeStubProtocolYSomeStubProtocolZSomeStubProtocolStringReturnValue
        }
    }

    //MARK: - someConfusingFuncName

    var someConfusingFuncNameXSomeStubProtocolVoidCallsCount = 0
    var someConfusingFuncNameXSomeStubProtocolVoidCalled: Bool {
        return someConfusingFuncNameXSomeStubProtocolVoidCallsCount > 0
    }
    var someConfusingFuncNameXSomeStubProtocolVoidReceivedX: (any StubProtocol)?
    var someConfusingFuncNameXSomeStubProtocolVoidReceivedInvocations: [(any StubProtocol)] = []
    var someConfusingFuncNameXSomeStubProtocolVoidClosure: ((any StubProtocol) -> Void)?

    func someConfusingFuncName(x: some StubProtocol) {
        someConfusingFuncNameXSomeStubProtocolVoidCallsCount += 1
        someConfusingFuncNameXSomeStubProtocolVoidReceivedX = x
        someConfusingFuncNameXSomeStubProtocolVoidReceivedInvocations.append(x)
        someConfusingFuncNameXSomeStubProtocolVoidClosure?(x)
    }

    //MARK: - c

    var cSomeConfusingArgumentNameSomeStubProtocolVoidCallsCount = 0
    var cSomeConfusingArgumentNameSomeStubProtocolVoidCalled: Bool {
        return cSomeConfusingArgumentNameSomeStubProtocolVoidCallsCount > 0
    }
    var cSomeConfusingArgumentNameSomeStubProtocolVoidReceivedSomeConfusingArgumentName: (any StubProtocol)?
    var cSomeConfusingArgumentNameSomeStubProtocolVoidReceivedInvocations: [(any StubProtocol)] = []
    var cSomeConfusingArgumentNameSomeStubProtocolVoidClosure: ((any StubProtocol) -> Void)?

    func c(someConfusingArgumentName: some StubProtocol) {
        cSomeConfusingArgumentNameSomeStubProtocolVoidCallsCount += 1
        cSomeConfusingArgumentNameSomeStubProtocolVoidReceivedSomeConfusingArgumentName = someConfusingArgumentName
        cSomeConfusingArgumentNameSomeStubProtocolVoidReceivedInvocations.append(someConfusingArgumentName)
        cSomeConfusingArgumentNameSomeStubProtocolVoidClosure?(someConfusingArgumentName)
    }

    //MARK: - d

    var dXSomeStubWithSomeNameProtocolVoidCallsCount = 0
    var dXSomeStubWithSomeNameProtocolVoidCalled: Bool {
        return dXSomeStubWithSomeNameProtocolVoidCallsCount > 0
    }
    var dXSomeStubWithSomeNameProtocolVoidReceivedX: (any StubWithSomeNameProtocol)?
    var dXSomeStubWithSomeNameProtocolVoidReceivedInvocations: [(any StubWithSomeNameProtocol)?] = []
    var dXSomeStubWithSomeNameProtocolVoidClosure: (((any StubWithSomeNameProtocol)?) -> Void)?

    func d(_ x: (some StubWithSomeNameProtocol)?) {
        dXSomeStubWithSomeNameProtocolVoidCallsCount += 1
        dXSomeStubWithSomeNameProtocolVoidReceivedX = x
        dXSomeStubWithSomeNameProtocolVoidReceivedInvocations.append(x)
        dXSomeStubWithSomeNameProtocolVoidClosure?(x)
    }


}
class StaticMethodProtocolMock: StaticMethodProtocol {



    static func reset()
    {
         //MARK: - staticFunction
        staticFunctionStringStringCallsCount = 0
        staticFunctionStringStringReceived = nil
        staticFunctionStringStringReceivedInvocations = []
        staticFunctionStringStringClosure = nil


    }

    //MARK: - staticFunction

    static var staticFunctionStringStringCallsCount = 0
    static var staticFunctionStringStringCalled: Bool {
        return staticFunctionStringStringCallsCount > 0
    }
    static var staticFunctionStringStringReceived: (String)?
    static var staticFunctionStringStringReceivedInvocations: [(String)] = []
    static var staticFunctionStringStringReturnValue: String!
    static var staticFunctionStringStringClosure: ((String) -> String)?

    static func staticFunction(_ arg0: String) -> String {
        staticFunctionStringStringCallsCount += 1
        staticFunctionStringStringReceived = arg0
        staticFunctionStringStringReceivedInvocations.append(arg0)
        if let staticFunctionStringStringClosure = staticFunctionStringStringClosure {
            return staticFunctionStringStringClosure(arg0)
        } else {
            return staticFunctionStringStringReturnValue
        }
    }


}
class SubscriptProtocolMock: SubscriptProtocol {





    //MARK: - Subscript #1
    subscript(arg: Int) -> String {
        get { fatalError("Subscripts are not fully supported yet") }
        set { fatalError("Subscripts are not fully supported yet") }
    }
    //MARK: - Subscript #2
    subscript<T>(arg: T) -> Int {
        get { fatalError("Subscripts are not fully supported yet") }
    }
    //MARK: - Subscript #3
    subscript<T>(arg: T) -> String {
        get async { fatalError("Subscripts are not fully supported yet") }
    }
    //MARK: - Subscript #4
    subscript<T: Hashable>(arg: T) -> T? {
        get { fatalError("Subscripts are not fully supported yet") }
        set { fatalError("Subscripts are not fully supported yet") }
    }
    //MARK: - Subscript #5
    subscript<T>(arg: String) -> T? where T : Cancellable {
        get throws { fatalError("Subscripts are not fully supported yet") }
    }
}
class ThrowableProtocolMock: ThrowableProtocol {




    //MARK: - doOrThrow

    var doOrThrowStringThrowableError: (any Error)?
    var doOrThrowStringCallsCount = 0
    var doOrThrowStringCalled: Bool {
        return doOrThrowStringCallsCount > 0
    }
    var doOrThrowStringReturnValue: String!
    var doOrThrowStringClosure: (() throws -> String)?

    func doOrThrow() throws -> String {
        doOrThrowStringCallsCount += 1
        if let error = doOrThrowStringThrowableError {
            throw error
        }
        if let doOrThrowStringClosure = doOrThrowStringClosure {
            return try doOrThrowStringClosure()
        } else {
            return doOrThrowStringReturnValue
        }
    }

    //MARK: - doOrThrowVoid

    var doOrThrowVoidVoidThrowableError: (any Error)?
    var doOrThrowVoidVoidCallsCount = 0
    var doOrThrowVoidVoidCalled: Bool {
        return doOrThrowVoidVoidCallsCount > 0
    }
    var doOrThrowVoidVoidClosure: (() throws -> Void)?

    func doOrThrowVoid() throws {
        doOrThrowVoidVoidCallsCount += 1
        if let error = doOrThrowVoidVoidThrowableError {
            throw error
        }
        try doOrThrowVoidVoidClosure?()
    }


}
class ThrowingVariablesProtocolMock: ThrowingVariablesProtocol {


    var titleCallsCount = 0
    var titleCalled: Bool {
        return titleCallsCount > 0
    }

    var title: String? {
        get throws {
            titleCallsCount += 1
            if let error = titleThrowableError {
                throw error
            }
            if let titleClosure = titleClosure {
                return try titleClosure()
            } else {
                return underlyingTitle
            }
        }
    }
    var underlyingTitle: String?
    var titleThrowableError: Error?
    var titleClosure: (() throws -> String?)?
    var firstNameCallsCount = 0
    var firstNameCalled: Bool {
        return firstNameCallsCount > 0
    }

    var firstName: String {
        get throws {
            firstNameCallsCount += 1
            if let error = firstNameThrowableError {
                throw error
            }
            if let firstNameClosure = firstNameClosure {
                return try firstNameClosure()
            } else {
                return underlyingFirstName
            }
        }
    }
    var underlyingFirstName: String!
    var firstNameThrowableError: Error?
    var firstNameClosure: (() throws -> String)?



}
class VariablesProtocolMock: VariablesProtocol {


    var company: String?
    var name: String {
        get { return underlyingName }
        set(value) { underlyingName = value }
    }
    var underlyingName: (String)!
    var age: Int {
        get { return underlyingAge }
        set(value) { underlyingAge = value }
    }
    var underlyingAge: (Int)!
    var kids: [String] = []
    var universityMarks: [String: Int] = [:]



}
