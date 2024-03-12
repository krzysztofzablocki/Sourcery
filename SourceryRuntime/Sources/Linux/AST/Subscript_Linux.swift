#if !canImport(ObjectiveC)
import Foundation

/// Describes subscript
public final class Subscript: NSObject, SourceryModel, Annotated, Documented, Definition, Diffable, SourceryDynamicMemberLookup {

    public subscript(dynamicMember member: String) -> Any? {
        switch member {
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
            case "isFinal":
                return isFinal
            case "readAccess":
                return readAccess
            case "writeAccess":
                return writeAccess
            case "isAsync":
                return isAsync
            case "throws":
                return `throws`
            case "isMutable":
                return isMutable
            case "annotations":
                return annotations
            case "documentation":
                return documentation
            case "definedInTypeName":
                return definedInTypeName
            case "actualDefinedInTypeName":
                return actualDefinedInTypeName
            case "attributes":
                return attributes
            case "modifiers":
                return modifiers
            case "genericParameters":
                return genericParameters
            case "genericRequirements":
                return genericRequirements
            case "isGeneric":
                return isGeneric
            default:
                fatalError("unable to lookup: \(member) in \(self)")
        }
    }

    /// Method parameters
    public var parameters: [MethodParameter]

    /// Return value type name used in declaration, including generic constraints, i.e. `where T: Equatable`
    public var returnTypeName: TypeName

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

    /// Whether method is final
    public var isFinal: Bool {
        modifiers.contains { $0.name == "final" }
    }

    /// Variable read access level, i.e. `internal`, `private`, `fileprivate`, `public`, `open`
    public let readAccess: String

    /// Variable write access, i.e. `internal`, `private`, `fileprivate`, `public`, `open`.
    /// For immutable variables this value is empty string
    public var writeAccess: String

    /// Whether subscript is async
    public let isAsync: Bool

    /// Whether subscript throws
    public let `throws`: Bool

    /// Whether variable is mutable or not
    public var isMutable: Bool {
        return writeAccess != AccessLevel.none.rawValue
    }

    /// Annotations, that were created with // sourcery: annotation1, other = "annotation value", alterantive = 2
    public let annotations: Annotations

    public let documentation: Documentation

    /// Reference to type name where the method is defined,
    /// nil if defined outside of any `enum`, `struct`, `class` etc
    public let definedInTypeName: TypeName?

    /// Reference to actual type name where the method is defined if declaration uses typealias, otherwise just a `definedInTypeName`
    public var actualDefinedInTypeName: TypeName? {
        return definedInTypeName?.actualTypeName ?? definedInTypeName
    }

    // sourcery: skipEquality, skipDescription
    /// Reference to actual type where the object is defined,
    /// nil if defined outside of any `enum`, `struct`, `class` etc or type is unknown
    public var definedInType: Type?

    /// Method attributes, i.e. `@discardableResult`
    public let attributes: AttributeList

    /// Method modifiers, i.e. `private`
    public let modifiers: [SourceryModifier]

    /// list of generic parameters
    public let genericParameters: [GenericParameter]

    /// list of generic requirements
    public let genericRequirements: [GenericRequirement]

    /// Whether subscript is generic or not
    public var isGeneric: Bool {
        return genericParameters.isEmpty == false
    }

    // Underlying parser data, never to be used by anything else
    // sourcery: skipEquality, skipDescription, skipCoding, skipJSExport
    /// :nodoc:
    public var __parserData: Any?

    /// :nodoc:
    public init(parameters: [MethodParameter] = [],
                returnTypeName: TypeName,
                accessLevel: (read: AccessLevel, write: AccessLevel) = (.internal, .internal),
                isAsync: Bool = false,
                `throws`: Bool = false,
                genericParameters: [GenericParameter] = [],
                genericRequirements: [GenericRequirement] = [],
                attributes: AttributeList = [:],
                modifiers: [SourceryModifier] = [],
                annotations: [String: NSObject] = [:],
                documentation: [String] = [],
                definedInTypeName: TypeName? = nil) {

        self.parameters = parameters
        self.returnTypeName = returnTypeName
        self.readAccess = accessLevel.read.rawValue
        self.writeAccess = accessLevel.write.rawValue
        self.isAsync = isAsync
        self.throws = `throws`
        self.genericParameters = genericParameters
        self.genericRequirements = genericRequirements
        self.attributes = attributes
        self.modifiers = modifiers
        self.annotations = annotations
        self.documentation = documentation
        self.definedInTypeName = definedInTypeName
    }

