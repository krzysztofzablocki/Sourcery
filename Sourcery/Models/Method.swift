import Foundation

//typealias used to avoid types ambiguty in tests
typealias SourceryMethod = Method

final class MethodParameter: NSObject, AutoDiffable, Typed, NSCoding {
    /// Parameter external name
    var argumentLabel: String

    /// Parameter internal name
    let name: String

    /// Parameter type name
    let typeName: TypeName

    /// Actual parameter type, if known
    var type: Type?

    var typeAttributes: [String: Attribute] { return typeName.attributes }

    /// Underlying parser data, never to be used by anything else
    // sourcery: skipEquality, skipDescription, skipCoding
    internal var __parserData: Any?

    init(argumentLabel: String? = nil, name: String = "", typeName: TypeName) {
        self.typeName = typeName
        self.argumentLabel = argumentLabel ?? name
        self.name = name
    }

    // MethodParameter.NSCoding {
    required init?(coder aDecoder: NSCoder) {
        guard let argumentLabel: String = aDecoder.decode(forKey: "argumentLabel") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["argumentLabel"])); fatalError() }; self.argumentLabel = argumentLabel
        guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
        guard let typeName: TypeName = aDecoder.decode(forKey: "typeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typeName"])); fatalError() }; self.typeName = typeName
        self.type = aDecoder.decode(forKey: "type")

    }

    func encode(with aCoder: NSCoder) {

        aCoder.encode(self.argumentLabel, forKey: "argumentLabel")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.typeName, forKey: "typeName")
        aCoder.encode(self.type, forKey: "type")

    }
    // } MethodParameter.NSCoding
}

final class Method: NSObject, AutoDiffable, Annotated, NSCoding {
    /// Method name including arguments names, i.e. `foo(bar:)`
    let selectorName: String

    /// All method parameters
    var parameters: [MethodParameter]

    /// Method name without arguments names and parenthesis
    var shortName: String {
        return selectorName.range(of: "(").map({ selectorName.substring(to: $0.lowerBound) }) ?? selectorName
    }

    /// Name of the return type
    var returnTypeName: TypeName

    /// Actual method return type, if known.
    // sourcery: skipEquality
    // sourcery: skipDescription
    //weak to avoid reference cycle between type and its initializers
    weak var returnType: Type?

    // sourcery: skipEquality
    // sourcery: skipDescription
    var isOptionalReturnType: Bool {
        return returnTypeName.isOptional || isFailableInitializer
    }

    // sourcery: skipEquality
    // sourcery: skipDescription
    var isImplicitlyUnwrappedOptionalReturnType: Bool {
        return returnTypeName.isImplicitlyUnwrappedOptional
    }

    // sourcery: skipEquality
    // sourcery: skipDescription
    var unwrappedReturnTypeName: String {
        return returnTypeName.unwrappedTypeName
    }

    /// Whether this method throws or rethrows
    let `throws`: Bool

    /// Method access level
    let accessLevel: String

    /// Whether this is a static method
    let isStatic: Bool

    /// Whether this is a class method
    let isClass: Bool

    /// Whether this is a constructor
    var isInitializer: Bool {
        return selectorName.hasPrefix("init(")
    }

    /// Whether this is a failable initializer
    let isFailableInitializer: Bool

    /// Annotations, that were created with // sourcery: annotation1, other = "annotation value", alterantive = 2
    let annotations: [String: NSObject]

    let attributes: [String: Attribute]

    /// Underlying parser data, never to be used by anything else
    // sourcery: skipEquality, skipDescription, skipCoding
    internal var __parserData: Any?

    init(selectorName: String,
         parameters: [MethodParameter] = [],
         returnTypeName: TypeName = TypeName("Void"),
         throws: Bool = false,
         accessLevel: AccessLevel = .internal,
         isStatic: Bool = false,
         isClass: Bool = false,
         isFailableInitializer: Bool = false,
         attributes: [String: Attribute] = [:],
         annotations: [String: NSObject] = [:]) {

        self.selectorName = selectorName
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

    // Method.NSCoding {
        required init?(coder aDecoder: NSCoder) {
            guard let selectorName: String = aDecoder.decode(forKey: "selectorName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["selectorName"])); fatalError() }; self.selectorName = selectorName
            guard let parameters: [MethodParameter] = aDecoder.decode(forKey: "parameters") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["parameters"])); fatalError() }; self.parameters = parameters
            guard let returnTypeName: TypeName = aDecoder.decode(forKey: "returnTypeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["returnTypeName"])); fatalError() }; self.returnTypeName = returnTypeName
            self.returnType = aDecoder.decode(forKey: "returnType")
            self.`throws` = aDecoder.decode(forKey: "throws")
            guard let accessLevel: String = aDecoder.decode(forKey: "accessLevel") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["accessLevel"])); fatalError() }; self.accessLevel = accessLevel
            self.isStatic = aDecoder.decode(forKey: "isStatic")
            self.isClass = aDecoder.decode(forKey: "isClass")
            self.isFailableInitializer = aDecoder.decode(forKey: "isFailableInitializer")
            guard let annotations: [String: NSObject] = aDecoder.decode(forKey: "annotations") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["annotations"])); fatalError() }; self.annotations = annotations
            guard let attributes: [String: Attribute] = aDecoder.decode(forKey: "attributes") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["attributes"])); fatalError() }; self.attributes = attributes

        }

        func encode(with aCoder: NSCoder) {

            aCoder.encode(self.selectorName, forKey: "selectorName")
            aCoder.encode(self.parameters, forKey: "parameters")
            aCoder.encode(self.returnTypeName, forKey: "returnTypeName")
            aCoder.encode(self.returnType, forKey: "returnType")
            aCoder.encode(self.`throws`, forKey: "throws")
            aCoder.encode(self.accessLevel, forKey: "accessLevel")
            aCoder.encode(self.isStatic, forKey: "isStatic")
            aCoder.encode(self.isClass, forKey: "isClass")
            aCoder.encode(self.isFailableInitializer, forKey: "isFailableInitializer")
            aCoder.encode(self.annotations, forKey: "annotations")
            aCoder.encode(self.attributes, forKey: "attributes")

        }
        // } Method.NSCoding
}
