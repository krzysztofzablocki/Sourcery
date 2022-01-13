import Foundation

/// Describes closure type
@objcMembers public final class ClosureType: NSObject, SourceryModel {

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

// sourcery:inline:ClosureType.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let parameters: [ClosureParameter] = aDecoder.decode(forKey: "parameters") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["parameters"])); fatalError() }; self.parameters = parameters
            guard let returnTypeName: TypeName = aDecoder.decode(forKey: "returnTypeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["returnTypeName"])); fatalError() }; self.returnTypeName = returnTypeName
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
