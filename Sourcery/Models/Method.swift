import Foundation

//typealias used to avoid types ambiguty in tests
typealias SourceryMethod = Method

/// Describes method parameter
final class MethodParameter: NSObject, SourceryModel, Typed, Annotated {
    /// Parameter external name
    var argumentLabel: String?

    /// Parameter internal name
    let name: String

    /// Parameter type name
    let typeName: TypeName

    /// Parameter type, if known
    // sourcery: skipEquality, skipDescription
    var type: Type?

    /// Parameter type attributes, i.e. `@escaping`
    var typeAttributes: [String: Attribute] { return typeName.attributes }

    /// Method parameter default value expression
    var defaultValue: String?

    /// Annotations, that were created with // sourcery: annotation1, other = "annotation value", alterantive = 2
    var annotations: [String: NSObject] = [:]

    /// Underlying parser data, never to be used by anything else
    // sourcery: skipEquality, skipDescription, skipCoding, skipJSExport
    internal var __parserData: Any?

    init(argumentLabel: String?, name: String = "", typeName: TypeName, type: Type? = nil, defaultValue: String? = nil, annotations: [String: NSObject] = [:]) {
        self.typeName = typeName
        self.argumentLabel = argumentLabel
        self.name = name
        self.type = type
        self.defaultValue = defaultValue
        self.annotations = annotations
    }

    init(name: String = "", typeName: TypeName, type: Type? = nil, defaultValue: String? = nil, annotations: [String: NSObject] = [:]) {
        self.typeName = typeName
        self.argumentLabel = name
        self.name = name
        self.type = type
        self.defaultValue = defaultValue
        self.annotations = annotations
    }

    // sourcery:inline:MethodParameter.AutoCoding
        required init?(coder aDecoder: NSCoder) {
            self.argumentLabel = aDecoder.decode(forKey: "argumentLabel")
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let typeName: TypeName = aDecoder.decode(forKey: "typeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typeName"])); fatalError() }; self.typeName = typeName
            self.type = aDecoder.decode(forKey: "type")
            self.defaultValue = aDecoder.decode(forKey: "defaultValue")
            guard let annotations: [String: NSObject] = aDecoder.decode(forKey: "annotations") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["annotations"])); fatalError() }; self.annotations = annotations
        }

        func encode(with aCoder: NSCoder) {
            aCoder.encode(self.argumentLabel, forKey: "argumentLabel")
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.typeName, forKey: "typeName")
            aCoder.encode(self.type, forKey: "type")
            aCoder.encode(self.defaultValue, forKey: "defaultValue")
            aCoder.encode(self.annotations, forKey: "annotations")
        }
        // sourcery:end
}

/// Describes method
final class Method: NSObject, SourceryModel, Annotated {

    /// Full method name, including generic constraints, i.e. `foo<T>(bar: T) where T: Equatable`
    let name: String

    /// Method name including arguments names, i.e. `foo(bar:)`
    // sourcery: skipDescription
    let selectorName: String

    /// Method name without arguments names and parenthesis, i.e. `foo<t>`
    var shortName: String {
        return name.range(of: "(").map({ name.substring(to: $0.lowerBound) }) ?? name
    }

    /// Method name without arguments names, parenthesis and generic types, i.e. `foo`
    var callName: String {
        return shortName.range(of: "<").map({ shortName.substring(to: $0.lowerBound) }) ?? shortName
    }

    /// Method parameters
    var parameters: [MethodParameter]

    /// Return value type name
    var returnTypeName: TypeName

    /// Actual return value type name, if it is a typealias
    var actualReturnTypeName: TypeName {
        return returnTypeName.actualTypeName ?? returnTypeName
    }

    /// Actual return value type, if known
    // sourcery: skipEquality, skipDescription
    var returnType: Type?

    /// Whether return value type is optional
    // sourcery: skipEquality, skipDescription
    var isOptionalReturnType: Bool {
        return returnTypeName.isOptional || isFailableInitializer
    }

    /// Whether return value type is implicitly unwrapped optional
    // sourcery: skipEquality, skipDescription
    var isImplicitlyUnwrappedOptionalReturnType: Bool {
        return returnTypeName.isImplicitlyUnwrappedOptional
    }

