//
// Created by Krzysztof Zablocki on 11/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

/// :nodoc:
public typealias AttributeList = [String: [Attribute]]

/// Defines Swift type
@objcMembers public class Type: NSObject, SourceryModel, Annotated, Documented {

    /// :nodoc:
    public var module: String?

    /// Imports that existed in the file that contained this type declaration
    public var imports: [Import] = []

    // sourcery: skipEquality
    /// Imports existed in all files containing this type and all its super classes/protocols
    public var allImports: [Import] {
        return self.unique({ $0.gatherAllImports() }, filter: { $0 == $1 })
    }

    private func gatherAllImports() -> [Import] {
        var allImports: [Import] = Array(self.imports)

        self.basedTypes.values.forEach { (basedType) in
            allImports.append(contentsOf: basedType.imports)
        }
        return allImports
    }

    // All local typealiases
    // sourcery: skipJSExport
    /// :nodoc:
    public var typealiases: [String: Typealias] {
        didSet {
            typealiases.values.forEach { $0.parent = self }
        }
    }

    // sourcery: skipJSExport
    /// Whether declaration is an extension of some type
    public var isExtension: Bool

    // sourcery: forceEquality
    /// Kind of type declaration, i.e. `enum`, `struct`, `class`, `protocol` or `extension`
    public var kind: String { return isExtension ? "extension" : "unknown" }

    /// Type access level, i.e. `internal`, `private`, `fileprivate`, `public`, `open`
    public let accessLevel: String

    /// Type name in global scope. For inner types includes the name of its containing type, i.e. `Type.Inner`
    public var name: String {
        guard let parentName = parent?.name else { return localName }
        return "\(parentName).\(localName)"
    }

    // sourcery: skipCoding
    /// Whether the type has been resolved as unknown extension
    public var isUnknownExtension: Bool = false

    // sourcery: skipDescription
    /// Global type name including module name, unless it's an extension of unknown type
    public var globalName: String {
        guard let module = module, !isUnknownExtension else { return name }
        return "\(module).\(name)"
    }

    /// Whether type is generic
    public var isGeneric: Bool

    /// Type name in its own scope.
    public var localName: String

    // sourcery: skipEquality, skipDescription
    /// Variables defined in this type only, inluding variables defined in its extensions,
    /// but not including variables inherited from superclasses (for classes only) and protocols
    public var variables: [Variable] {
        unique({ $0.rawVariables }, filter: Self.uniqueVariableFilter)
    }

    /// Unfiltered (can contain duplications from extensions) variables defined in this type only, inluding variables defined in its extensions,
    /// but not including variables inherited from superclasses (for classes only) and protocols
    public var rawVariables: [Variable]

    // sourcery: skipEquality, skipDescription
    /// All variables defined for this type, including variables defined in extensions,
    /// in superclasses (for classes only) and protocols
    public var allVariables: [Variable] {
        return flattenAll({
            return $0.variables
        },
        isExtension: { $0.definedInType?.isExtension == true },
        filter: { all, extracted in
            !all.contains(where: { Self.uniqueVariableFilter($0, rhs: extracted) })
        })
    }

    private static func uniqueVariableFilter(_ lhs: Variable, rhs: Variable) -> Bool {
        return lhs.name == rhs.name && lhs.isStatic == rhs.isStatic && lhs.typeName == rhs.typeName
    }

    // sourcery: skipEquality, skipDescription
    /// Methods defined in this type only, inluding methods defined in its extensions,
    /// but not including methods inherited from superclasses (for classes only) and protocols
    public var methods: [Method] {
        unique({ $0.rawMethods }, filter: Self.uniqueMethodFilter)
    }

    /// Unfiltered (can contain duplications from extensions) methods defined in this type only, inluding methods defined in its extensions,
    /// but not including methods inherited from superclasses (for classes only) and protocols
    public var rawMethods: [Method]

