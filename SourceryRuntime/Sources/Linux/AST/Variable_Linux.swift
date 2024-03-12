//
// Created by Krzysztof Zablocki on 13/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//
#if !canImport(ObjectiveC)
import Foundation

/// :nodoc:
public typealias SourceryVariable = Variable

/// Defines variable
public final class Variable: NSObject, SourceryModel, Typed, Annotated, Documented, Definition, Diffable, SourceryDynamicMemberLookup {
    public subscript(dynamicMember member: String) -> Any? {
        switch member {
        case "readAccess":
            return readAccess
        case "annotations":
            return annotations
        case "isOptional":
            return isOptional
        case "name":
            return name
        case "typeName":
            return typeName
        case "type":
            return type
        case "definedInType":
            return definedInType
        case "isStatic":
            return isStatic
        case "isAsync":
            return isAsync
        case "throws":
            return `throws`
        case "isArray":
            return isArray
        case "isDictionary":
            return isDictionary
        case "isDynamic":
            return isDynamic
        default:
            fatalError("unable to lookup: \(member) in \(self)")
        }
    }

    /// Variable name
    public let name: String

    /// Variable type name
    public let typeName: TypeName

    // sourcery: skipEquality, skipDescription
    /// Variable type, if known, i.e. if the type is declared in the scanned sources.
    /// For explanation, see <https://cdn.rawgit.com/krzysztofzablocki/Sourcery/master/docs/writing-templates.html#what-are-em-known-em-and-em-unknown-em-types>
    public var type: Type?

    /// Whether variable is computed and not stored
    public let isComputed: Bool
    
    /// Whether variable is async
    public let isAsync: Bool
    
    /// Whether variable throws
    public let `throws`: Bool

    /// Whether variable is static
    public let isStatic: Bool

    /// Variable read access level, i.e. `internal`, `private`, `fileprivate`, `public`, `open`
    public let readAccess: String

    /// Variable write access, i.e. `internal`, `private`, `fileprivate`, `public`, `open`.
    /// For immutable variables this value is empty string
    public let writeAccess: String

    /// composed access level
    /// sourcery: skipJSExport
    public var accessLevel: (read: AccessLevel, write: AccessLevel) {
        (read: AccessLevel(rawValue: readAccess) ?? .none, AccessLevel(rawValue: writeAccess) ?? .none)
    }

    /// Whether variable is mutable or not
    public var isMutable: Bool {
        return writeAccess != AccessLevel.none.rawValue
    }

    /// Variable default value expression
    public var defaultValue: String?

    /// Annotations, that were created with // sourcery: annotation1, other = "annotation value", alterantive = 2
    public var annotations: Annotations = [:]

    public var documentation: Documentation = []

    /// Variable attributes, i.e. `@IBOutlet`, `@IBInspectable`
    public var attributes: AttributeList

    /// Modifiers, i.e. `private`
    public var modifiers: [SourceryModifier]

    /// Whether variable is final or not
    public var isFinal: Bool {
        return modifiers.contains { $0.name == Attribute.Identifier.final.rawValue }
    }

    /// Whether variable is lazy or not
    public var isLazy: Bool {
        return modifiers.contains { $0.name == Attribute.Identifier.lazy.rawValue }
    }

    /// Whether variable is dynamic or not
    public var isDynamic: Bool {
        modifiers.contains { $0.name == Attribute.Identifier.dynamic.rawValue }
    }

    /// Reference to type name where the variable is defined,
    /// nil if defined outside of any `enum`, `struct`, `class` etc
    public internal(set) var definedInTypeName: TypeName?

    /// Reference to actual type name where the method is defined if declaration uses typealias, otherwise just a `definedInTypeName`
    public var actualDefinedInTypeName: TypeName? {
        return definedInTypeName?.actualTypeName ?? definedInTypeName
    }

    // sourcery: skipEquality, skipDescription
    /// Reference to actual type where the object is defined,
    /// nil if defined outside of any `enum`, `struct`, `class` etc or type is unknown
    public var definedInType: Type?

