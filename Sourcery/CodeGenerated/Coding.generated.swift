// Generated using Sourcery 0.5.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation

extension NSCoder {

    @nonobjc func decode(forKey: String) -> String? {
        guard let object = self.decodeObject(forKey: forKey) else {
            return nil
        }

        return object as? String
    }

    @nonobjc func decode(forKey: String) -> TypeName? {
        guard let object = self.decodeObject(forKey: forKey) else {
            return nil
        }

        return object as? TypeName
    }

    @nonobjc func decode(forKey: String) -> AccessLevel? {
        guard let object = self.decodeObject(forKey: forKey) else {
            return nil
        }
        return object as? AccessLevel
    }

    @nonobjc func decode(forKey: String) -> Bool {
        return self.decodeBool(forKey: forKey)
    }

    @nonobjc func decode(forKey: String) -> Int {
        return self.decodeInteger(forKey: forKey)
    }

    func decode<E>(forKey: String) -> E? {
        guard let object = self.decodeObject(forKey: forKey) else {
            return nil
        }

        return object as? E
    }

}

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
             guard let cases: [Case] = aDecoder.decode(forKey: "cases") else { return nil }; self.cases = cases
             self.rawType = aDecoder.decode(forKey: "rawType")
            self.hasRawType = aDecoder.decodeBool(forKey: "hasRawType")
            
            super.init(coder: aDecoder)
        }
 
        override func encode(with aCoder: NSCoder) {
            super.encode(with: aCoder)
            aCoder.encode(self.cases, forKey: "cases")
            aCoder.encode(self.rawType, forKey: "rawType")
            aCoder.encode(self.hasRawType, forKey: "hasRawType")
            
        }
        // } Enum.NSCoding
}
*/

/*
extension Enum.Case: NSCoding {
        // Enum.Case.NSCoding {
        required init?(coder aDecoder: NSCoder) {
             guard let name: String = aDecoder.decode(forKey: "name") else { return nil }; self.name = name
             self.rawValue = aDecoder.decode(forKey: "rawValue")
             guard let associatedValues: [AssociatedValue] = aDecoder.decode(forKey: "associatedValues") else { return nil }; self.associatedValues = associatedValues
             guard let annotations: [String: NSObject] = aDecoder.decode(forKey: "annotations") else { return nil }; self.annotations = annotations
            
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
             guard let typeName: TypeName = aDecoder.decode(forKey: "typeName") else { return nil }; self.typeName = typeName
            
            
        }
 
        func encode(with aCoder: NSCoder) {
            
            aCoder.encode(self.localName, forKey: "localName")
            aCoder.encode(self.externalName, forKey: "externalName")
            aCoder.encode(self.typeName, forKey: "typeName")
            
        }
        // } Enum.Case.AssociatedValue.NSCoding
}
*/

/*
extension GenerationContext: NSCoding {
        // GenerationContext.NSCoding {
        required init?(coder aDecoder: NSCoder) {
             guard let types: [Type] = aDecoder.decode(forKey: "types") else { return nil }; self.types = types
             guard let typeByName: [String : Type] = aDecoder.decode(forKey: "typeByName") else { return nil }; self.typeByName = typeByName
             guard let arguments: [String : NSObject] = aDecoder.decode(forKey: "arguments") else { return nil }; self.arguments = arguments
            
            
            
            
            
            
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
             guard let selectorName: String = aDecoder.decode(forKey: "selectorName") else { return nil }; self.selectorName = selectorName
             guard let parameters: [Parameter] = aDecoder.decode(forKey: "parameters") else { return nil }; self.parameters = parameters
             guard let returnTypeName: TypeName = aDecoder.decode(forKey: "returnTypeName") else { return nil }; self.returnTypeName = returnTypeName
            
             guard let accessLevel: AccessLevel = aDecoder.decode(forKey: "accessLevel") else { return nil }; self.accessLevel = accessLevel
            self.isStatic = aDecoder.decodeBool(forKey: "isStatic")
            self.isClass = aDecoder.decodeBool(forKey: "isClass")
            self.isFailableInitializer = aDecoder.decodeBool(forKey: "isFailableInitializer")
             guard let annotations: [String: NSObject] = aDecoder.decode(forKey: "annotations") else { return nil }; self.annotations = annotations
            
            
        }
 
        func encode(with aCoder: NSCoder) {
            
            aCoder.encode(self.selectorName, forKey: "selectorName")
            aCoder.encode(self.parameters, forKey: "parameters")
            aCoder.encode(self.returnTypeName, forKey: "returnTypeName")
            aCoder.encode(self.accessLevel, forKey: "accessLevel")
            aCoder.encode(self.isStatic, forKey: "isStatic")
            aCoder.encode(self.isClass, forKey: "isClass")
            aCoder.encode(self.isFailableInitializer, forKey: "isFailableInitializer")
            aCoder.encode(self.annotations, forKey: "annotations")
            
        }
        // } Method.NSCoding
}
*/