    /// Return value type name without attributes and optional type information
    // sourcery: skipEquality, skipDescription
    var unwrappedReturnTypeName: String {
        return returnTypeName.unwrappedTypeName
    }

    /// Whether method throws or rethrows
    let `throws`: Bool

    /// Method access level, i.e. `internal`, `private`, `fileprivate`, `public`, `open`
    let accessLevel: String

    /// Whether method is a static method
    let isStatic: Bool

    /// Whether method is a class method
    let isClass: Bool

    /// Whether method is a constructor
    var isInitializer: Bool {
        return selectorName.hasPrefix("init(")
    }

    /// Whether method is a failable initializer
    let isFailableInitializer: Bool

    /// Whether method is a convenience initializer
    public var isConvenienceInitialiser: Bool {
        return attributes[Attribute.Identifier.convenience.name] != nil
    }

    /// Annotations, that were created with // sourcery: annotation1, other = "annotation value", alterantive = 2
    let annotations: [String: NSObject]

    /// Method attributes, i.e. `@discardableResult`
    let attributes: [String: Attribute]

    // Underlying parser data, never to be used by anything else
    // sourcery: skipEquality, skipDescription, skipCoding, skipJSExport
    internal var __parserData: Any?

    init(name: String,
         selectorName: String? = nil,
         parameters: [MethodParameter] = [],
         returnTypeName: TypeName = TypeName("Void"),
         throws: Bool = false,
         accessLevel: AccessLevel = .internal,
         isStatic: Bool = false,
         isClass: Bool = false,
         isFailableInitializer: Bool = false,
         attributes: [String: Attribute] = [:],
         annotations: [String: NSObject] = [:]) {

        self.name = name
        self.selectorName = selectorName ?? name
        self.parameters = parameters
        self.returnTypeName = returnTypeName
        self.throws = `throws`
        self.accessLevel = accessLevel.rawValue
        self.isStatic = isStatic
        self.isClass = isClass
        self.isFailableInitializer = isFailableInitializer
        self.attributes = attributes
        self.annotations = annotations
    }

    // sourcery:inline:Method.AutoCoding
        required init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let selectorName: String = aDecoder.decode(forKey: "selectorName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["selectorName"])); fatalError() }; self.selectorName = selectorName
            guard let parameters: [MethodParameter] = aDecoder.decode(forKey: "parameters") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["parameters"])); fatalError() }; self.parameters = parameters
            guard let returnTypeName: TypeName = aDecoder.decode(forKey: "returnTypeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["returnTypeName"])); fatalError() }; self.returnTypeName = returnTypeName
            self.returnType = aDecoder.decode(forKey: "returnType")
            self.`throws` = aDecoder.decode(forKey: "`throws`")
            guard let accessLevel: String = aDecoder.decode(forKey: "accessLevel") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["accessLevel"])); fatalError() }; self.accessLevel = accessLevel
            self.isStatic = aDecoder.decode(forKey: "isStatic")
            self.isClass = aDecoder.decode(forKey: "isClass")
            self.isFailableInitializer = aDecoder.decode(forKey: "isFailableInitializer")
            guard let annotations: [String: NSObject] = aDecoder.decode(forKey: "annotations") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["annotations"])); fatalError() }; self.annotations = annotations
            guard let attributes: [String: Attribute] = aDecoder.decode(forKey: "attributes") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["attributes"])); fatalError() }; self.attributes = attributes
        }

        func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.selectorName, forKey: "selectorName")
            aCoder.encode(self.parameters, forKey: "parameters")
            aCoder.encode(self.returnTypeName, forKey: "returnTypeName")
            aCoder.encode(self.returnType, forKey: "returnType")
            aCoder.encode(self.`throws`, forKey: "`throws`")
            aCoder.encode(self.accessLevel, forKey: "accessLevel")
            aCoder.encode(self.isStatic, forKey: "isStatic")
            aCoder.encode(self.isClass, forKey: "isClass")
            aCoder.encode(self.isFailableInitializer, forKey: "isFailableInitializer")
            aCoder.encode(self.annotations, forKey: "annotations")
            aCoder.encode(self.attributes, forKey: "attributes")
        }
     // sourcery:end
}
