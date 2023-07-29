// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
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

    public var loadConfigurationCallsCount = 0
    public var loadConfigurationCalled: Bool {
        return loadConfigurationCallsCount > 0
    }
    public var loadConfigurationReturnValue: String?
    public var loadConfigurationClosure: (() -> String?)?

    public func loadConfiguration() -> String? {
        loadConfigurationCallsCount += 1
        if let loadConfigurationClosure = loadConfigurationClosure {
            return loadConfigurationClosure()
        } else {
            return loadConfigurationReturnValue
        }
    }

}
class AnnotatedProtocolMock: AnnotatedProtocol {




    //MARK: - sayHelloWith

    var sayHelloWithNameCallsCount = 0
    var sayHelloWithNameCalled: Bool {
        return sayHelloWithNameCallsCount > 0
    }
    var sayHelloWithNameReceivedName: (String)?
    var sayHelloWithNameReceivedInvocations: [(String)] = []
    var sayHelloWithNameClosure: ((String) -> Void)?

    func sayHelloWith(name: String) {
        sayHelloWithNameCallsCount += 1
        sayHelloWithNameReceivedName = name
        sayHelloWithNameReceivedInvocations.append(name)
        sayHelloWithNameClosure?(name)
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

    var fyzCallsCount = 0
    var fyzCalled: Bool {
        return fyzCallsCount > 0
    }
    var fyzReceivedArguments: (x: (any StubProtocol)?, y: (any StubProtocol)?, z: any StubProtocol)?
    var fyzReceivedInvocations: [(x: (any StubProtocol)?, y: (any StubProtocol)?, z: any StubProtocol)] = []
    var fyzClosure: (((any StubProtocol)?, (any StubProtocol)?, any StubProtocol) -> Void)?

    func f(_ x: (any StubProtocol)?, y: (any StubProtocol)!, z: any StubProtocol) {
        fyzCallsCount += 1
        fyzReceivedArguments = (x: x, y: y, z: z)
        fyzReceivedInvocations.append((x: x, y: y, z: z))
        fyzClosure?(x, y, z)
    }

    //MARK: - j

    var jxyzCallsCount = 0
    var jxyzCalled: Bool {
        return jxyzCallsCount > 0
    }
    var jxyzReceivedArguments: (x: (any StubProtocol)?, y: (any StubProtocol)?, z: any StubProtocol)?
    var jxyzReceivedInvocations: [(x: (any StubProtocol)?, y: (any StubProtocol)?, z: any StubProtocol)] = []
    var jxyzReturnValue: String!
    var jxyzClosure: (((any StubProtocol)?, (any StubProtocol)?, any StubProtocol) async -> String)?

    func j(x: (any StubProtocol)?, y: (any StubProtocol)!, z: any StubProtocol) async -> String {
        jxyzCallsCount += 1
        jxyzReceivedArguments = (x: x, y: y, z: z)
        jxyzReceivedInvocations.append((x: x, y: y, z: z))
        if let jxyzClosure = jxyzClosure {
            return await jxyzClosure(x, y, z)
        } else {
            return jxyzReturnValue
        }
    }

    //MARK: - k

    var kxyCallsCount = 0
    var kxyCalled: Bool {
        return kxyCallsCount > 0
    }
    var kxyClosure: ((((any StubProtocol)?) -> Void, (any StubProtocol) -> Void) -> Void)?

    func k(x: ((any StubProtocol)?) -> Void, y: (any StubProtocol) -> Void) {
        kxyCallsCount += 1
        kxyClosure?(x, y)
    }

    //MARK: - l

    var lxyCallsCount = 0
    var lxyCalled: Bool {
        return lxyCallsCount > 0
    }
    var lxyClosure: ((((any StubProtocol)?) -> Void, (any StubProtocol) -> Void) -> Void)?

    func l(x: ((any StubProtocol)?) -> Void, y: (any StubProtocol) -> Void) {
        lxyCallsCount += 1
        lxyClosure?(x, y)
    }

    //MARK: - m

    var mAnyConfusingArgumentNameCallsCount = 0
    var mAnyConfusingArgumentNameCalled: Bool {
        return mAnyConfusingArgumentNameCallsCount > 0
    }
    var mAnyConfusingArgumentNameReceivedAnyConfusingArgumentName: (any StubProtocol)?
    var mAnyConfusingArgumentNameReceivedInvocations: [(any StubProtocol)] = []
    var mAnyConfusingArgumentNameClosure: ((any StubProtocol) -> Void)?

    func m(anyConfusingArgumentName: any StubProtocol) {
        mAnyConfusingArgumentNameCallsCount += 1
        mAnyConfusingArgumentNameReceivedAnyConfusingArgumentName = anyConfusingArgumentName
        mAnyConfusingArgumentNameReceivedInvocations.append(anyConfusingArgumentName)
        mAnyConfusingArgumentNameClosure?(anyConfusingArgumentName)
    }

    //MARK: - n

    var nxCallsCount = 0
    var nxCalled: Bool {
        return nxCallsCount > 0
    }
    var nxReceivedX: ((((any StubProtocol)?) -> Void))?
    var nxReceivedInvocations: [((((any StubProtocol)?) -> Void))] = []
    var nxClosure: ((@escaping ((any StubProtocol)?) -> Void) -> Void)?

    func n(x: @escaping ((any StubProtocol)?) -> Void) {
        nxCallsCount += 1
        nxReceivedX = x
        nxReceivedInvocations.append(x)
        nxClosure?(x)
    }

    //MARK: - p

    var pCallsCount = 0
    var pCalled: Bool {
        return pCallsCount > 0
    }
    var pReceivedX: (any StubWithAnyNameProtocol)?
    var pReceivedInvocations: [(any StubWithAnyNameProtocol)?] = []
    var pClosure: (((any StubWithAnyNameProtocol)?) -> Void)?

    func p(_ x: (any StubWithAnyNameProtocol)?) {
        pCallsCount += 1
        pReceivedX = x
        pReceivedInvocations.append(x)
        pClosure?(x)
    }

    //MARK: - q

    var qCallsCount = 0
    var qCalled: Bool {
        return qCallsCount > 0
    }
    var qReturnValue: (any StubProtocol)!
    var qClosure: (() -> any StubProtocol)?

    func q() -> any StubProtocol {
        qCallsCount += 1
        if let qClosure = qClosure {
            return qClosure()
        } else {
            return qReturnValue
        }
    }

    //MARK: - r

    var rCallsCount = 0
    var rCalled: Bool {
        return rCallsCount > 0
    }
    var rReturnValue: ((any StubProtocol)?)
    var rClosure: (() -> (any StubProtocol)?)?

    func r() -> (any StubProtocol)? {
        rCallsCount += 1
        if let rClosure = rClosure {
            return rClosure()
        } else {
            return rReturnValue
        }
    }

    //MARK: - s

    var sCallsCount = 0
    var sCalled: Bool {
        return sCallsCount > 0
    }
    var sReturnValue: (() -> any StubProtocol)!
    var sClosure: (() -> () -> any StubProtocol)?

    func s() -> () -> any StubProtocol {
        sCallsCount += 1
        if let sClosure = sClosure {
            return sClosure()
        } else {
            return sReturnValue
        }
    }

    //MARK: - t

    var tCallsCount = 0
    var tCalled: Bool {
        return tCallsCount > 0
    }
    var tReturnValue: ((() -> (any StubProtocol)?))!
    var tClosure: (() -> (() -> (any StubProtocol)?))?

    func t() -> (() -> (any StubProtocol)?) {
        tCallsCount += 1
        if let tClosure = tClosure {
            return tClosure()
        } else {
            return tReturnValue
        }
    }

    //MARK: - u

    var uCallsCount = 0
    var uCalled: Bool {
        return uCallsCount > 0
    }
    var uReturnValue: ((Int, () -> (any StubProtocol)?))!
    var uClosure: (() -> (Int, () -> (any StubProtocol)?))?

    func u() -> (Int, () -> (any StubProtocol)?) {
        uCallsCount += 1
        if let uClosure = uClosure {
            return uClosure()
        } else {
            return uReturnValue
        }
    }

    //MARK: - v

    var vCallsCount = 0
    var vCalled: Bool {
        return vCallsCount > 0
    }
    var vReturnValue: ((Int, (() -> any StubProtocol)?))!
    var vClosure: (() -> (Int, (() -> any StubProtocol)?))?

    func v() -> (Int, (() -> any StubProtocol)?) {
        vCallsCount += 1
        if let vClosure = vClosure {
            return vClosure()
        } else {
            return vReturnValue
        }
    }

    //MARK: - w

    var wCallsCount = 0
    var wCalled: Bool {
        return wCallsCount > 0
    }
    var wReturnValue: ([(any StubProtocol)?])!
    var wClosure: (() -> [(any StubProtocol)?])?

    func w() -> [(any StubProtocol)?] {
        wCallsCount += 1
        if let wClosure = wClosure {
            return wClosure()
        } else {
            return wReturnValue
        }
    }

    //MARK: - x

    var xCallsCount = 0
    var xCalled: Bool {
        return xCallsCount > 0
    }
    var xReturnValue: ([String: (any StubProtocol)?])!
    var xClosure: (() -> [String: (any StubProtocol)?])?

    func x() -> [String: (any StubProtocol)?] {
        xCallsCount += 1
        if let xClosure = xClosure {
            return xClosure()
        } else {
            return xReturnValue
        }
    }

    //MARK: - y

    var yCallsCount = 0
    var yCalled: Bool {
        return yCallsCount > 0
    }
    var yReturnValue: ((any StubProtocol, (any StubProtocol)?))!
    var yClosure: (() -> (any StubProtocol, (any StubProtocol)?))?

    func y() -> (any StubProtocol, (any StubProtocol)?) {
        yCallsCount += 1
        if let yClosure = yClosure {
            return yClosure()
        } else {
            return yReturnValue
        }
    }

    //MARK: - z

    var zCallsCount = 0
    var zCalled: Bool {
        return zCallsCount > 0
    }
    var zReturnValue: (any StubProtocol & CustomStringConvertible)!
    var zClosure: (() -> any StubProtocol & CustomStringConvertible)?

    func z() -> any StubProtocol & CustomStringConvertible {
        zCallsCount += 1
        if let zClosure = zClosure {
            return zClosure()
        } else {
            return zReturnValue
        }
    }

}
class AsyncProtocolMock: AsyncProtocol {




