// Generated using Sourcery 0.5.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation

extension NSCoder {

    @nonobjc func decode(forKey: String) -> String? {
        return self.maybeDecode(forKey: forKey) as String?
    }

    @nonobjc func decode(forKey: String) -> TypeName? {
        return self.maybeDecode(forKey: forKey) as TypeName?
    }

    @nonobjc func decode(forKey: String) -> AccessLevel? {
        return self.maybeDecode(forKey: forKey) as AccessLevel?
    }

    @nonobjc func decode(forKey: String) -> Bool {
        return self.decodeBool(forKey: forKey)
    }

    @nonobjc func decode(forKey: String) -> Int {
        return self.decodeInteger(forKey: forKey)
    }

    func decode<E>(forKey: String) -> E? {
        return maybeDecode(forKey: forKey) as E?
    }

    fileprivate func maybeDecode<E>(forKey: String) -> E? {
        guard let object = self.decodeObject(forKey: forKey) else {
            return nil
        }

        return object as? E
    }

}

/*
extension Attribute: NSCoding {
        // Attribute.NSCoding {
        required init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let arguments: [String: NSObject] = aDecoder.decode(forKey: "arguments") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["arguments"])); fatalError() }; self.arguments = arguments
            guard let _description: String = aDecoder.decode(forKey: "_description") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["_description"])); fatalError() }; self._description = _description
            
        }

        func encode(with aCoder: NSCoder) {
            
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.arguments, forKey: "arguments")
            aCoder.encode(self._description, forKey: "_description")
            
        }
        // } Attribute.NSCoding
}
*/

/*
extension Class {
        // Class.NSCoding {
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }

        override func encode(with aCoder: NSCoder) {
            super.encode(with: aCoder)
            
        }
        // } Class.NSCoding
}
*/

/*
extension Enum {
        // Enum.NSCoding {
        required init?(coder aDecoder: NSCoder) {
            guard let cases: [Case] = aDecoder.decode(forKey: "cases") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["cases"])); fatalError() }; self.cases = cases
            self.rawTypeName = aDecoder.decode(forKey: "rawTypeName")
            self.hasRawType = aDecoder.decode(forKey: "hasRawType")
            self.rawType = aDecoder.decode(forKey: "rawType")
            
            super.init(coder: aDecoder)
        }

        override func encode(with aCoder: NSCoder) {
            super.encode(with: aCoder)
            aCoder.encode(self.cases, forKey: "cases")
            aCoder.encode(self.rawTypeName, forKey: "rawTypeName")
            aCoder.encode(self.hasRawType, forKey: "hasRawType")
            aCoder.encode(self.rawType, forKey: "rawType")
            
        }
        // } Enum.NSCoding
}
*/

/*
extension Enum.Case: NSCoding {
        // Enum.Case.NSCoding {
        required init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            self.rawValue = aDecoder.decode(forKey: "rawValue")
            guard let associatedValues: [AssociatedValue] = aDecoder.decode(forKey: "associatedValues") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["associatedValues"])); fatalError() }; self.associatedValues = associatedValues
            guard let annotations: [String: NSObject] = aDecoder.decode(forKey: "annotations") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["annotations"])); fatalError() }; self.annotations = annotations
            
            
        }

        func encode(with aCoder: NSCoder) {
            
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.rawValue, forKey: "rawValue")
            aCoder.encode(self.associatedValues, forKey: "associatedValues")
            aCoder.encode(self.annotations, forKey: "annotations")
            
        }
        // } Enum.Case.NSCoding
}
*/

/*
extension Enum.Case.AssociatedValue: NSCoding {
        // Enum.Case.AssociatedValue.NSCoding {
        required init?(coder aDecoder: NSCoder) {
            self.localName = aDecoder.decode(forKey: "localName")
            self.externalName = aDecoder.decode(forKey: "externalName")
            guard let typeName: TypeName = aDecoder.decode(forKey: "typeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typeName"])); fatalError() }; self.typeName = typeName
            self.type = aDecoder.decode(forKey: "type")
            
        }

        func encode(with aCoder: NSCoder) {
            
            aCoder.encode(self.localName, forKey: "localName")
            aCoder.encode(self.externalName, forKey: "externalName")
            aCoder.encode(self.typeName, forKey: "typeName")
            aCoder.encode(self.type, forKey: "type")
            
        }
        // } Enum.Case.AssociatedValue.NSCoding
}
*/

