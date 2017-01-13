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

// sourcery: skipDescription
final class TypeName: NSObject, AutoDiffable, NSCoding {
    let name: String

    /// Actual type name if given type name is type alias
    // sourcery: skipEquality
    var actualTypeName: TypeName?

    init(_ name: String, attributes: [String: Attribute] = [:]) {
        self.name = name
        self.attributes = attributes

        var name = name
        attributes.forEach {
            let trim = CharacterSet(charactersIn: "@\($0.key)")
            name = name.trimmingCharacters(in: trim.union(.whitespaces))
        }

		let isImplicitlyUnwrappedOptional = name.hasSuffix("!") || name.hasPrefix("ImplicitlyUnwrappedOptional<")
        let isOptional = name.hasSuffix("?") || name.hasPrefix("Optional<") || isImplicitlyUnwrappedOptional
		self.isImplicitlyUnwrappedOptional = isImplicitlyUnwrappedOptional
        self.isOptional = isOptional

        if isOptional {
            if name.hasSuffix("?") || name.hasSuffix("!") {
                self.unwrappedTypeName = String(name.characters.dropLast())
            } else if name.hasPrefix("Optional<") {
                self.unwrappedTypeName = name.drop(first: "Optional<".characters.count, last: 1)
            } else {
                self.unwrappedTypeName = name.drop(first: "ImplicitlyUnwrappedOptional<".characters.count, last: 1)
            }
        } else {
            self.unwrappedTypeName = name
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
        return name == "Void" || name == "()"
    }

    var isTuple: Bool {
        if let actualTypeName = actualTypeName?.name {
            return actualTypeName.isValidTupleName()
        } else {
            return name.isValidTupleName()
        }
    }

    var tuple: TupleType?

    override var description: String {
        return name
    }

    // TypeName.NSCoding {
        required init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            self.actualTypeName = aDecoder.decode(forKey: "actualTypeName")
            guard let attributes: [String: Attribute] = aDecoder.decode(forKey: "attributes") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["attributes"])); fatalError() }; self.attributes = attributes
            self.isOptional = aDecoder.decode(forKey: "isOptional")
            self.isImplicitlyUnwrappedOptional = aDecoder.decode(forKey: "isImplicitlyUnwrappedOptional")
            guard let unwrappedTypeName: String = aDecoder.decode(forKey: "unwrappedTypeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["unwrappedTypeName"])); fatalError() }; self.unwrappedTypeName = unwrappedTypeName
            self.tuple = aDecoder.decode(forKey: "tuple")

        }

        func encode(with aCoder: NSCoder) {

            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.actualTypeName, forKey: "actualTypeName")
            aCoder.encode(self.attributes, forKey: "attributes")
            aCoder.encode(self.isOptional, forKey: "isOptional")
            aCoder.encode(self.isImplicitlyUnwrappedOptional, forKey: "isImplicitlyUnwrappedOptional")
            aCoder.encode(self.unwrappedTypeName, forKey: "unwrappedTypeName")
            aCoder.encode(self.tuple, forKey: "tuple")

        }
        // } TypeName.NSCoding

}

final class TupleElement: NSObject, AutoDiffable, Typed, NSCoding {
    let name: String
    let typeName: TypeName

    // sourcery: skipEquality, skipDescription
    var type: Type?

    init(name: String = "", typeName: TypeName, type: Type? = nil) {
        self.name = name
        self.typeName = typeName
        self.type = type
    }

    // TupleElement.NSCoding {
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
    // } TupleElement.NSCoding
}

final class TupleType: NSObject, AutoDiffable, NSCoding {
    let name: String

    let elements: [TupleElement]

    init(name: String, elements: [TupleElement]) {
        self.name = name
        self.elements = elements
    }

    // TupleType.NSCoding {
        required init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let elements: [TupleElement] = aDecoder.decode(forKey: "elements") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["elements"])); fatalError() }; self.elements = elements

        }

        func encode(with aCoder: NSCoder) {

            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.elements, forKey: "elements")

        }
        // } TupleType.NSCoding
}