/*
extension Method.Parameter: NSCoding {
        // Method.Parameter.NSCoding {
        required init?(coder aDecoder: NSCoder) {
             guard let argumentLabel: String = aDecoder.decode(forKey: "argumentLabel") else { return nil }; self.argumentLabel = argumentLabel
             guard let name: String = aDecoder.decode(forKey: "name") else { return nil }; self.name = name
             guard let typeName: TypeName = aDecoder.decode(forKey: "typeName") else { return nil }; self.typeName = typeName
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
             guard let name: String = aDecoder.decode(forKey: "name") else { return nil }; self.name = name
             guard let elements: [Element] = aDecoder.decode(forKey: "elements") else { return nil }; self.elements = elements
            
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
             guard let name: String = aDecoder.decode(forKey: "name") else { return nil }; self.name = name
             guard let typeName: TypeName = aDecoder.decode(forKey: "typeName") else { return nil }; self.typeName = typeName
            
            
        }
 
        func encode(with aCoder: NSCoder) {
            
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.typeName, forKey: "typeName")
            
        }
        // } TupleType.Element.NSCoding
}
*/

/*
extension Type: NSCoding {
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
*/

/*
extension TypeName: NSCoding {
        // TypeName.NSCoding {
        required init?(coder aDecoder: NSCoder) {
             guard let name: String = aDecoder.decode(forKey: "name") else { return nil }; self.name = name
            
             self.tuple = aDecoder.decode(forKey: "tuple")
            
        }
 
        func encode(with aCoder: NSCoder) {
            
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.tuple, forKey: "tuple")
            
        }
        // } TypeName.NSCoding
}
*/

/*
extension Typealias: NSCoding {
        // Typealias.NSCoding {
        required init?(coder aDecoder: NSCoder) {
             guard let aliasName: String = aDecoder.decode(forKey: "aliasName") else { return nil }; self.aliasName = aliasName
             guard let typeName: TypeName = aDecoder.decode(forKey: "typeName") else { return nil }; self.typeName = typeName
            
            
             self.parentName = aDecoder.decode(forKey: "parentName")
            
        }
 
        func encode(with aCoder: NSCoder) {
            
            aCoder.encode(self.aliasName, forKey: "aliasName")
            aCoder.encode(self.typeName, forKey: "typeName")
            aCoder.encode(self.parentName, forKey: "parentName")
            
        }
        // } Typealias.NSCoding
}
*/

/*
extension Variable: NSCoding {
        // Variable.NSCoding {
        required init?(coder aDecoder: NSCoder) {
             guard let name: String = aDecoder.decode(forKey: "name") else { return nil }; self.name = name
             guard let typeName: TypeName = aDecoder.decode(forKey: "typeName") else { return nil }; self.typeName = typeName
            
            self.isComputed = aDecoder.decodeBool(forKey: "isComputed")
            self.isStatic = aDecoder.decodeBool(forKey: "isStatic")
             guard let readAccess: String = aDecoder.decode(forKey: "readAccess") else { return nil }; self.readAccess = readAccess
             guard let writeAccess: String = aDecoder.decode(forKey: "writeAccess") else { return nil }; self.writeAccess = writeAccess
             guard let annotations: [String: NSObject] = aDecoder.decode(forKey: "annotations") else { return nil }; self.annotations = annotations
            
            
        }
 
        func encode(with aCoder: NSCoder) {
            
            aCoder.encode(self.name, forKey: "name")
            aCoder.encode(self.typeName, forKey: "typeName")
            aCoder.encode(self.isComputed, forKey: "isComputed")
            aCoder.encode(self.isStatic, forKey: "isStatic")
            aCoder.encode(self.readAccess, forKey: "readAccess")
            aCoder.encode(self.writeAccess, forKey: "writeAccess")
            aCoder.encode(self.annotations, forKey: "annotations")
            
        }
        // } Variable.NSCoding
}
*/
