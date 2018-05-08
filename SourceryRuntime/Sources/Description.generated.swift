// Generated using Sourcery 0.13.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable vertical_whitespace


extension ArrayType {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "name = \(String(describing: self.name)), "
        string += "elementTypeName = \(String(describing: self.elementTypeName))"
        return string
    }
}
extension AssociatedValue {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "localName = \(String(describing: self.localName)), "
        string += "externalName = \(String(describing: self.externalName)), "
        string += "typeName = \(String(describing: self.typeName)), "
        string += "annotations = \(String(describing: self.annotations))"
        return string
    }
}
extension BytesRange {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "offset = \(String(describing: self.offset)), "
        string += "length = \(String(describing: self.length))"
        return string
    }
}
extension Class {
    /// :nodoc:
    override public var description: String {
        var string = super.description
        string += ", "
        string += "kind = \(String(describing: self.kind)), "
        string += "isFinal = \(String(describing: self.isFinal))"
        return string
    }
}
extension ClosureType {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "name = \(String(describing: self.name)), "
        string += "parameters = \(String(describing: self.parameters)), "
        string += "returnTypeName = \(String(describing: self.returnTypeName)), "
        string += "actualReturnTypeName = \(String(describing: self.actualReturnTypeName)), "
        string += "`throws` = \(String(describing: self.`throws`))"
        return string
    }
}
extension DictionaryType {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "name = \(String(describing: self.name)), "
        string += "valueTypeName = \(String(describing: self.valueTypeName)), "
        string += "keyTypeName = \(String(describing: self.keyTypeName))"
        return string
    }
}
extension Enum {
    /// :nodoc:
    override public var description: String {
        var string = super.description
        string += ", "
        string += "cases = \(String(describing: self.cases)), "
        string += "rawTypeName = \(String(describing: self.rawTypeName)), "
        string += "hasAssociatedValues = \(String(describing: self.hasAssociatedValues))"
        return string
    }
}
extension EnumCase {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "name = \(String(describing: self.name)), "
        string += "rawValue = \(String(describing: self.rawValue)), "
        string += "associatedValues = \(String(describing: self.associatedValues)), "
        string += "annotations = \(String(describing: self.annotations)), "
        string += "hasAssociatedValue = \(String(describing: self.hasAssociatedValue))"
        return string
    }
}
extension FileParserResult {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "path = \(String(describing: self.path)), "
        string += "module = \(String(describing: self.module)), "
        string += "types = \(String(describing: self.types)), "
        string += "typealiases = \(String(describing: self.typealiases)), "
        string += "inlineRanges = \(String(describing: self.inlineRanges)), "
        string += "contentSha = \(String(describing: self.contentSha)), "
        string += "sourceryVersion = \(String(describing: self.sourceryVersion))"
        return string
    }
}
extension GenericType {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "name = \(String(describing: self.name)), "
        string += "typeParameters = \(String(describing: self.typeParameters))"
        return string
    }
}
extension GenericTypeParameter {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "typeName = \(String(describing: self.typeName))"
        return string
    }
}
extension Method {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "name = \(String(describing: self.name)), "
        string += "selectorName = \(String(describing: self.selectorName)), "
        string += "parameters = \(String(describing: self.parameters)), "
        string += "returnTypeName = \(String(describing: self.returnTypeName)), "
        string += "`throws` = \(String(describing: self.`throws`)), "
        string += "`rethrows` = \(String(describing: self.`rethrows`)), "
        string += "accessLevel = \(String(describing: self.accessLevel)), "
        string += "isStatic = \(String(describing: self.isStatic)), "
        string += "isClass = \(String(describing: self.isClass)), "
        string += "isFailableInitializer = \(String(describing: self.isFailableInitializer)), "
        string += "annotations = \(String(describing: self.annotations)), "
        string += "definedInTypeName = \(String(describing: self.definedInTypeName)), "
        string += "attributes = \(String(describing: self.attributes))"
        return string
    }
}
extension MethodParameter {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "argumentLabel = \(String(describing: self.argumentLabel)), "
        string += "name = \(String(describing: self.name)), "
        string += "typeName = \(String(describing: self.typeName)), "
        string += "`inout` = \(String(describing: self.`inout`)), "
        string += "typeAttributes = \(String(describing: self.typeAttributes)), "
        string += "defaultValue = \(String(describing: self.defaultValue)), "
        string += "annotations = \(String(describing: self.annotations))"
        return string
    }
}
extension Protocol {
    /// :nodoc:
    override public var description: String {
        var string = super.description
        string += ", "
        string += "kind = \(String(describing: self.kind))"
        return string
    }
}
extension Struct {
    /// :nodoc:
    override public var description: String {
        var string = super.description
        string += ", "
        string += "kind = \(String(describing: self.kind))"
        return string
    }
}
extension Subscript {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "parameters = \(String(describing: self.parameters)), "
        string += "returnTypeName = \(String(describing: self.returnTypeName)), "
        string += "actualReturnTypeName = \(String(describing: self.actualReturnTypeName)), "
        string += "isFinal = \(String(describing: self.isFinal)), "
        string += "readAccess = \(String(describing: self.readAccess)), "
        string += "writeAccess = \(String(describing: self.writeAccess)), "
        string += "isMutable = \(String(describing: self.isMutable)), "
        string += "annotations = \(String(describing: self.annotations)), "
        string += "definedInTypeName = \(String(describing: self.definedInTypeName)), "
        string += "actualDefinedInTypeName = \(String(describing: self.actualDefinedInTypeName)), "
        string += "attributes = \(String(describing: self.attributes))"
        return string
    }
}
extension TemplateContext {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "types = \(String(describing: self.types)), "
        string += "arguments = \(String(describing: self.arguments)), "
        string += "stencilContext = \(String(describing: self.stencilContext))"
        return string
    }
}
extension TupleElement {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "name = \(String(describing: self.name)), "
        string += "typeName = \(String(describing: self.typeName))"
        return string
    }
}
extension TupleType {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "name = \(String(describing: self.name)), "
        string += "elements = \(String(describing: self.elements))"
        return string
    }
}
extension Type {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "module = \(String(describing: self.module)), "
        string += "typealiases = \(String(describing: self.typealiases)), "
        string += "isExtension = \(String(describing: self.isExtension)), "
        string += "kind = \(String(describing: self.kind)), "
        string += "accessLevel = \(String(describing: self.accessLevel)), "
        string += "name = \(String(describing: self.name)), "
        string += "isGeneric = \(String(describing: self.isGeneric)), "
        string += "localName = \(String(describing: self.localName)), "
        string += "variables = \(String(describing: self.variables)), "
        string += "methods = \(String(describing: self.methods)), "
        string += "subscripts = \(String(describing: self.subscripts)), "
        string += "initializers = \(String(describing: self.initializers)), "
        string += "annotations = \(String(describing: self.annotations)), "
        string += "staticVariables = \(String(describing: self.staticVariables)), "
        string += "staticMethods = \(String(describing: self.staticMethods)), "
        string += "classMethods = \(String(describing: self.classMethods)), "
        string += "instanceVariables = \(String(describing: self.instanceVariables)), "
        string += "instanceMethods = \(String(describing: self.instanceMethods)), "
        string += "computedVariables = \(String(describing: self.computedVariables)), "
        string += "storedVariables = \(String(describing: self.storedVariables)), "
        string += "inheritedTypes = \(String(describing: self.inheritedTypes)), "
        string += "containedTypes = \(String(describing: self.containedTypes)), "
        string += "parentName = \(String(describing: self.parentName)), "
        string += "parentTypes = \(String(describing: self.parentTypes)), "
        string += "attributes = \(String(describing: self.attributes))"
        return string
    }
}
extension Typealias {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "aliasName = \(String(describing: self.aliasName)), "
        string += "typeName = \(String(describing: self.typeName)), "
        string += "parentName = \(String(describing: self.parentName)), "
        string += "name = \(String(describing: self.name))"
        return string
    }
}
extension Types {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "types = \(String(describing: self.types))"
        return string
    }
}
extension Variable {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "name = \(String(describing: self.name)), "
        string += "typeName = \(String(describing: self.typeName)), "
        string += "isComputed = \(String(describing: self.isComputed)), "
        string += "isStatic = \(String(describing: self.isStatic)), "
        string += "readAccess = \(String(describing: self.readAccess)), "
        string += "writeAccess = \(String(describing: self.writeAccess)), "
        string += "isMutable = \(String(describing: self.isMutable)), "
        string += "defaultValue = \(String(describing: self.defaultValue)), "
        string += "annotations = \(String(describing: self.annotations)), "
        string += "attributes = \(String(describing: self.attributes)), "
        string += "isFinal = \(String(describing: self.isFinal)), "
        string += "definedInTypeName = \(String(describing: self.definedInTypeName)), "
        string += "actualDefinedInTypeName = \(String(describing: self.actualDefinedInTypeName))"
        return string
    }
}