    // sourcery: skipEquality, skipDescription
    /// All methods defined for this type, including methods defined in extensions,
    /// in superclasses (for classes only) and protocols
    public var allMethods: [Method] {
        return flattenAll({
            $0.methods
        },
        isExtension: { $0.definedInType?.isExtension == true },
        filter: { all, extracted in
            !all.contains(where: { Self.uniqueMethodFilter($0, rhs: extracted) })
        })
    }

    private static func uniqueMethodFilter(_ lhs: Method, rhs: Method) -> Bool {
        return lhs.name == rhs.name && lhs.isStatic == rhs.isStatic && lhs.isClass == rhs.isClass && lhs.actualReturnTypeName == rhs.actualReturnTypeName
    }

    // sourcery: skipEquality, skipDescription
    /// Subscripts defined in this type only, inluding subscripts defined in its extensions,
    /// but not including subscripts inherited from superclasses (for classes only) and protocols
    public var subscripts: [Subscript] {
        unique({ $0.rawSubscripts }, filter: Self.uniqueSubscriptFilter)
    }

    /// Unfiltered (can contain duplications from extensions) Subscripts defined in this type only, inluding subscripts defined in its extensions,
    /// but not including subscripts inherited from superclasses (for classes only) and protocols
    public var rawSubscripts: [Subscript]

    // sourcery: skipEquality, skipDescription
    /// All subscripts defined for this type, including subscripts defined in extensions,
    /// in superclasses (for classes only) and protocols
    public var allSubscripts: [Subscript] {
        return flattenAll({ $0.subscripts },
            isExtension: { $0.definedInType?.isExtension == true },
            filter: { all, extracted in
                !all.contains(where: { Self.uniqueSubscriptFilter($0, rhs: extracted) })
            })
    }

    private static func uniqueSubscriptFilter(_ lhs: Subscript, rhs: Subscript) -> Bool {
        return lhs.parameters == rhs.parameters && lhs.returnTypeName == rhs.returnTypeName && lhs.readAccess == rhs.readAccess && lhs.writeAccess == rhs.writeAccess
    }

    // sourcery: skipEquality, skipDescription, skipJSExport
    /// Bytes position of the body of this type in its declaration file if available.
    public var bodyBytesRange: BytesRange?

    // sourcery: skipEquality, skipDescription, skipJSExport
    /// Bytes position of the whole declaration of this type in its declaration file if available.
    public var completeDeclarationRange: BytesRange?

    private func flattenAll<T>(_ extraction: @escaping (Type) -> [T], isExtension: (T) -> Bool, filter: ([T], T) -> Bool) -> [T] {
        let all = NSMutableOrderedSet()
        let allObjects = extraction(self)

        /// The order of importance for properties is:
        /// Base class
        /// Inheritance
        /// Protocol conformance
        /// Extension

        var extensions = [T]()
        var baseObjects = [T]()

        allObjects.forEach {
            if isExtension($0) {
                extensions.append($0)
            } else {
                baseObjects.append($0)
            }
        }

        all.addObjects(from: baseObjects)

        func filteredExtraction(_ target: Type) -> [T] {
            // swiftlint:disable:next force_cast
            let all = all.array as! [T]
            let extracted = extraction(target).filter({ filter(all, $0) })
            return extracted
        }

        inherits.values.sorted(by: { $0.name < $1.name }).forEach { all.addObjects(from: filteredExtraction($0)) }
        implements.values.sorted(by: { $0.name < $1.name }).forEach { all.addObjects(from: filteredExtraction($0)) }

        // swiftlint:disable:next force_cast
        let array = all.array as! [T]
        all.addObjects(from: extensions.filter({ filter(array, $0) }))

        return all.array.compactMap { $0 as? T }
    }

    private func unique<T>(_ extraction: @escaping (Type) -> [T], filter: (T, T) -> Bool) -> [T] {
        let all = NSMutableOrderedSet()
        for nextItem in extraction(self) {
            // swiftlint:disable:next force_cast
            if !all.contains(where: { filter($0 as! T, nextItem) }) {
                all.add(nextItem)
            }
        }

        return all.array.compactMap { $0 as? T }
    }