    /// :nodoc:
    public init(name: String = "",
                typeName: TypeName,
                type: Type? = nil,
                accessLevel: (read: AccessLevel, write: AccessLevel) = (.internal, .internal),
                isComputed: Bool = false,
                isAsync: Bool = false,
                `throws`: Bool = false,
                isStatic: Bool = false,
                defaultValue: String? = nil,
                attributes: AttributeList = [:],
                modifiers: [SourceryModifier] = [],
                annotations: [String: NSObject] = [:],
                documentation: [String] = [],
                definedInTypeName: TypeName? = nil) {

        self.name = name
        self.typeName = typeName
        self.type = type
        self.isComputed = isComputed
        self.isAsync = isAsync
        self.`throws` = `throws`
        self.isStatic = isStatic
        self.defaultValue = defaultValue
        self.readAccess = accessLevel.read.rawValue
        self.writeAccess = accessLevel.write.rawValue
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
        string.append("name = \(String(describing: self.name)), ")
        string.append("typeName = \(String(describing: self.typeName)), ")
        string.append("isComputed = \(String(describing: self.isComputed)), ")
        string.append("isAsync = \(String(describing: self.isAsync)), ")
        string.append("`throws` = \(String(describing: self.`throws`)), ")
        string.append("isStatic = \(String(describing: self.isStatic)), ")
        string.append("readAccess = \(String(describing: self.readAccess)), ")
        string.append("writeAccess = \(String(describing: self.writeAccess)), ")
        string.append("accessLevel = \(String(describing: self.accessLevel)), ")
        string.append("isMutable = \(String(describing: self.isMutable)), ")
        string.append("defaultValue = \(String(describing: self.defaultValue)), ")
        string.append("annotations = \(String(describing: self.annotations)), ")
        string.append("documentation = \(String(describing: self.documentation)), ")
        string.append("attributes = \(String(describing: self.attributes)), ")
        string.append("modifiers = \(String(describing: self.modifiers)), ")
        string.append("isFinal = \(String(describing: self.isFinal)), ")
        string.append("isLazy = \(String(describing: self.isLazy)), ")
        string.append("isDynamic = \(String(describing: self.isDynamic)), ")
        string.append("definedInTypeName = \(String(describing: self.definedInTypeName)), ")
        string.append("actualDefinedInTypeName = \(String(describing: self.actualDefinedInTypeName))")
        return string
    }