    //MARK: - callAsync

    var callAsyncParameterCallsCount = 0
    var callAsyncParameterCalled: Bool {
        return callAsyncParameterCallsCount > 0
    }
    var callAsyncParameterReceivedParameter: (Int)?
    var callAsyncParameterReceivedInvocations: [(Int)] = []
    var callAsyncParameterReturnValue: String!
    var callAsyncParameterClosure: ((Int) async -> String)?

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func callAsync(parameter: Int) async -> String {
        callAsyncParameterCallsCount += 1
        callAsyncParameterReceivedParameter = parameter
        callAsyncParameterReceivedInvocations.append(parameter)
        if let callAsyncParameterClosure = callAsyncParameterClosure {
            return await callAsyncParameterClosure(parameter)
        } else {
            return callAsyncParameterReturnValue
        }
    }

    //MARK: - callAsyncAndThrow

    var callAsyncAndThrowParameterThrowableError: Error?
    var callAsyncAndThrowParameterCallsCount = 0
    var callAsyncAndThrowParameterCalled: Bool {
        return callAsyncAndThrowParameterCallsCount > 0
    }
    var callAsyncAndThrowParameterReceivedParameter: (Int)?
    var callAsyncAndThrowParameterReceivedInvocations: [(Int)] = []
    var callAsyncAndThrowParameterReturnValue: String!
    var callAsyncAndThrowParameterClosure: ((Int) async throws -> String)?