/*
extension GenerationContext: NSCoding {
        // GenerationContext.NSCoding {
        required init?(coder aDecoder: NSCoder) {
            guard let types: [Type] = aDecoder.decode(forKey: "types") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["types"])); fatalError() }; self.types = types
            guard let typeByName: [String : Type] = aDecoder.decode(forKey: "typeByName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typeByName"])); fatalError() }; self.typeByName = typeByName
            guard let arguments: [String : NSObject] = aDecoder.decode(forKey: "arguments") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["arguments"])); fatalError() }; self.arguments = arguments
            
            
            
            
            
            
        }

        func encode(with aCoder: NSCoder) {
            
            aCoder.encode(self.types, forKey: "types")
            aCoder.encode(self.typeByName, forKey: "typeByName")
            aCoder.encode(self.arguments, forKey: "arguments")
            
        }
        // } GenerationContext.NSCoding
}
*/

/*
extension Method: NSCoding {
        // Method.NSCoding {
        required init?(coder aDecoder: NSCoder) {
            guard let selectorName: String = aDecoder.decode(forKey: "selectorName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["selectorName"])); fatalError() }; self.selectorName = selectorName
            guard let parameters: [Parameter] = aDecoder.decode(forKey: "parameters") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["parameters"])); fatalError() }; self.parameters = parameters
            guard let returnTypeName: TypeName = aDecoder.decode(forKey: "returnTypeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["returnTypeName"])); fatalError() }; self.returnTypeName = returnTypeName
            self.returnType = aDecoder.decode(forKey: "returnType")
            guard let accessLevel: AccessLevel = aDecoder.decode(forKey: "accessLevel") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["accessLevel"])); fatalError() }; self.accessLevel = accessLevel
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
            aCoder.encode(self.accessLevel, forKey: "accessLevel")
            aCoder.encode(self.isStatic, forKey: "isStatic")
            aCoder.encode(self.isClass, forKey: "isClass")
            aCoder.encode(self.isFailableInitializer, forKey: "isFailableInitializer")
            aCoder.encode(self.annotations, forKey: "annotations")
            aCoder.encode(self.attributes, forKey: "attributes")
            
        }
        // } Method.NSCoding
}
*/

/*
extension Method.Parameter: NSCoding {
        // Method.Parameter.NSCoding {
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
        // } Method.Parameter.NSCoding
}
*/

/*
extension Protocol {
        // Protocol.NSCoding {
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }

        override func encode(with aCoder: NSCoder) {
            super.encode(with: aCoder)
            
        }
        // } Protocol.NSCoding
}
*/

/*
extension Struct {
        // Struct.NSCoding {
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }

        override func encode(with aCoder: NSCoder) {
            super.encode(with: aCoder)
            
        }
        // } Struct.NSCoding
}
*/

/*
extension TupleType: NSCoding {
        // TupleType.NSCoding {
        required init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let elements: [Element] = aDecoder.decode(forKey: "elements") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["elements"])); fatalError() }; self.elements = elements
            
        }

        func encode(with aCoder: NSCoder) {
            
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.elements, forKey: "elements")
            
        }
        // } TupleType.NSCoding
}
*/

/*
extension TupleType.Element: NSCoding {
        // TupleType.Element.NSCoding {
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
        // } TupleType.Element.NSCoding
}
*/