    /// All initializers defined in this type
    public var initializers: [Method] {
        return methods.filter { $0.isInitializer }
    }

    /// All annotations for this type
    public var annotations: Annotations = [:]

    public var documentation: Documentation = []

    /// Static variables defined in this type
    public var staticVariables: [Variable] {
        return variables.filter { $0.isStatic }
    }

    /// Static methods defined in this type
    public var staticMethods: [Method] {
        return methods.filter { $0.isStatic }
    }

    /// Class methods defined in this type
    public var classMethods: [Method] {
        return methods.filter { $0.isClass }
    }

    /// Instance variables defined in this type
    public var instanceVariables: [Variable] {
        return variables.filter { !$0.isStatic }
    }

    /// Instance methods defined in this type
    public var instanceMethods: [Method] {
        return methods.filter { !$0.isStatic && !$0.isClass }
    }

    /// Computed instance variables defined in this type
    public var computedVariables: [Variable] {
        return variables.filter { $0.isComputed && !$0.isStatic }
    }

    /// Stored instance variables defined in this type
    public var storedVariables: [Variable] {
        return variables.filter { !$0.isComputed && !$0.isStatic }
    }

    /// Names of types this type inherits from (for classes only) and protocols it implements, in order of definition
    public var inheritedTypes: [String] {
        didSet {
            based.removeAll()
            inheritedTypes.forEach { name in
                self.based[name] = name
            }
        }
    }

    // sourcery: skipEquality, skipDescription
    /// Names of types or protocols this type inherits from, including unknown (not scanned) types
    public var based = [String: String]()

    // sourcery: skipEquality, skipDescription
    /// Types this type inherits from or implements, including unknown (not scanned) types with extensions defined
    public var basedTypes = [String: Type]()

    /// Types this type inherits from
    public var inherits = [String: Type]()

    // sourcery: skipEquality, skipDescription
    /// Protocols this type implements
    public var implements = [String: Type]()

    /// Contained types
    public var containedTypes: [Type] {
        didSet {
            containedTypes.forEach {
                containedType[$0.localName] = $0
                $0.parent = self
            }
        }
    }

    // sourcery: skipEquality, skipDescription
    /// Contained types groupd by their names
    public private(set) var containedType: [String: Type] = [:]

    /// Name of parent type (for contained types only)
    public private(set) var parentName: String?

    // sourcery: skipEquality, skipDescription
    /// Parent type, if known (for contained types only)
    public var parent: Type? {
        didSet {
            parentName = parent?.name
        }
    }

    // sourcery: skipJSExport
    /// :nodoc:
    public var parentTypes: AnyIterator<Type> {
        var next: Type? = self
        return AnyIterator {
            next = next?.parent
            return next
        }
    }

    // sourcery: skipEquality, skipDescription
    /// Superclass type, if known (only for classes)
    public var supertype: Type?

    /// Type attributes, i.e. `@objc`
    public var attributes: AttributeList

    /// Type modifiers, i.e. `private`, `final`
    public var modifiers: [SourceryModifier]

    /// Path to file where the type is defined
    // sourcery: skipDescription, skipEquality, skipJSExport
    public var path: String? {
        didSet {
            if let path = path {
                fileName = (path as NSString).lastPathComponent
            }
        }
    }

    /// Directory to file where the type is defined
    // sourcery: skipDescription, skipEquality, skipJSExport
    public var directory: String? {
        get {
            return (path as? NSString)?.deletingLastPathComponent
        }
    }

    /// File name where the type was defined
    public var fileName: String?

