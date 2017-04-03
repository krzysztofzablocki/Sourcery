// Generated using Sourcery 0.5.9 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

extension ArrayType {
    override var description: String {
        var string = "\(type(of: self)): "
        string += "name = \(self.name), "
        string += "elementTypeName = \(self.elementTypeName), "
        string += "elementType = \(String(describing: self.elementType))"
        return string
    }
}
extension AssociatedValue {
    override var description: String {
        var string = "\(type(of: self)): "
        string += "localName = \(String(describing: self.localName)), "
        string += "externalName = \(String(describing: self.externalName)), "
        string += "typeName = \(self.typeName)"
        return string
    }
}
extension Class {
    override var description: String {
        var string = super.description
        string += "kind = \(self.kind)"
        return string
    }
}
extension DictionaryType {
    override var description: String {
        var string = "\(type(of: self)): "
        string += "name = \(self.name), "
        string += "valueTypeName = \(self.valueTypeName), "
        string += "valueType = \(String(describing: self.valueType)), "
        string += "keyTypeName = \(self.keyTypeName), "
        string += "keyType = \(String(describing: self.keyType))"
        return string
    }
}
extension Enum {
    override var description: String {
        var string = super.description
        string += "cases = \(self.cases), "
        string += "rawTypeName = \(String(describing: self.rawTypeName)), "
        string += "hasAssociatedValues = \(self.hasAssociatedValues)"
        return string
    }
}
extension EnumCase {
    override var description: String {
        var string = "\(type(of: self)): "
        string += "name = \(self.name), "
        string += "rawValue = \(String(describing: self.rawValue)), "
        string += "associatedValues = \(self.associatedValues), "
        string += "annotations = \(self.annotations), "
        string += "hasAssociatedValue = \(self.hasAssociatedValue)"
        return string
    }
}
extension FileParserResult {
    override var description: String {
        var string = "\(type(of: self)): "
        string += "path = \(String(describing: self.path)), "
        string += "module = \(String(describing: self.module)), "
        string += "types = \(self.types), "
        string += "typealiases = \(self.typealiases), "
        string += "inlineRanges = \(self.inlineRanges), "
        string += "contentSha = \(String(describing: self.contentSha)), "
        string += "sourceryVersion = \(self.sourceryVersion)"
        return string
    }
}
extension GenerationContext {
    override var description: String {
        var string = "\(type(of: self)): "
        string += "types = \(self.types), "
        string += "typeByName = \(self.typeByName), "
        string += "arguments = \(self.arguments), "
        string += "classes = \(self.classes), "
        string += "all = \(self.all), "
        string += "protocols = \(self.protocols), "
        string += "structs = \(self.structs), "
        string += "enums = \(self.enums)"
        return string
    }
}
extension Method {
    override var description: String {
        var string = "\(type(of: self)): "
        string += "name = \(self.name), "
        string += "parameters = \(self.parameters), "
        string += "shortName = \(self.shortName), "
        string += "returnTypeName = \(self.returnTypeName), "
        string += "actualReturnTypeName = \(self.actualReturnTypeName), "
        string += "`throws` = \(self.`throws`), "
        string += "accessLevel = \(self.accessLevel), "
        string += "isStatic = \(self.isStatic), "
        string += "isClass = \(self.isClass), "
        string += "isInitializer = \(self.isInitializer), "
        string += "isFailableInitializer = \(self.isFailableInitializer), "
        string += "annotations = \(self.annotations), "
        string += "attributes = \(self.attributes)"
        return string
    }
}
extension MethodParameter {
    override var description: String {
        var string = "\(type(of: self)): "
        string += "argumentLabel = \(String(describing: self.argumentLabel)), "
        string += "name = \(String(describing: self.name)), "
        string += "typeName = \(self.typeName), "
        string += "typeAttributes = \(self.typeAttributes)"
        return string
    }
}
extension Protocol {
    override var description: String {
        var string = super.description
        string += "kind = \(self.kind)"
        return string
    }
}
extension Struct {
    override var description: String {
        var string = super.description
        string += "kind = \(self.kind)"
        return string
    }
}
extension TupleElement {
    override var description: String {
        var string = "\(type(of: self)): "
        string += "name = \(self.name), "
        string += "typeName = \(self.typeName)"
        return string
    }
}
extension TupleType {
    override var description: String {
        var string = "\(type(of: self)): "
        string += "name = \(self.name), "
        string += "elements = \(self.elements)"
        return string
    }
}
extension Type {
    override var description: String {
        var string = "\(type(of: self)): "
        string += "module = \(String(describing: self.module)), "
        string += "typealiases = \(self.typealiases), "
        string += "isExtension = \(self.isExtension), "
        string += "kind = \(self.kind), "
        string += "accessLevel = \(self.accessLevel), "
        string += "name = \(self.name), "
        string += "isGeneric = \(self.isGeneric), "
        string += "localName = \(self.localName), "
        string += "variables = \(self.variables), "
        string += "methods = \(self.methods), "
        string += "initializers = \(self.initializers), "
        string += "annotations = \(self.annotations), "
        string += "staticVariables = \(self.staticVariables), "
        string += "instanceVariables = \(self.instanceVariables), "
        string += "computedVariables = \(self.computedVariables), "
        string += "storedVariables = \(self.storedVariables), "
        string += "inheritedTypes = \(self.inheritedTypes), "
        string += "containedTypes = \(self.containedTypes), "
        string += "parentName = \(String(describing: self.parentName)), "
        string += "parentTypes = \(self.parentTypes), "
        string += "attributes = \(self.attributes)"
        return string
    }
}
extension TypeDefinition {
    override var description: String {
        var string = "\(type(of: self)): "
        string += "path = \(self.path), "
        string += "bodyOffset = \(self.bodyOffset), "
        string += "bodyStartPosition = \(self.bodyStartPosition), "
        string += "bodyLength = \(self.bodyLength), "
        string += "bodyEndPosition = \(self.bodyEndPosition)"
        return string
    }
}
extension Typealias {
    override var description: String {
        var string = "\(type(of: self)): "
        string += "aliasName = \(self.aliasName), "
        string += "typeName = \(self.typeName), "
        string += "parentName = \(String(describing: self.parentName)), "
        string += "name = \(self.name)"
        return string
    }
}
extension Variable {
    override var description: String {
        var string = "\(type(of: self)): "
        string += "name = \(self.name), "
        string += "typeName = \(self.typeName), "
        string += "isComputed = \(self.isComputed), "
        string += "isStatic = \(self.isStatic), "
        string += "readAccess = \(self.readAccess), "
        string += "writeAccess = \(self.writeAccess), "
        string += "annotations = \(self.annotations), "
        string += "attributes = \(self.attributes)"
        return string
    }
}
