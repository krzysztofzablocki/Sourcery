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
        let typeName: String
        
        /// Actual parameter type, if known
        var type: Type?

        /// Is the parameter optional?
        var isOptional: Bool {
            if typeName.hasSuffix("?") || typeName.hasPrefix("Optional<") {
                return true
            }
            return false
        }
        
        // sourcery: skipEquality
        // sourcery: skipDescription
        var unwrappedTypeName: String {
            guard isOptional else { return typeName }
            if typeName.hasSuffix("?") {
                return String(typeName.characters.dropLast())
            } else {
                return String(typeName.characters.dropFirst("Optional<".characters.count).dropLast())
            }
        }

        init(argumentLabel: String? = nil, name: String, typeName: String) {
            self.typeName = typeName
            self.argumentLabel = argumentLabel ?? name
            self.name = name
        }
    }
    
    /// All method parameters
    var parameters: [Parameter]
    
    /// Method name without arguments names and parenthesis
    var shortName: String {
        return fullName.range(of: "(").map({ fullName.substring(to: $0.lowerBound) }) ?? fullName
    }
    
    /// Method name including arguments names
    let fullName: String
    
    /// Name of the return type
    var returnTypeName: String
    
    /// Actual method return type, if known.
    // sourcery: skipEquality
    // sourcery: skipDescription
    //weak to avoid reference cycle between type and its initializers
    weak var returnType: Type?
    
    // sourcery: skipEquality
    // sourcery: skipDescription
    var isOptionalReturnType: Bool {
        if returnTypeName.hasSuffix("?") || returnTypeName.hasPrefix("Optional<") {
            return true
        }
        return isFailableInitializer
    }

    // sourcery: skipEquality
    // sourcery: skipDescription
    var unwrappedReturnTypeName: String {
        guard isOptionalReturnType else { return returnTypeName }
        guard !isFailableInitializer else { return returnTypeName }
        
        if returnTypeName.hasSuffix("?") {
            return String(returnTypeName.characters.dropLast())
        } else {
            return String(returnTypeName.characters.dropFirst("Optional<".characters.count).dropLast())
        }
    }
    
    /// Method access level
    let accessLevel: AccessLevel
    
    /// Whether this is a static method
    let isStatic: Bool

    /// Whether this is a class method
    let isClass: Bool
    
    /// Whether this is a constructor
    var isInitializer: Bool {
        return fullName.hasPrefix("init(")
    }
    
    /// Whether this is a failable initializer
    let isFailableInitializer: Bool
    
    /// Annotations, that were created with // sourcery: annotation1, other = "annotation value", alterantive = 2
    let annotations: [String: NSObject]

    /// Underlying parser data, never to be used by anything else
    // sourcery: skipEquality, skipDescription
    internal var __parserData: Any?

    init(fullName: String,
         parameters: [Parameter] = [],
         returnTypeName: String = "Void",
         accessLevel: AccessLevel = .internal,
         isStatic: Bool = false,
         isClass: Bool = false,
         isFailableInitializer: Bool = false,
         annotations: [String: NSObject] = [:]) {
        
        self.fullName = fullName
        self.parameters = parameters
        self.returnTypeName = returnTypeName
        self.accessLevel = accessLevel
        self.isStatic = isStatic
        self.isClass = isClass
        self.isFailableInitializer = isFailableInitializer
        self.annotations = annotations
    }
    
}