    /// :nodoc:
    public init(name: String = "",
                parent: Type? = nil,
                accessLevel: AccessLevel = .internal,
                isExtension: Bool = false,
                variables: [Variable] = [],
                methods: [Method] = [],
                subscripts: [Subscript] = [],
                inheritedTypes: [String] = [],
                containedTypes: [Type] = [],
                typealiases: [Typealias] = [],
                attributes: AttributeList = [:],
                modifiers: [SourceryModifier] = [],
                annotations: [String: NSObject] = [:],
                documentation: [String] = [],
                isGeneric: Bool = false) {

        self.localName = name
        self.accessLevel = accessLevel.rawValue
        self.isExtension = isExtension
        self.rawVariables = variables
        self.rawMethods = methods
        self.rawSubscripts = subscripts
        self.inheritedTypes = inheritedTypes
        self.containedTypes = containedTypes
        self.typealiases = [:]
        self.parent = parent
        self.parentName = parent?.name
        self.attributes = attributes
        self.modifiers = modifiers
        self.annotations = annotations
        self.documentation = documentation
        self.isGeneric = isGeneric

        super.init()
        containedTypes.forEach {
            containedType[$0.localName] = $0
            $0.parent = self
        }
        inheritedTypes.forEach { name in
            self.based[name] = name
        }
        typealiases.forEach({
            $0.parent = self
            self.typealiases[$0.aliasName] = $0
        })
    }

    /// :nodoc:
    public func extend(_ type: Type) {
        type.annotations.forEach { self.annotations[$0.key] = $0.value }
        type.inherits.forEach { self.inherits[$0.key] = $0.value }
        type.implements.forEach { self.implements[$0.key] = $0.value }
        self.inheritedTypes += type.inheritedTypes
        self.containedTypes += type.containedTypes

        self.rawVariables += type.rawVariables
        self.rawMethods += type.rawMethods
        self.rawSubscripts += type.rawSubscripts
    }

// sourcery:inline:Type.AutoCoding

