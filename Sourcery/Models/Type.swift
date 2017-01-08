//
// Created by Krzysztof Zablocki on 11/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

/// Defines Swift Type
class Type: NSObject, AutoDiffable, Annotated, NSCoding {

    /// All local typealiases
    var typealiases: [String: Typealias] {
        didSet {
            typealiases.values.forEach { $0.parent = self }
        }
    }

    internal var isExtension: Bool

    var kind: String { return isExtension ? "extension" : "unknown" }

    /// What is the type access level?
    let accessLevel: String

    /// Name in global scope
    var name: String {
        guard let parentName = parent?.name else { return localName }
        return "\(parentName).\(localName)"
    }

    /// Is this type generic?
    var isGeneric: Bool

    /// Name in parent scope
    var localName: String

    /// Variables defined in this type only, excluding those from parent or protocols
    var variables: [Variable]

    /// All variables associated with this type, including those from parent or protocols
    /// sourcery: skipEquality, skipDescription
    var allVariables: [Variable] {
        return flattenAll { $0.variables }
    }

    /// All methods associated with this type, including those from parent or protocols
    /// sourcery: skipEquality, skipDescription
    var allMethods: [Method] {
        return flattenAll { $0.methods }
    }

    private func flattenAll<T>(extraction: (Type) -> [T]) -> [T] {
        let all = NSMutableOrderedSet()
        all.addObjects(from: extraction(self))

        _ = supertype.flatMap { all.addObjects(from: extraction($0)) }
        inherits.values.forEach { all.addObjects(from: extraction($0)) }
        implements.values.forEach { all.addObjects(from: extraction($0)) }

        return Array(all.array.flatMap { $0 as? T })
    }

    /// All methods defined by this type, excluding those from parent or protocols
    var methods: [Method]

    /// All initializers defined by this type
    var initializers: [Method] {
        return methods.filter { $0.isInitializer }
    }

    /// Annotations, that were created with // sourcery: annotation1, other = "annotation value", alternative = 2
    var annotations: [String: NSObject] = [:]

    /// Static variables defined in this type
    var staticVariables: [Variable] {
        return variables.filter { $0.isStatic }
    }

    /// Instance variables defined in this type
    var instanceVariables: [Variable] {
        return variables.filter { !$0.isStatic }
    }

    /// All computed instance variables defined in this type
    var computedVariables: [Variable] {
        return variables.filter { $0.isComputed && !$0.isStatic }
    }

    /// Only stored instance variables defined in this type
    var storedVariables: [Variable] {
        return variables.filter { !$0.isComputed && !$0.isStatic }
    }

    /// Types / Protocols names we inherit from, in order of definition
    var inheritedTypes: [String] {
        didSet {
            based.removeAll()
            inheritedTypes.forEach { name in
                self.based[name] = name
            }
        }
    }

    /// contains all base types inheriting from given BaseClass or implementing given Protocol, even not known by Sourcery
    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var based = [String: String]()

    /// contains all types inheriting from known BaseClass
    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var inherits = [String: Type]()

    /// contains all types implementing known BaseProtocol
    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var implements = [String: Type]()

    /// Contained types
    var containedTypes: [Type] {
        didSet {
            containedTypes.forEach { $0.parent = self }
        }
    }

    /// Parent name
    private(set) var parentName: String?

    /// Parent type
    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var parent: Type? {
        didSet {
            parentName = parent?.name
        }
    }

    /// Superclass definition if any
    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var supertype: Type?

    /// sourcery: skipEquality
    /// Underlying parser data, never to be used by anything else
    /// sourcery: skipDescription
    internal var __parserData: Any?

    init(name: String = "",
         parent: Type? = nil,
         accessLevel: AccessLevel = .internal,
         isExtension: Bool = false,
         variables: [Variable] = [],
		 methods: [Method] = [],
         inheritedTypes: [String] = [],
         containedTypes: [Type] = [],
		 typealiases: [Typealias] = [],
         annotations: [String: NSObject] = [:],
         isGeneric: Bool = false) {

        self.localName = name
        self.accessLevel = accessLevel.rawValue
        self.isExtension = isExtension
        self.variables = variables
        self.methods = methods
        self.inheritedTypes = inheritedTypes
        self.containedTypes = containedTypes
        self.typealiases = [:]
        self.parent = parent
        self.parentName = parent?.name
        self.annotations = annotations
        self.isGeneric = isGeneric

        super.init()
        containedTypes.forEach { $0.parent = self }
        inheritedTypes.forEach { name in
            self.based[name] = name
        }
        typealiases.forEach({
            $0.parent = self
            self.typealiases[$0.aliasName] = $0
        })
    }

    /// Extends this type with an extension
    ///
    /// - Parameter type: Extension of this type
    func extend(_ type: Type) {
        self.variables += type.variables
        self.methods += type.methods

        type.annotations.forEach { self.annotations[$0.key] = $0.value }
        type.inherits.forEach { self.inherits[$0.key] = $0.value }
        type.implements.forEach { self.implements[$0.key] = $0.value }
        self.inheritedTypes = Array(Set(self.inheritedTypes + type.inheritedTypes))
    }

    // Type.NSCoding {
        required init?(coder aDecoder: NSCoder) {
             guard let typealiases: [String: Typealias] = aDecoder.decode(forKey: "typealiases") else { return nil }; self.typealiases = typealiases
            self.isExtension = aDecoder.decodeBool(forKey: "isExtension")
             guard let accessLevel: String = aDecoder.decode(forKey: "accessLevel") else { return nil }; self.accessLevel = accessLevel
            self.isGeneric = aDecoder.decodeBool(forKey: "isGeneric")
             guard let localName: String = aDecoder.decode(forKey: "localName") else { return nil }; self.localName = localName
             guard let variables: [Variable] = aDecoder.decode(forKey: "variables") else { return nil }; self.variables = variables
             guard let methods: [Method] = aDecoder.decode(forKey: "methods") else { return nil }; self.methods = methods
             guard let annotations: [String: NSObject] = aDecoder.decode(forKey: "annotations") else { return nil }; self.annotations = annotations
             guard let inheritedTypes: [String] = aDecoder.decode(forKey: "inheritedTypes") else { return nil }; self.inheritedTypes = inheritedTypes

             guard let containedTypes: [Type] = aDecoder.decode(forKey: "containedTypes") else { return nil }; self.containedTypes = containedTypes
             self.parentName = aDecoder.decode(forKey: "parentName")

        }

        func encode(with aCoder: NSCoder) {

            aCoder.encode(self.typealiases, forKey: "typealiases")
            aCoder.encode(self.isExtension, forKey: "isExtension")
            aCoder.encode(self.accessLevel, forKey: "accessLevel")
            aCoder.encode(self.isGeneric, forKey: "isGeneric")
            aCoder.encode(self.localName, forKey: "localName")
            aCoder.encode(self.variables, forKey: "variables")
            aCoder.encode(self.methods, forKey: "methods")
            aCoder.encode(self.annotations, forKey: "annotations")
            aCoder.encode(self.inheritedTypes, forKey: "inheritedTypes")
            aCoder.encode(self.containedTypes, forKey: "containedTypes")
            aCoder.encode(self.parentName, forKey: "parentName")

        }
        // } Type.NSCoding
}

extension Type {
    var isClass: Bool {
        let isNotClass = self is Struct || self is Enum || self is Protocol
        return !isNotClass && !isExtension
    }
}