    func callAsyncAndThrow(parameter: Int) async throws -> String {
        if let error = callAsyncAndThrowParameterThrowableError {
            throw error
        }
        callAsyncAndThrowParameterCallsCount += 1
        callAsyncAndThrowParameterReceivedParameter = parameter
        callAsyncAndThrowParameterReceivedInvocations.append(parameter)
        if let callAsyncAndThrowParameterClosure = callAsyncAndThrowParameterClosure {
            return try await callAsyncAndThrowParameterClosure(parameter)
        } else {
            return callAsyncAndThrowParameterReturnValue
        }
    }

    //MARK: - callAsyncVoid

    var callAsyncVoidParameterCallsCount = 0
    var callAsyncVoidParameterCalled: Bool {
        return callAsyncVoidParameterCallsCount > 0
    }
    var callAsyncVoidParameterReceivedParameter: (Int)?
    var callAsyncVoidParameterReceivedInvocations: [(Int)] = []
    var callAsyncVoidParameterClosure: ((Int) async -> Void)?

    func callAsyncVoid(parameter: Int) async {
        callAsyncVoidParameterCallsCount += 1
        callAsyncVoidParameterReceivedParameter = parameter
        callAsyncVoidParameterReceivedInvocations.append(parameter)
        await callAsyncVoidParameterClosure?(parameter)
    }