    /// :nodoc:
    // sourcery: skipJSExport
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string.append("parameters = \(String(describing: self.parameters)), ")
        string.append("returnTypeName = \(String(describing: self.returnTypeName)), ")
        string.append("actualReturnTypeName = \(String(describing: self.actualReturnTypeName)), ")
        string.append("isFinal = \(String(describing: self.isFinal)), ")
        string.append("readAccess = \(String(describing: self.readAccess)), ")
        string.append("writeAccess = \(String(describing: self.writeAccess)), ")
        string.append("isAsync = \(String(describing: self.isAsync)), ")
        string.append("`throws` = \(String(describing: self.throws)), ")
        string.append("isMutable = \(String(describing: self.isMutable)), ")
        string.append("annotations = \(String(describing: self.annotations)), ")
        string.append("documentation = \(String(describing: self.documentation)), ")
        string.append("definedInTypeName = \(String(describing: self.definedInTypeName)), ")
        string.append("actualDefinedInTypeName = \(String(describing: self.actualDefinedInTypeName)), ")
        string.append("genericParameters = \(String(describing: self.genericParameters)), ")
        string.append("genericRequirements = \(String(describing: self.genericRequirements)), ")
        string.append("isGeneric = \(String(describing: self.isGeneric)), ")
        string.append("attributes = \(String(describing: self.attributes)), ")
        string.append("modifiers = \(String(describing: self.modifiers))")
        return string
    }

    public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? Subscript else {
            results.append("Incorrect type <expected: Subscript, received: \(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "parameters").trackDifference(actual: self.parameters, expected: castObject.parameters))
        results.append(contentsOf: DiffableResult(identifier: "returnTypeName").trackDifference(actual: self.returnTypeName, expected: castObject.returnTypeName))
        results.append(contentsOf: DiffableResult(identifier: "readAccess").trackDifference(actual: self.readAccess, expected: castObject.readAccess))
        results.append(contentsOf: DiffableResult(identifier: "writeAccess").trackDifference(actual: self.writeAccess, expected: castObject.writeAccess))
        results.append(contentsOf: DiffableResult(identifier: "isAsync").trackDifference(actual: self.isAsync, expected: castObject.isAsync))
        results.append(contentsOf: DiffableResult(identifier: "`throws`").trackDifference(actual: self.throws, expected: castObject.throws))
        results.append(contentsOf: DiffableResult(identifier: "annotations").trackDifference(actual: self.annotations, expected: castObject.annotations))
        results.append(contentsOf: DiffableResult(identifier: "documentation").trackDifference(actual: self.documentation, expected: castObject.documentation))
        results.append(contentsOf: DiffableResult(identifier: "definedInTypeName").trackDifference(actual: self.definedInTypeName, expected: castObject.definedInTypeName))
        results.append(contentsOf: DiffableResult(identifier: "genericParameters").trackDifference(actual: self.genericParameters, expected: castObject.genericParameters))
        results.append(contentsOf: DiffableResult(identifier: "genericRequirements").trackDifference(actual: self.genericRequirements, expected: castObject.genericRequirements))
        results.append(contentsOf: DiffableResult(identifier: "attributes").trackDifference(actual: self.attributes, expected: castObject.attributes))
        results.append(contentsOf: DiffableResult(identifier: "modifiers").trackDifference(actual: self.modifiers, expected: castObject.modifiers))
        return results
    }

    /// :nodoc:
    // sourcery: skipJSExport
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.parameters)
        hasher.combine(self.returnTypeName)
        hasher.combine(self.readAccess)
        hasher.combine(self.writeAccess)
        hasher.combine(self.isAsync)
        hasher.combine(self.throws)
        hasher.combine(self.annotations)
        hasher.combine(self.documentation)
        hasher.combine(self.definedInTypeName)
        hasher.combine(self.genericParameters)
        hasher.combine(self.genericRequirements)
        hasher.combine(self.attributes)
        hasher.combine(self.modifiers)
        return hasher.finalize()
    }

    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Subscript else { return false }
        if self.parameters != rhs.parameters { return false }
        if self.returnTypeName != rhs.returnTypeName { return false }
        if self.readAccess != rhs.readAccess { return false }
        if self.writeAccess != rhs.writeAccess { return false }
        if self.isAsync != rhs.isAsync { return false }
        if self.throws != rhs.throws { return false }
        if self.annotations != rhs.annotations { return false }
        if self.documentation != rhs.documentation { return false }
        if self.definedInTypeName != rhs.definedInTypeName { return false }
        if self.genericParameters != rhs.genericParameters { return false }
        if self.genericRequirements != rhs.genericRequirements { return false }
        if self.attributes != rhs.attributes { return false }
        if self.modifiers != rhs.modifiers { return false }
        return true
    }