/*
extension Type: NSCoding {
        // Type.NSCoding {
        required init?(coder aDecoder: NSCoder) {
            guard let typealiases: [String: Typealias] = aDecoder.decode(forKey: "typealiases") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typealiases"])); fatalError() }; self.typealiases = typealiases
            self.isExtension = aDecoder.decode(forKey: "isExtension")
            guard let accessLevel: String = aDecoder.decode(forKey: "accessLevel") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["accessLevel"])); fatalError() }; self.accessLevel = accessLevel
            self.isGeneric = aDecoder.decode(forKey: "isGeneric")
            guard let localName: String = aDecoder.decode(forKey: "localName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["localName"])); fatalError() }; self.localName = localName
            guard let variables: [Variable] = aDecoder.decode(forKey: "variables") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["variables"])); fatalError() }; self.variables = variables
            guard let methods: [Method] = aDecoder.decode(forKey: "methods") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["methods"])); fatalError() }; self.methods = methods
            guard let annotations: [String: NSObject] = aDecoder.decode(forKey: "annotations") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["annotations"])); fatalError() }; self.annotations = annotations
            guard let inheritedTypes: [String] = aDecoder.decode(forKey: "inheritedTypes") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["inheritedTypes"])); fatalError() }; self.inheritedTypes = inheritedTypes
            guard let based: [String: String] = aDecoder.decode(forKey: "based") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["based"])); fatalError() }; self.based = based
            guard let inherits: [String: Type] = aDecoder.decode(forKey: "inherits") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["inherits"])); fatalError() }; self.inherits = inherits
            guard let implements: [String: Type] = aDecoder.decode(forKey: "implements") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["implements"])); fatalError() }; self.implements = implements
            guard let containedTypes: [Type] = aDecoder.decode(forKey: "containedTypes") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["containedTypes"])); fatalError() }; self.containedTypes = containedTypes
            self.parentName = aDecoder.decode(forKey: "parentName")
            self.parent = aDecoder.decode(forKey: "parent")
            self.supertype = aDecoder.decode(forKey: "supertype")
            guard let attributes: [String: Attribute] = aDecoder.decode(forKey: "attributes") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["attributes"])); fatalError() }; self.attributes = attributes
            
            
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
            aCoder.encode(self.based, forKey: "based")
            aCoder.encode(self.inherits, forKey: "inherits")
            aCoder.encode(self.implements, forKey: "implements")
            aCoder.encode(self.containedTypes, forKey: "containedTypes")
            aCoder.encode(self.parentName, forKey: "parentName")
            aCoder.encode(self.parent, forKey: "parent")
            aCoder.encode(self.supertype, forKey: "supertype")
            aCoder.encode(self.attributes, forKey: "attributes")
            
        }
        // } Type.NSCoding
}
*/

/*
extension TypeName: NSCoding {
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
*/

/*
extension Typealias: NSCoding {
        // Typealias.NSCoding {
        required init?(coder aDecoder: NSCoder) {
            guard let aliasName: String = aDecoder.decode(forKey: "aliasName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["aliasName"])); fatalError() }; self.aliasName = aliasName
            guard let typeName: TypeName = aDecoder.decode(forKey: "typeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typeName"])); fatalError() }; self.typeName = typeName
            self.type = aDecoder.decode(forKey: "type")
            self.parent = aDecoder.decode(forKey: "parent")
            self.parentName = aDecoder.decode(forKey: "parentName")
            
        }

        func encode(with aCoder: NSCoder) {
            
            aCoder.encode(self.aliasName, forKey: "aliasName")
            aCoder.encode(self.typeName, forKey: "typeName")
            aCoder.encode(self.type, forKey: "type")
            aCoder.encode(self.parent, forKey: "parent")
            aCoder.encode(self.parentName, forKey: "parentName")
            
        }
        // } Typealias.NSCoding
}
*/

/*
extension Variable: NSCoding {
        // Variable.NSCoding {
        required init?(coder aDecoder: NSCoder) {
            guard let name: String = aDecoder.decode(forKey: "name") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["name"])); fatalError() }; self.name = name
            guard let typeName: TypeName = aDecoder.decode(forKey: "typeName") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["typeName"])); fatalError() }; self.typeName = typeName
            self.type = aDecoder.decode(forKey: "type")
            self.isComputed = aDecoder.decode(forKey: "isComputed")
            self.isStatic = aDecoder.decode(forKey: "isStatic")
            guard let readAccess: String = aDecoder.decode(forKey: "readAccess") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["readAccess"])); fatalError() }; self.readAccess = readAccess
            guard let writeAccess: String = aDecoder.decode(forKey: "writeAccess") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["writeAccess"])); fatalError() }; self.writeAccess = writeAccess
            guard let annotations: [String: NSObject] = aDecoder.decode(forKey: "annotations") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["annotations"])); fatalError() }; self.annotations = annotations
            guard let attributes: [String: Attribute] = aDecoder.decode(forKey: "attributes") else { NSException.raise(NSExceptionName.parseErrorException, format: "Key '%@' not found.", arguments: getVaList(["attributes"])); fatalError() }; self.attributes = attributes
            
            
        }

        func encode(with aCoder: NSCoder) {
            
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.typeName, forKey: "typeName")
            aCoder.encode(self.type, forKey: "type")
            aCoder.encode(self.isComputed, forKey: "isComputed")
            aCoder.encode(self.isStatic, forKey: "isStatic")
            aCoder.encode(self.readAccess, forKey: "readAccess")
            aCoder.encode(self.writeAccess, forKey: "writeAccess")
            aCoder.encode(self.annotations, forKey: "annotations")
            aCoder.encode(self.attributes, forKey: "attributes")
            
        }
        // } Variable.NSCoding
}
*/
