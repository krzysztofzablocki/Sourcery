import Foundation

//typealias used to avoid types ambiguty in tests
typealias SourceryMethod = Method

class Method: NSObject, AutoDiffable {

    class Parameter: NSObject, AutoDiffable {
        /// Parameter external name
        var argumentLabel: String

        /// Parameter internal name
        let name: String

        /// Parameter type name
        let typeName: TypeName

        /// Actual parameter type, if known
        var type: Type?

        /// Is the variable optional?
        /// sourcery: skipEquality
        var isOptional: Bool { return typeName.isOptional }

        /// sourcery: skipEquality
        /// sourcery: skipDescription
        var unwrappedTypeName: String { return typeName.unwrappedTypeName }

        init(argumentLabel: String? = nil, name: String, typeName: String) {
            self.typeName = TypeName(typeName)
            self.argumentLabel = argumentLabel ?? name
            self.name = name
        }
    }

    /// All method parameters
    var parameters: [Parameter]

    /// Method name without arguments names and parenthesis
    var shortName: String {
        return selectorName.range(of: "(").map({ selectorName.substring(to: $0.lowerBound) }) ?? selectorName
    }

    /// Method name including arguments names, i.e. `foo(bar:)`
    let selectorName: String

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
    var unwrappedReturnTypeName: String {
        guard !isFailableInitializer else { return returnTypeName.unwrappedTypeName }
        return returnTypeName.unwrappedTypeName
    }

    /// Method access level
    let accessLevel: AccessLevel

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

    /// Underlying parser data, never to be used by anything else
    // sourcery: skipEquality, skipDescription
    internal var __parserData: Any?

    init(selectorName: String,
         parameters: [Parameter] = [],
         returnTypeName: String = "Void",
         accessLevel: AccessLevel = .internal,
         isStatic: Bool = false,
         isClass: Bool = false,
         isFailableInitializer: Bool = false,
         annotations: [String: NSObject] = [:]) {

        self.selectorName = selectorName
        self.parameters = parameters
        self.returnTypeName = TypeName(returnTypeName)
        self.accessLevel = accessLevel
        self.isStatic = isStatic
        self.isClass = isClass
        self.isFailableInitializer = isFailableInitializer
        self.annotations = annotations
    }

}