// sourcery:inline:Subscript.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let parameters: [MethodParameter] = aDecoder.decode(forKey: "parameters") else { 
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
            guard let readAccess: String = aDecoder.decode(forKey: "readAccess") else { 
                withVaList(["readAccess"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.readAccess = readAccess
            guard let writeAccess: String = aDecoder.decode(forKey: "writeAccess") else { 
                withVaList(["writeAccess"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.writeAccess = writeAccess
            self.isAsync = aDecoder.decode(forKey: "isAsync")
            self.`throws` = aDecoder.decode(forKey: "`throws`")
            guard let annotations: Annotations = aDecoder.decode(forKey: "annotations") else { 
                withVaList(["annotations"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.annotations = annotations
            guard let documentation: Documentation = aDecoder.decode(forKey: "documentation") else { 
                withVaList(["documentation"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.documentation = documentation
            self.definedInTypeName = aDecoder.decode(forKey: "definedInTypeName")
            self.definedInType = aDecoder.decode(forKey: "definedInType")
            guard let attributes: AttributeList = aDecoder.decode(forKey: "attributes") else { 
                withVaList(["attributes"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.attributes = attributes
            guard let modifiers: [SourceryModifier] = aDecoder.decode(forKey: "modifiers") else { 
                withVaList(["modifiers"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.modifiers = modifiers
            guard let genericParameters: [GenericParameter] = aDecoder.decode(forKey: "genericParameters") else { 
                withVaList(["genericParameters"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.genericParameters = genericParameters
            guard let genericRequirements: [GenericRequirement] = aDecoder.decode(forKey: "genericRequirements") else { 
                withVaList(["genericRequirements"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.genericRequirements = genericRequirements
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.parameters, forKey: "parameters")
            aCoder.encode(self.returnTypeName, forKey: "returnTypeName")
            aCoder.encode(self.returnType, forKey: "returnType")
            aCoder.encode(self.readAccess, forKey: "readAccess")
            aCoder.encode(self.writeAccess, forKey: "writeAccess")
            aCoder.encode(self.isAsync, forKey: "isAsync")
            aCoder.encode(self.`throws`, forKey: "`throws`")
            aCoder.encode(self.annotations, forKey: "annotations")
            aCoder.encode(self.documentation, forKey: "documentation")
            aCoder.encode(self.definedInTypeName, forKey: "definedInTypeName")
            aCoder.encode(self.definedInType, forKey: "definedInType")
            aCoder.encode(self.attributes, forKey: "attributes")
            aCoder.encode(self.modifiers, forKey: "modifiers")
            aCoder.encode(self.genericParameters, forKey: "genericParameters")
            aCoder.encode(self.genericRequirements, forKey: "genericRequirements")
        }
// sourcery:end

}
#endif
