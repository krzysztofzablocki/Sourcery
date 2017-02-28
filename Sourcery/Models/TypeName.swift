//
// Created by Krzysztof Zabłocki on 25/12/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation

protocol Typed {
    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var type: Type? { get set }

    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var typeName: TypeName { get }

    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var isOptional: Bool { get }

    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var isImplicitlyUnwrappedOptional: Bool { get }

    /// sourcery: skipEquality
    /// sourcery: skipDescription
    var unwrappedTypeName: String { get }
}

final class TypeName: NSObject, AutoCoding, AutoEquatable, AutoDiffable, AutoJSExport {
    let name: String

    /// Actual type name if given type name is type alias
    // sourcery: skipEquality
    var actualTypeName: TypeName?

    init(_ name: String,
         actualTypeName: TypeName? = nil,
         attributes: [String: Attribute] = [:],
         tuple: TupleType? = nil,
         array: ArrayType? = nil) {

        self.name = name
        self.actualTypeName = actualTypeName
        self.attributes = attributes
        self.tuple = tuple
        self.array = array

        var name = name
        attributes.forEach {
            name = name.trimmingPrefix($0.value.description)
                .trimmingCharacters(in: .whitespaces)
        }

        if let genericConstraint = name.range(of: "where") {
            name = String(name.characters.prefix(upTo: genericConstraint.lowerBound))
                .trimmingCharacters(in: .whitespaces)
        }

        if name.isEmpty {
            self.unwrappedTypeName = "Void"
            self.isImplicitlyUnwrappedOptional = false
            self.isOptional = false
        } else {
            name = name.bracketsBalancing()
            let isImplicitlyUnwrappedOptional = name.hasSuffix("!") || name.hasPrefix("ImplicitlyUnwrappedOptional<")
            let isOptional = name.hasSuffix("?") || name.hasPrefix("Optional<") || isImplicitlyUnwrappedOptional
            self.isImplicitlyUnwrappedOptional = isImplicitlyUnwrappedOptional
            self.isOptional = isOptional

            if isOptional {
                let unwrappedTypeName: String
                if name.hasSuffix("?") || name.hasSuffix("!") {
                    unwrappedTypeName = String(name.characters.dropLast())
                } else if name.hasPrefix("Optional<") {
                    unwrappedTypeName = name.drop(first: "Optional<".characters.count, last: 1)
                } else {
                    unwrappedTypeName = name.drop(first: "ImplicitlyUnwrappedOptional<".characters.count, last: 1)
                }
                self.unwrappedTypeName = unwrappedTypeName.bracketsBalancing()
            } else {
                self.unwrappedTypeName = name
            }
        }
    }

    let attributes: [String: Attribute]

    // sourcery: skipEquality
    let isOptional: Bool

    // sourcery: skipEquality
    let isImplicitlyUnwrappedOptional: Bool

    // sourcery: skipEquality
    let unwrappedTypeName: String

    // sourcery: skipEquality
    var isVoid: Bool {
        return name == "Void" || name == "()" || unwrappedTypeName == "Void"
    }

    var isTuple: Bool {
        if let actualTypeName = actualTypeName?.unwrappedTypeName {
            return actualTypeName.isValidTupleName()
        } else {
            return unwrappedTypeName.isValidTupleName()
        }
    }

    var tuple: TupleType?

    var isArray: Bool {
        if let actualTypeName = actualTypeName?.unwrappedTypeName {
            return actualTypeName.isValidArrayName()
        } else {
            return unwrappedTypeName.isValidArrayName()
        }
    }

    var array: ArrayType?

    var isClosure: Bool {
        if let actualTypeName = actualTypeName?.unwrappedTypeName {
            return actualTypeName.isValidClosureName()
        } else {
            return unwrappedTypeName.isValidClosureName()
        }
    }

    override var description: String {
        return name
    }

    // sourcery:inline:TypeName.AutoCoding
        required init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            self.actualTypeName = aDecoder.decode(forKey: "actualTypeName")
            guard let attributes: [String: Attribute] = aDecoder.decode(forKey: "attributes") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["attributes"])); fatalError() }; self.attributes = attributes
            self.isOptional = aDecoder.decode(forKey: "isOptional")
            self.isImplicitlyUnwrappedOptional = aDecoder.decode(forKey: "isImplicitlyUnwrappedOptional")
            guard let unwrappedTypeName: String = aDecoder.decode(forKey: "unwrappedTypeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["unwrappedTypeName"])); fatalError() }; self.unwrappedTypeName = unwrappedTypeName
            self.tuple = aDecoder.decode(forKey: "tuple")
            self.array = aDecoder.decode(forKey: "array")
        }

        func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.actualTypeName, forKey: "actualTypeName")
            aCoder.encode(self.attributes, forKey: "attributes")
            aCoder.encode(self.isOptional, forKey: "isOptional")
            aCoder.encode(self.isImplicitlyUnwrappedOptional, forKey: "isImplicitlyUnwrappedOptional")
            aCoder.encode(self.unwrappedTypeName, forKey: "unwrappedTypeName")
            aCoder.encode(self.tuple, forKey: "tuple")
            aCoder.encode(self.array, forKey: "array")
        }
        // sourcery:end

}

final class TupleElement: NSObject, SourceryModel, Typed {
    let name: String
    let typeName: TypeName

    // sourcery: skipEquality, skipDescription
    var type: Type?

    init(name: String = "", typeName: TypeName, type: Type? = nil) {
        self.name = name
        self.typeName = typeName
        self.type = type
    }

    // sourcery:inline:TupleElement.AutoCoding
        required init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let typeName: TypeName = aDecoder.decode(forKey: "typeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typeName"])); fatalError() }; self.typeName = typeName
            self.type = aDecoder.decode(forKey: "type")
        }

        func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.typeName, forKey: "typeName")
            aCoder.encode(self.type, forKey: "type")
        }
     // sourcery:end
}

final class TupleType: NSObject, SourceryModel {
    let name: String

    let elements: [TupleElement]

    init(name: String, elements: [TupleElement]) {
        self.name = name
        self.elements = elements
    }

    // sourcery:inline:TupleType.AutoCoding
        required init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let elements: [TupleElement] = aDecoder.decode(forKey: "elements") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["elements"])); fatalError() }; self.elements = elements
        }

        func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.elements, forKey: "elements")
        }
     // sourcery:end
}

final class ArrayType: NSObject, SourceryModel {
    let name: String
    let elementTypeName: TypeName
    var elementType: Type?

    init(name: String, elementTypeName: TypeName, elementType: Type? = nil) {
        self.name = name
        self.elementTypeName = elementTypeName
        self.elementType = elementType
    }

    // sourcery:inline:ArrayType.AutoCoding
        required init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let elementTypeName: TypeName = aDecoder.decode(forKey: "elementTypeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["elementTypeName"])); fatalError() }; self.elementTypeName = elementTypeName
            self.elementType = aDecoder.decode(forKey: "elementType")
        }

        func encode(with aCoder: NSCoder) {
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.elementTypeName, forKey: "elementTypeName")
            aCoder.encode(self.elementType, forKey: "elementType")
        }
    // sourcery:end
}
