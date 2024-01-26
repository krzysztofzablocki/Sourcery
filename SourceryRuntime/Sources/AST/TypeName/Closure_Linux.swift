#if !canImport(ObjectiveC)
import Foundation
// For DynamicMemberLookup we need to import Stencil,
// however, this is different from SourceryRuntime.content.generated.swift, because
// it cannot reference Stencil
import Stencil
/// Describes closure type

public final class ClosureType: NSObject, SourceryModel, Diffable, DynamicMemberLookup {
    public subscript(dynamicMember member: String) -> Any? {
        switch member {
            case "name":
                return name
            case "parameters":
                return parameters
            case "returnTypeName":
                return returnTypeName
            case "actualReturnTypeName":
                return actualReturnTypeName
            case "returnType":
                return returnType
            case "isOptionalReturnType":
                return isOptionalReturnType
            case "isImplicitlyUnwrappedOptionalReturnType":
                return isImplicitlyUnwrappedOptionalReturnType
            case "unwrappedReturnTypeName":
                return unwrappedReturnTypeName
            case "isAsync":
                return isAsync
            case "asyncKeyword":
                return asyncKeyword
            case "throws":
                return `throws`
            case "throwsOrRethrowsKeyword":
                return throwsOrRethrowsKeyword
            default:
                fatalError("unable to lookup: \(member) in \(self)")
        }
    }
    /// Type name used in declaration with stripped whitespaces and new lines
    public let name: String

    /// List of closure parameters
    public let parameters: [ClosureParameter]

    /// Return value type name
    public let returnTypeName: TypeName

    /// Actual return value type name if declaration uses typealias, otherwise just a `returnTypeName`
    public var actualReturnTypeName: TypeName {
        return returnTypeName.actualTypeName ?? returnTypeName
    }

    // sourcery: skipEquality, skipDescription
    /// Actual return value type, if known
    public var returnType: Type?

    // sourcery: skipEquality, skipDescription
    /// Whether return value type is optional
    public var isOptionalReturnType: Bool {
        return returnTypeName.isOptional
    }

    // sourcery: skipEquality, skipDescription
    /// Whether return value type is implicitly unwrapped optional
    public var isImplicitlyUnwrappedOptionalReturnType: Bool {
        return returnTypeName.isImplicitlyUnwrappedOptional
    }

    // sourcery: skipEquality, skipDescription
    /// Return value type name without attributes and optional type information
    public var unwrappedReturnTypeName: String {
        return returnTypeName.unwrappedTypeName
    }
    
    /// Whether method is async method
    public let isAsync: Bool

    /// async keyword
    public let asyncKeyword: String?

    /// Whether closure throws
    public let `throws`: Bool

    /// throws or rethrows keyword
    public let throwsOrRethrowsKeyword: String?

    /// :nodoc:
    public init(name: String, parameters: [ClosureParameter], returnTypeName: TypeName, returnType: Type? = nil, asyncKeyword: String? = nil, throwsOrRethrowsKeyword: String? = nil) {
        self.name = name
        self.parameters = parameters
        self.returnTypeName = returnTypeName
        self.returnType = returnType
        self.asyncKeyword = asyncKeyword
        self.isAsync = asyncKeyword != nil
        self.throwsOrRethrowsKeyword = throwsOrRethrowsKeyword
        self.`throws` = throwsOrRethrowsKeyword != nil
    }

    public var asSource: String {
        "\(parameters.asSource)\(asyncKeyword != nil ? " \(asyncKeyword!)" : "")\(throwsOrRethrowsKeyword != nil ? " \(throwsOrRethrowsKeyword!)" : "") -> \(returnTypeName.asSource)"
    }

    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "name = \(String(describing: self.name)), "
        string += "parameters = \(String(describing: self.parameters)), "
        string += "returnTypeName = \(String(describing: self.returnTypeName)), "
        string += "actualReturnTypeName = \(String(describing: self.actualReturnTypeName)), "
        string += "isAsync = \(String(describing: self.isAsync)), "
        string += "asyncKeyword = \(String(describing: self.asyncKeyword)), "
        string += "`throws` = \(String(describing: self.`throws`)), "
        string += "throwsOrRethrowsKeyword = \(String(describing: self.throwsOrRethrowsKeyword)), "
        string += "asSource = \(String(describing: self.asSource))"
        return string
    }

    public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? ClosureType else {
            results.append("Incorrect type <expected: ClosureType, received: \(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: castObject.name))
        results.append(contentsOf: DiffableResult(identifier: "parameters").trackDifference(actual: self.parameters, expected: castObject.parameters))
        results.append(contentsOf: DiffableResult(identifier: "returnTypeName").trackDifference(actual: self.returnTypeName, expected: castObject.returnTypeName))
        results.append(contentsOf: DiffableResult(identifier: "isAsync").trackDifference(actual: self.isAsync, expected: castObject.isAsync))
        results.append(contentsOf: DiffableResult(identifier: "asyncKeyword").trackDifference(actual: self.asyncKeyword, expected: castObject.asyncKeyword))
        results.append(contentsOf: DiffableResult(identifier: "`throws`").trackDifference(actual: self.`throws`, expected: castObject.`throws`))
        results.append(contentsOf: DiffableResult(identifier: "throwsOrRethrowsKeyword").trackDifference(actual: self.throwsOrRethrowsKeyword, expected: castObject.throwsOrRethrowsKeyword))
        return results
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.parameters)
        hasher.combine(self.returnTypeName)
        hasher.combine(self.isAsync)
        hasher.combine(self.asyncKeyword)
        hasher.combine(self.`throws`)
        hasher.combine(self.throwsOrRethrowsKeyword)
        return hasher.finalize()
    }

    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? ClosureType else { return false }
        if self.name != rhs.name { return false }
        if self.parameters != rhs.parameters { return false }
        if self.returnTypeName != rhs.returnTypeName { return false }
        if self.isAsync != rhs.isAsync { return false }
        if self.asyncKeyword != rhs.asyncKeyword { return false }
        if self.`throws` != rhs.`throws` { return false }
        if self.throwsOrRethrowsKeyword != rhs.throwsOrRethrowsKeyword { return false }
        return true
    }

// sourcery:inline:ClosureType.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { 
                withVaList(["name"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.name = name
            guard let parameters: [ClosureParameter] = aDecoder.decode(forKey: "parameters") else { 
                withVaList(["parameters"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.parameters = parameters
            guard let returnTypeName: TypeName = aDecoder.decode(forKey: "returnTypeName") else { 
                withVaList(["returnTypeName"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.returnTypeName = returnTypeName
            self.returnType = aDecoder.decode(forKey: "returnType")
            self.isAsync = aDecoder.decode(forKey: "isAsync")
            self.asyncKeyword = aDecoder.decode(forKey: "asyncKeyword")
            self.`throws` = aDecoder.decode(forKey: "`throws`")
            self.throwsOrRethrowsKeyword = aDecoder.decode(forKey: "throwsOrRethrowsKeyword")
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.parameters, forKey: "parameters")
            aCoder.encode(self.returnTypeName, forKey: "returnTypeName")
            aCoder.encode(self.returnType, forKey: "returnType")
            aCoder.encode(self.isAsync, forKey: "isAsync")
            aCoder.encode(self.asyncKeyword, forKey: "asyncKeyword")
            aCoder.encode(self.`throws`, forKey: "`throws`")
            aCoder.encode(self.throwsOrRethrowsKeyword, forKey: "throwsOrRethrowsKeyword")
        }
// sourcery:end

}
#endif
