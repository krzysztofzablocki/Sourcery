// Generated using Sourcery 0.5.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import Foundation


extension NSCoder {

    @nonobjc func decode(forKey: String) -> String? {
        return self.decode(forKey: forKey) as String?
    }

    @nonobjc func decode(forKey: String) -> TypeName? {
        return self.decode(forKey: forKey) as TypeName?
    }

    @nonobjc func decode(forKey: String) -> AccessLevel? {
        return self.decode(forKey: forKey) as AccessLevel?
    }

    func decode<E, V>(forKey: String) -> [E: V]? {
        guard let object = self.decodeObject(forKey: forKey) else {
            return nil
        }

        return object as? [E:V]
    }

    func decode<E>(forKey: String) -> E? {
        guard let object = self.decodeObject(forKey: forKey) else {
            return nil
        }

        return object as? E
    }

    func decode<E>(forKey: String) -> [E]? {
        guard let object = self.decodeObject(forKey: forKey) else {
            return []
        }

        return object as? [E]
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
         self.cases = aDecoder.decode(forKey: "cases")
         self.rawType = aDecoder.decode(forKey: "rawType")
        
        
        super.init(coder: aDecoder)
    }
 
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.cases, forKey: "cases")
        aCoder.encode(self.rawType, forKey: "rawType")
        
    }
    // } Enum.NSCoding
}
*/
    
/*
extension Enum.Case: NSCoding {
    // Enum.Case.NSCoding {
    required init?(coder aDecoder: NSCoder) {
         self.name = aDecoder.decode(forKey: "name")
         self.rawValue = aDecoder.decode(forKey: "rawValue")
         self.associatedValues = aDecoder.decode(forKey: "associatedValues")
         self.annotations = aDecoder.decode(forKey: "annotations")
        
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
         self.typeName = aDecoder.decode(forKey: "typeName")
        
        
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
         self.types = aDecoder.decode(forKey: "types")
         self.typeByName = aDecoder.decode(forKey: "typeByName")
         self.arguments = aDecoder.decode(forKey: "arguments")
         self.classes = aDecoder.decode(forKey: "classes")
         self.all = aDecoder.decode(forKey: "all")
         self.protocols = aDecoder.decode(forKey: "protocols")
         self.structs = aDecoder.decode(forKey: "structs")
         self.enums = aDecoder.decode(forKey: "enums")
        
    }
 
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.types, forKey: "types")
        aCoder.encode(self.typeByName, forKey: "typeByName")
        aCoder.encode(self.arguments, forKey: "arguments")
        aCoder.encode(self.classes, forKey: "classes")
        aCoder.encode(self.all, forKey: "all")
        aCoder.encode(self.protocols, forKey: "protocols")
        aCoder.encode(self.structs, forKey: "structs")
        aCoder.encode(self.enums, forKey: "enums")
        
    }
    // } GenerationContext.NSCoding
}
*/
    
/*
extension Method: NSCoding {
    // Method.NSCoding {
    required init?(coder aDecoder: NSCoder) {
         self.selectorName = aDecoder.decode(forKey: "selectorName")
         self.parameters = aDecoder.decode(forKey: "parameters")
         self.returnTypeName = aDecoder.decode(forKey: "returnTypeName")
        
         self.accessLevel = aDecoder.decode(forKey: "accessLevel")
         self.isStatic = aDecoder.decode(forKey: "isStatic")
         self.isClass = aDecoder.decode(forKey: "isClass")
         self.isFailableInitializer = aDecoder.decode(forKey: "isFailableInitializer")
         self.annotations = aDecoder.decode(forKey: "annotations")
        
        
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
         self.argumentLabel = aDecoder.decode(forKey: "argumentLabel")
         self.name = aDecoder.decode(forKey: "name")
         self.typeName = aDecoder.decode(forKey: "typeName")
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
         self.name = aDecoder.decode(forKey: "name")
         self.elements = aDecoder.decode(forKey: "elements")
        
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
         self.name = aDecoder.decode(forKey: "name")
         self.typeName = aDecoder.decode(forKey: "typeName")
        
        
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
         self.typealiases = aDecoder.decode(forKey: "typealiases")
         self.isExtension = aDecoder.decode(forKey: "isExtension")
         self.accessLevel = aDecoder.decode(forKey: "accessLevel")
         self.isGeneric = aDecoder.decode(forKey: "isGeneric")
         self.localName = aDecoder.decode(forKey: "localName")
         self.variables = aDecoder.decode(forKey: "variables")
         self.methods = aDecoder.decode(forKey: "methods")
         self.annotations = aDecoder.decode(forKey: "annotations")
         self.inheritedTypes = aDecoder.decode(forKey: "inheritedTypes")
        
        
        
         self.containedTypes = aDecoder.decode(forKey: "containedTypes")
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
         self.name = aDecoder.decode(forKey: "name")
        
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
         self.aliasName = aDecoder.decode(forKey: "aliasName")
         self.typeName = aDecoder.decode(forKey: "typeName")
        
        
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
         self.name = aDecoder.decode(forKey: "name")
         self.typeName = aDecoder.decode(forKey: "typeName")
        
         self.isComputed = aDecoder.decode(forKey: "isComputed")
         self.isStatic = aDecoder.decode(forKey: "isStatic")
         self.readAccess = aDecoder.decode(forKey: "readAccess")
         self.writeAccess = aDecoder.decode(forKey: "writeAccess")
         self.annotations = aDecoder.decode(forKey: "annotations")
        
        
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
    