        /// :nodoc:
        required public init?(coder aDecoder: NSCoder) {
            self.module = aDecoder.decode(forKey: "module")
            guard let imports: [Import] = aDecoder.decode(forKey: "imports") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["imports"])); fatalError() }; self.imports = imports
            guard let typealiases: [String: Typealias] = aDecoder.decode(forKey: "typealiases") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typealiases"])); fatalError() }; self.typealiases = typealiases
            self.isExtension = aDecoder.decode(forKey: "isExtension")
            guard let accessLevel: String = aDecoder.decode(forKey: "accessLevel") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["accessLevel"])); fatalError() }; self.accessLevel = accessLevel
            self.isGeneric = aDecoder.decode(forKey: "isGeneric")
            guard let localName: String = aDecoder.decode(forKey: "localName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["localName"])); fatalError() }; self.localName = localName
            guard let rawVariables: [Variable] = aDecoder.decode(forKey: "rawVariables") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["rawVariables"])); fatalError() }; self.rawVariables = rawVariables
            guard let rawMethods: [Method] = aDecoder.decode(forKey: "rawMethods") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["rawMethods"])); fatalError() }; self.rawMethods = rawMethods
            guard let rawSubscripts: [Subscript] = aDecoder.decode(forKey: "rawSubscripts") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["rawSubscripts"])); fatalError() }; self.rawSubscripts = rawSubscripts
            self.bodyBytesRange = aDecoder.decode(forKey: "bodyBytesRange")
            self.completeDeclarationRange = aDecoder.decode(forKey: "completeDeclarationRange")
            guard let annotations: Annotations = aDecoder.decode(forKey: "annotations") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["annotations"])); fatalError() }; self.annotations = annotations
            guard let documentation: Documentation = aDecoder.decode(forKey: "documentation") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["documentation"])); fatalError() }; self.documentation = documentation
            guard let inheritedTypes: [String] = aDecoder.decode(forKey: "inheritedTypes") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["inheritedTypes"])); fatalError() }; self.inheritedTypes = inheritedTypes
            guard let based: [String: String] = aDecoder.decode(forKey: "based") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["based"])); fatalError() }; self.based = based
            guard let basedTypes: [String: Type] = aDecoder.decode(forKey: "basedTypes") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["basedTypes"])); fatalError() }; self.basedTypes = basedTypes
            guard let inherits: [String: Type] = aDecoder.decode(forKey: "inherits") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["inherits"])); fatalError() }; self.inherits = inherits
            guard let implements: [String: Type] = aDecoder.decode(forKey: "implements") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["implements"])); fatalError() }; self.implements = implements
            guard let containedTypes: [Type] = aDecoder.decode(forKey: "containedTypes") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["containedTypes"])); fatalError() }; self.containedTypes = containedTypes
            guard let containedType: [String: Type] = aDecoder.decode(forKey: "containedType") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["containedType"])); fatalError() }; self.containedType = containedType
            self.parentName = aDecoder.decode(forKey: "parentName")
            self.parent = aDecoder.decode(forKey: "parent")
            self.supertype = aDecoder.decode(forKey: "supertype")
            guard let attributes: AttributeList = aDecoder.decode(forKey: "attributes") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["attributes"])); fatalError() }; self.attributes = attributes
            guard let modifiers: [SourceryModifier] = aDecoder.decode(forKey: "modifiers") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["modifiers"])); fatalError() }; self.modifiers = modifiers
            self.path = aDecoder.decode(forKey: "path")
            self.fileName = aDecoder.decode(forKey: "fileName")
        }

        /// :nodoc:
        public func encode(with aCoder: NSCoder) {
            aCoder.encode(self.module, forKey: "module")
            aCoder.encode(self.imports, forKey: "imports")
            aCoder.encode(self.typealiases, forKey: "typealiases")
            aCoder.encode(self.isExtension, forKey: "isExtension")
            aCoder.encode(self.accessLevel, forKey: "accessLevel")
            aCoder.encode(self.isGeneric, forKey: "isGeneric")
            aCoder.encode(self.localName, forKey: "localName")
            aCoder.encode(self.rawVariables, forKey: "rawVariables")
            aCoder.encode(self.rawMethods, forKey: "rawMethods")
            aCoder.encode(self.rawSubscripts, forKey: "rawSubscripts")
            aCoder.encode(self.bodyBytesRange, forKey: "bodyBytesRange")
            aCoder.encode(self.completeDeclarationRange, forKey: "completeDeclarationRange")
            aCoder.encode(self.annotations, forKey: "annotations")
            aCoder.encode(self.documentation, forKey: "documentation")
            aCoder.encode(self.inheritedTypes, forKey: "inheritedTypes")
            aCoder.encode(self.based, forKey: "based")
            aCoder.encode(self.basedTypes, forKey: "basedTypes")
            aCoder.encode(self.inherits, forKey: "inherits")
            aCoder.encode(self.implements, forKey: "implements")
            aCoder.encode(self.containedTypes, forKey: "containedTypes")
            aCoder.encode(self.containedType, forKey: "containedType")
            aCoder.encode(self.parentName, forKey: "parentName")
            aCoder.encode(self.parent, forKey: "parent")
            aCoder.encode(self.supertype, forKey: "supertype")
            aCoder.encode(self.attributes, forKey: "attributes")
            aCoder.encode(self.modifiers, forKey: "modifiers")
            aCoder.encode(self.path, forKey: "path")
            aCoder.encode(self.fileName, forKey: "fileName")
        }
// sourcery:end
}

extension Type {

    // sourcery: skipDescription, skipJSExport
    /// :nodoc:
    var isClass: Bool {
        let isNotClass = self is Struct || self is Enum || self is Protocol
        return !isNotClass && !isExtension
    }
}

/// Extends type so that inner types can be accessed via KVC e.g. Parent.Inner.Children
extension Type {
    /// :nodoc:
    override public func value(forUndefinedKey key: String) -> Any? {
        if let innerType = containedTypes.lazy.filter({ $0.localName == key }).first {
            return innerType
        }

        return super.value(forUndefinedKey: key)
    }
}