    public func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let castObject = object as? Variable else {
            results.append("Incorrect type <expected: Variable, received: \(Swift.type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: castObject.name))
        results.append(contentsOf: DiffableResult(identifier: "typeName").trackDifference(actual: self.typeName, expected: castObject.typeName))
        results.append(contentsOf: DiffableResult(identifier: "isComputed").trackDifference(actual: self.isComputed, expected: castObject.isComputed))
        results.append(contentsOf: DiffableResult(identifier: "isAsync").trackDifference(actual: self.isAsync, expected: castObject.isAsync))
        results.append(contentsOf: DiffableResult(identifier: "`throws`").trackDifference(actual: self.`throws`, expected: castObject.`throws`))
        results.append(contentsOf: DiffableResult(identifier: "isStatic").trackDifference(actual: self.isStatic, expected: castObject.isStatic))
        results.append(contentsOf: DiffableResult(identifier: "readAccess").trackDifference(actual: self.readAccess, expected: castObject.readAccess))
        results.append(contentsOf: DiffableResult(identifier: "writeAccess").trackDifference(actual: self.writeAccess, expected: castObject.writeAccess))
        results.append(contentsOf: DiffableResult(identifier: "defaultValue").trackDifference(actual: self.defaultValue, expected: castObject.defaultValue))
        results.append(contentsOf: DiffableResult(identifier: "annotations").trackDifference(actual: self.annotations, expected: castObject.annotations))
        results.append(contentsOf: DiffableResult(identifier: "documentation").trackDifference(actual: self.documentation, expected: castObject.documentation))
        results.append(contentsOf: DiffableResult(identifier: "attributes").trackDifference(actual: self.attributes, expected: castObject.attributes))
        results.append(contentsOf: DiffableResult(identifier: "modifiers").trackDifference(actual: self.modifiers, expected: castObject.modifiers))
        results.append(contentsOf: DiffableResult(identifier: "definedInTypeName").trackDifference(actual: self.definedInTypeName, expected: castObject.definedInTypeName))
        return results
    }

    /// :nodoc:
    // sourcery: skipJSExport
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.typeName)
        hasher.combine(self.isComputed)
        hasher.combine(self.isAsync)
        hasher.combine(self.`throws`)
        hasher.combine(self.isStatic)
        hasher.combine(self.readAccess)
        hasher.combine(self.writeAccess)
        hasher.combine(self.defaultValue)
        hasher.combine(self.annotations)
        hasher.combine(self.documentation)
        hasher.combine(self.attributes)
        hasher.combine(self.modifiers)
        hasher.combine(self.definedInTypeName)
        return hasher.finalize()
    }

    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Variable else { return false }
        if self.name != rhs.name { return false }
        if self.typeName != rhs.typeName { return false }
        if self.isComputed != rhs.isComputed { return false }
        if self.isAsync != rhs.isAsync { return false }
        if self.`throws` != rhs.`throws` { return false }
        if self.isStatic != rhs.isStatic { return false }
        if self.readAccess != rhs.readAccess { return false }
        if self.writeAccess != rhs.writeAccess { return false }
        if self.defaultValue != rhs.defaultValue { return false }
        if self.annotations != rhs.annotations { return false }
        if self.documentation != rhs.documentation { return false }
        if self.attributes != rhs.attributes { return false }
        if self.modifiers != rhs.modifiers { return false }
        if self.definedInTypeName != rhs.definedInTypeName { return false }
        return true
    }

// sourcery:inline:Variable.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { 
                withVaList(["name"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.name = name
            guard let typeName: TypeName = aDecoder.decode(forKey: "typeName") else { 
                withVaList(["typeName"]) { arguments in
                    NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: arguments)
                }
                fatalError()
             }; self.typeName = typeName
            self.type = aDecoder.decode(forKey: "type")
            self.isComputed = aDecoder.decode(forKey: "isComputed")
            self.isAsync = aDecoder.decode(forKey: "isAsync")
            self.`throws` = aDecoder.decode(forKey: "`throws`")
            self.isStatic = aDecoder.decode(forKey: "isStatic")
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
            self.defaultValue = aDecoder.decode(forKey: "defaultValue")
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
            self.definedInTypeName = aDecoder.decode(forKey: "definedInTypeName")
            self.definedInType = aDecoder.decode(forKey: "definedInType")
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.typeName, forKey: "typeName")
            aCoder.encode(self.type, forKey: "type")
            aCoder.encode(self.isComputed, forKey: "isComputed")
            aCoder.encode(self.isAsync, forKey: "isAsync")
            aCoder.encode(self.`throws`, forKey: "`throws`")
            aCoder.encode(self.isStatic, forKey: "isStatic")
            aCoder.encode(self.readAccess, forKey: "readAccess")
            aCoder.encode(self.writeAccess, forKey: "writeAccess")
            aCoder.encode(self.defaultValue, forKey: "defaultValue")
            aCoder.encode(self.annotations, forKey: "annotations")
            aCoder.encode(self.documentation, forKey: "documentation")
            aCoder.encode(self.attributes, forKey: "attributes")
            aCoder.encode(self.modifiers, forKey: "modifiers")
            aCoder.encode(self.definedInTypeName, forKey: "definedInTypeName")
            aCoder.encode(self.definedInType, forKey: "definedInType")
        }
// sourcery:end
}
#endif