    //MARK: - callAsyncAndThrowVoid

    var callAsyncAndThrowVoidParameterThrowableError: Error?
    var callAsyncAndThrowVoidParameterCallsCount = 0
    var callAsyncAndThrowVoidParameterCalled: Bool {
        return callAsyncAndThrowVoidParameterCallsCount > 0
    }
    var callAsyncAndThrowVoidParameterReceivedParameter: (Int)?
    var callAsyncAndThrowVoidParameterReceivedInvocations: [(Int)] = []
    var callAsyncAndThrowVoidParameterClosure: ((Int) async throws -> Void)?

    func callAsyncAndThrowVoid(parameter: Int) async throws {
        if let error = callAsyncAndThrowVoidParameterThrowableError {
            throw error
        }
        callAsyncAndThrowVoidParameterCallsCount += 1
        callAsyncAndThrowVoidParameterReceivedParameter = parameter
        callAsyncAndThrowVoidParameterReceivedInvocations.append(parameter)
        try await callAsyncAndThrowVoidParameterClosure?(parameter)
    }

}
class AsyncThrowingVariablesProtocolMock: AsyncThrowingVariablesProtocol {


    var titleCallsCount = 0
    var titleCalled: Bool {
        return titleCallsCount > 0
    }

    var title: String? {
        get async throws {
            if let error = titleThrowableError {
                throw error
            }
            titleCallsCount += 1
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
            if let error = firstNameThrowableError {
                throw error
            }
            firstNameCallsCount += 1
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

    var loadConfigurationCallsCount = 0
    var loadConfigurationCalled: Bool {
        return loadConfigurationCallsCount > 0
    }
    var loadConfigurationReturnValue: String?
    var loadConfigurationClosure: (() -> String?)?

    func loadConfiguration() -> String? {
        loadConfigurationCallsCount += 1
        if let loadConfigurationClosure = loadConfigurationClosure {
            return loadConfigurationClosure()
        } else {
            return loadConfigurationReturnValue
        }
    }

    //MARK: - save

    var saveConfigurationCallsCount = 0
    var saveConfigurationCalled: Bool {
        return saveConfigurationCallsCount > 0
    }
    var saveConfigurationReceivedConfiguration: (String)?
    var saveConfigurationReceivedInvocations: [(String)] = []
    var saveConfigurationClosure: ((String) -> Void)?

    func save(configuration: String) {
        saveConfigurationCallsCount += 1
        saveConfigurationReceivedConfiguration = configuration
        saveConfigurationReceivedInvocations.append(configuration)
        saveConfigurationClosure?(configuration)
    }

}
class ClosureProtocolMock: ClosureProtocol {




    //MARK: - setClosure

    var setClosureCallsCount = 0
    var setClosureCalled: Bool {
        return setClosureCallsCount > 0
    }
    var setClosureReceivedClosure: ((() -> Void))?
    var setClosureReceivedInvocations: [((() -> Void))] = []
    var setClosureClosure: ((@escaping () -> Void) -> Void)?

    func setClosure(_ closure: @escaping () -> Void) {
        setClosureCallsCount += 1
        setClosureReceivedClosure = closure
        setClosureReceivedInvocations.append(closure)
        setClosureClosure?(closure)
    }

}
class CurrencyPresenterMock: CurrencyPresenter {




    //MARK: - showSourceCurrency

    var showSourceCurrencyCallsCount = 0
    var showSourceCurrencyCalled: Bool {
        return showSourceCurrencyCallsCount > 0
    }
    var showSourceCurrencyReceivedCurrency: (String)?
    var showSourceCurrencyReceivedInvocations: [(String)] = []
    var showSourceCurrencyClosure: ((String) -> Void)?

    func showSourceCurrency(_ currency: String) {
        showSourceCurrencyCallsCount += 1
        showSourceCurrencyReceivedCurrency = currency
        showSourceCurrencyReceivedInvocations.append(currency)
        showSourceCurrencyClosure?(currency)
    }

}
class ExtendableProtocolMock: ExtendableProtocol {


    var canReport: Bool {
        get { return underlyingCanReport }
        set(value) { underlyingCanReport = value }
    }
    var underlyingCanReport: (Bool)!


    //MARK: - report

    var reportMessageCallsCount = 0
    var reportMessageCalled: Bool {
        return reportMessageCallsCount > 0
    }
    var reportMessageReceivedMessage: (String)?
    var reportMessageReceivedInvocations: [(String)] = []
    var reportMessageClosure: ((String) -> Void)?

    func report(message: String) {
        reportMessageCallsCount += 1
        reportMessageReceivedMessage = message
        reportMessageReceivedInvocations.append(message)
        reportMessageClosure?(message)
    }

}
class FunctionWithAttributesMock: FunctionWithAttributes {




    //MARK: - callOneAttribute

    var callOneAttributeCallsCount = 0
    var callOneAttributeCalled: Bool {
        return callOneAttributeCallsCount > 0
    }
    var callOneAttributeReturnValue: String!
    var callOneAttributeClosure: (() -> String)?

    @discardableResult
    func callOneAttribute() -> String {
        callOneAttributeCallsCount += 1
        if let callOneAttributeClosure = callOneAttributeClosure {
            return callOneAttributeClosure()
        } else {
            return callOneAttributeReturnValue
        }
    }

    //MARK: - callTwoAttributes

    var callTwoAttributesCallsCount = 0
    var callTwoAttributesCalled: Bool {
        return callTwoAttributesCallsCount > 0
    }
    var callTwoAttributesReturnValue: Int!
    var callTwoAttributesClosure: (() -> Int)?

    @available(macOS 10.15, *)
    @discardableResult
    func callTwoAttributes() -> Int {
        callTwoAttributesCallsCount += 1
        if let callTwoAttributesClosure = callTwoAttributesClosure {
            return callTwoAttributesClosure()
        } else {
            return callTwoAttributesReturnValue
        }
    }

    //MARK: - callRepeatedAttributes

    var callRepeatedAttributesCallsCount = 0
    var callRepeatedAttributesCalled: Bool {
        return callRepeatedAttributesCallsCount > 0
    }
    var callRepeatedAttributesReturnValue: Bool!
    var callRepeatedAttributesClosure: (() -> Bool)?

    @available(iOS 13.0, *)
    @available(macOS 10.15, *)
    @discardableResult
    func callRepeatedAttributes() -> Bool {
        callRepeatedAttributesCallsCount += 1
        if let callRepeatedAttributesClosure = callRepeatedAttributesClosure {
            return callRepeatedAttributesClosure()
        } else {
            return callRepeatedAttributesReturnValue
        }
    }

}
class FunctionWithClosureReturnTypeMock: FunctionWithClosureReturnType {




    //MARK: - get

    var getCallsCount = 0
    var getCalled: Bool {
        return getCallsCount > 0
    }
    var getReturnValue: (() -> Void)!
    var getClosure: (() -> () -> Void)?

    func get() -> () -> Void {
        getCallsCount += 1
        if let getClosure = getClosure {
            return getClosure()
        } else {
            return getReturnValue
        }
    }

    //MARK: - getOptional

    var getOptionalCallsCount = 0
    var getOptionalCalled: Bool {
        return getOptionalCallsCount > 0
    }
    var getOptionalReturnValue: (() -> Void)?
    var getOptionalClosure: (() -> (() -> Void)?)?

    func getOptional() -> (() -> Void)? {
        getOptionalCallsCount += 1
        if let getOptionalClosure = getOptionalClosure {
            return getOptionalClosure()
        } else {
            return getOptionalReturnValue
        }
    }

}
class FunctionWithMultilineDeclarationMock: FunctionWithMultilineDeclaration {




    //MARK: - start

    var startCarOfCallsCount = 0
    var startCarOfCalled: Bool {
        return startCarOfCallsCount > 0
    }
    var startCarOfReceivedArguments: (car: String, model: String)?
    var startCarOfReceivedInvocations: [(car: String, model: String)] = []
    var startCarOfClosure: ((String, String) -> Void)?

    func start(car: String, of model: String) {
        startCarOfCallsCount += 1
        startCarOfReceivedArguments = (car: car, model: model)
        startCarOfReceivedInvocations.append((car: car, model: model))
        startCarOfClosure?(car, model)
    }

}
class ImplicitlyUnwrappedOptionalReturnValueProtocolMock: ImplicitlyUnwrappedOptionalReturnValueProtocol {




    //MARK: - implicitReturn

    var implicitReturnCallsCount = 0
    var implicitReturnCalled: Bool {
        return implicitReturnCallsCount > 0
    }
    var implicitReturnReturnValue: String!
    var implicitReturnClosure: (() -> String!)?

    func implicitReturn() -> String! {
        implicitReturnCallsCount += 1
        if let implicitReturnClosure = implicitReturnClosure {
            return implicitReturnClosure()
        } else {
            return implicitReturnReturnValue
        }
    }

}
class InitializationProtocolMock: InitializationProtocol {




    //MARK: - init

    var initIntParameterStringParameterOptionalParameterReceivedArguments: (intParameter: Int, stringParameter: String, optionalParameter: String?)?
    var initIntParameterStringParameterOptionalParameterReceivedInvocations: [(intParameter: Int, stringParameter: String, optionalParameter: String?)] = []
    var initIntParameterStringParameterOptionalParameterClosure: ((Int, String, String?) -> Void)?

    required init(intParameter: Int, stringParameter: String, optionalParameter: String?) {
        initIntParameterStringParameterOptionalParameterReceivedArguments = (intParameter: intParameter, stringParameter: stringParameter, optionalParameter: optionalParameter)
        initIntParameterStringParameterOptionalParameterReceivedInvocations.append((intParameter: intParameter, stringParameter: stringParameter, optionalParameter: optionalParameter))
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
class MultiClosureProtocolMock: MultiClosureProtocol {




    //MARK: - setClosure

    var setClosureNameCallsCount = 0
    var setClosureNameCalled: Bool {
        return setClosureNameCallsCount > 0
    }
    var setClosureNameReceivedArguments: (name: String, closure: () -> Void)?
    var setClosureNameReceivedInvocations: [(name: String, closure: () -> Void)] = []
    var setClosureNameClosure: ((String, @escaping () -> Void) -> Void)?

    func setClosure(name: String, _ closure: @escaping () -> Void) {
        setClosureNameCallsCount += 1
        setClosureNameReceivedArguments = (name: name, closure: closure)
        setClosureNameReceivedInvocations.append((name: name, closure: closure))
        setClosureNameClosure?(name, closure)
    }

}
class MultiNonEscapingClosureProtocolMock: MultiNonEscapingClosureProtocol {




    //MARK: - executeClosure

    var executeClosureNameCallsCount = 0
    var executeClosureNameCalled: Bool {
        return executeClosureNameCallsCount > 0
    }
    var executeClosureNameClosure: ((String, () -> Void) -> Void)?

    func executeClosure(name: String, _ closure: () -> Void) {
        executeClosureNameCallsCount += 1
        executeClosureNameClosure?(name, closure)
    }

}
class NonEscapingClosureProtocolMock: NonEscapingClosureProtocol {




    //MARK: - executeClosure

    var executeClosureCallsCount = 0
    var executeClosureCalled: Bool {
        return executeClosureCallsCount > 0
    }
    var executeClosureClosure: ((() -> Void) -> Void)?

    func executeClosure(_ closure: () -> Void) {
        executeClosureCallsCount += 1
        executeClosureClosure?(closure)
    }

}
class ReservedWordsProtocolMock: ReservedWordsProtocol {




    //MARK: - `continue`

    var continueWithCallsCount = 0
    var continueWithCalled: Bool {
        return continueWithCallsCount > 0
    }
    var continueWithReceivedMessage: (String)?
    var continueWithReceivedInvocations: [(String)] = []
    var continueWithReturnValue: String!
    var continueWithClosure: ((String) -> String)?

    func `continue`(with message: String) -> String {
        continueWithCallsCount += 1
        continueWithReceivedMessage = message
        continueWithReceivedInvocations.append(message)
        if let continueWithClosure = continueWithClosure {
            return continueWithClosure(message)
        } else {
            return continueWithReturnValue
        }
    }

}
class SameShortMethodNamesProtocolMock: SameShortMethodNamesProtocol {




    //MARK: - start

    var startCarOfCallsCount = 0
    var startCarOfCalled: Bool {
        return startCarOfCallsCount > 0
    }
    var startCarOfReceivedArguments: (car: String, model: String)?
    var startCarOfReceivedInvocations: [(car: String, model: String)] = []
    var startCarOfClosure: ((String, String) -> Void)?

    func start(car: String, of model: String) {
        startCarOfCallsCount += 1
        startCarOfReceivedArguments = (car: car, model: model)
        startCarOfReceivedInvocations.append((car: car, model: model))
        startCarOfClosure?(car, model)
    }

    //MARK: - start

    var startPlaneOfCallsCount = 0
    var startPlaneOfCalled: Bool {
        return startPlaneOfCallsCount > 0
    }
    var startPlaneOfReceivedArguments: (plane: String, model: String)?
    var startPlaneOfReceivedInvocations: [(plane: String, model: String)] = []
    var startPlaneOfClosure: ((String, String) -> Void)?

    func start(plane: String, of model: String) {
        startPlaneOfCallsCount += 1
        startPlaneOfReceivedArguments = (plane: plane, model: model)
        startPlaneOfReceivedInvocations.append((plane: plane, model: model))
        startPlaneOfClosure?(plane, model)
    }

}
class SingleOptionalParameterFunctionMock: SingleOptionalParameterFunction {




    //MARK: - send

    var sendMessageCallsCount = 0
    var sendMessageCalled: Bool {
        return sendMessageCallsCount > 0
    }
    var sendMessageReceivedMessage: (String)?
    var sendMessageReceivedInvocations: [(String)?] = []
    var sendMessageClosure: ((String?) -> Void)?

    func send(message: String?) {
        sendMessageCallsCount += 1
        sendMessageReceivedMessage = message
        sendMessageReceivedInvocations.append(message)
        sendMessageClosure?(message)
    }

}
class StaticMethodProtocolMock: StaticMethodProtocol {



    static func reset()
    {
         //MARK: - staticFunction
        staticFunctionCallsCount = 0
        staticFunctionReceived = nil
        staticFunctionReceivedInvocations = []
        staticFunctionClosure = nil


    }

    //MARK: - staticFunction

    static var staticFunctionCallsCount = 0
    static var staticFunctionCalled: Bool {
        return staticFunctionCallsCount > 0
    }
    static var staticFunctionReceived: (String)?
    static var staticFunctionReceivedInvocations: [(String)] = []
    static var staticFunctionReturnValue: String!
    static var staticFunctionClosure: ((String) -> String)?

    static func staticFunction(_ : String) -> String {
        staticFunctionCallsCount += 1
        staticFunctionReceived = 
        staticFunctionReceivedInvocations.append()
        if let staticFunctionClosure = staticFunctionClosure {
            return staticFunctionClosure()
        } else {
            return staticFunctionReturnValue
        }
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
        if let doOrThrowClosure = doOrThrowClosure {
            return try doOrThrowClosure()
        } else {
            return doOrThrowReturnValue
        }
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
class ThrowingVariablesProtocolMock: ThrowingVariablesProtocol {


    var titleCallsCount = 0
    var titleCalled: Bool {
        return titleCallsCount > 0
    }

    var title: String? {
        get throws {
            if let error = titleThrowableError {
                throw error
            }
            titleCallsCount += 1
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
            if let error = firstNameThrowableError {
                throw error
            }
            firstNameCallsCount += 1
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
