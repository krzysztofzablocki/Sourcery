// Generated using Sourcery 1.8.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable vertical_whitespace


extension ArrayType {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "name = \(String(describing: self.name)), "
        string += "elementTypeName = \(String(describing: self.elementTypeName)), "
        string += "asGeneric = \(String(describing: self.asGeneric)), "
        string += "asSource = \(String(describing: self.asSource))"
        return string
    }
}
extension AssociatedType {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "name = \(String(describing: self.name)), "
        string += "typeName = \(String(describing: self.typeName))"
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
        string += "defaultValue = \(String(describing: self.defaultValue)), "
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
extension ClosureParameter {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "argumentLabel = \(String(describing: self.argumentLabel)), "
        string += "name = \(String(describing: self.name)), "
        string += "typeName = \(String(describing: self.typeName)), "
        string += "`inout` = \(String(describing: self.`inout`)), "
        string += "typeAttributes = \(String(describing: self.typeAttributes)), "
        string += "defaultValue = \(String(describing: self.defaultValue)), "
        string += "annotations = \(String(describing: self.annotations)), "
        string += "asSource = \(String(describing: self.asSource))"
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
        string += "isAsync = \(String(describing: self.isAsync)), "
        string += "asyncKeyword = \(String(describing: self.asyncKeyword)), "
        string += "`throws` = \(String(describing: self.`throws`)), "
        string += "throwsOrRethrowsKeyword = \(String(describing: self.throwsOrRethrowsKeyword)), "
        string += "asSource = \(String(describing: self.asSource))"
        return string
    }
}
extension DictionaryType {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "name = \(String(describing: self.name)), "
        string += "valueTypeName = \(String(describing: self.valueTypeName)), "
        string += "keyTypeName = \(String(describing: self.keyTypeName)), "
        string += "asGeneric = \(String(describing: self.asGeneric)), "
        string += "asSource = \(String(describing: self.asSource))"
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
        string += "documentation = \(String(describing: self.documentation)), "
        string += "indirect = \(String(describing: self.indirect)), "
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
        string += "functions = \(String(describing: self.functions)), "
        string += "typealiases = \(String(describing: self.typealiases)), "
        string += "inlineRanges = \(String(describing: self.inlineRanges)), "
        string += "inlineIndentations = \(String(describing: self.inlineIndentations)), "
        string += "modifiedDate = \(String(describing: self.modifiedDate)), "
        string += "sourceryVersion = \(String(describing: self.sourceryVersion)), "
        string += "isEmpty = \(String(describing: self.isEmpty))"
        return string
    }
}
extension GenericRequirement {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "leftType = \(String(describing: self.leftType)), "
        string += "rightType = \(String(describing: self.rightType)), "
        string += "relationship = \(String(describing: self.relationship)), "
        string += "relationshipSyntax = \(String(describing: self.relationshipSyntax))"
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
        string += "isAsync = \(String(describing: self.isAsync)), "
        string += "`throws` = \(String(describing: self.`throws`)), "
        string += "`rethrows` = \(String(describing: self.`rethrows`)), "
        string += "accessLevel = \(String(describing: self.accessLevel)), "
        string += "isStatic = \(String(describing: self.isStatic)), "
        string += "isClass = \(String(describing: self.isClass)), "
        string += "isFailableInitializer = \(String(describing: self.isFailableInitializer)), "
        string += "annotations = \(String(describing: self.annotations)), "
        string += "documentation = \(String(describing: self.documentation)), "
        string += "definedInTypeName = \(String(describing: self.definedInTypeName)), "
        string += "attributes = \(String(describing: self.attributes)), "
        string += "modifiers = \(String(describing: self.modifiers))"
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
        string += "isVariadic = \(String(describing: self.isVariadic)), "
        string += "typeAttributes = \(String(describing: self.typeAttributes)), "
        string += "defaultValue = \(String(describing: self.defaultValue)), "
        string += "annotations = \(String(describing: self.annotations)), "
        string += "asSource = \(String(describing: self.asSource))"
        return string
    }
}
extension Protocol {
    /// :nodoc:
    override public var description: String {
        var string = super.description
        string += ", "
        string += "kind = \(String(describing: self.kind)), "
        string += "associatedTypes = \(String(describing: self.associatedTypes)), "
        string += "genericRequirements = \(String(describing: self.genericRequirements))"
        return string
    }
}
extension ProtocolComposition {
    /// :nodoc:
    override public var description: String {
        var string = super.description
        string += ", "
        string += "kind = \(String(describing: self.kind)), "
        string += "composedTypeNames = \(String(describing: self.composedTypeNames))"
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
        string += "documentation = \(String(describing: self.documentation)), "
        string += "definedInTypeName = \(String(describing: self.definedInTypeName)), "
        string += "actualDefinedInTypeName = \(String(describing: self.actualDefinedInTypeName)), "
        string += "attributes = \(String(describing: self.attributes)), "
        string += "modifiers = \(String(describing: self.modifiers))"
        return string
    }
}
extension TemplateContext {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "parserResult = \(String(describing: self.parserResult)), "
        string += "functions = \(String(describing: self.functions)), "
        string += "types = \(String(describing: self.types)), "
        string += "argument = \(String(describing: self.argument)), "
        string += "stencilContext = \(String(describing: self.stencilContext))"
        return string
    }
}
extension TupleElement {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "name = \(String(describing: self.name)), "
        string += "typeName = \(String(describing: self.typeName)), "
        string += "asSource = \(String(describing: self.asSource))"
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
        string += "imports = \(String(describing: self.imports)), "
        string += "allImports = \(String(describing: self.allImports)), "
        string += "typealiases = \(String(describing: self.typealiases)), "
        string += "isExtension = \(String(describing: self.isExtension)), "
        string += "kind = \(String(describing: self.kind)), "
        string += "accessLevel = \(String(describing: self.accessLevel)), "
        string += "name = \(String(describing: self.name)), "
        string += "isUnknownExtension = \(String(describing: self.isUnknownExtension)), "
        string += "isGeneric = \(String(describing: self.isGeneric)), "
        string += "localName = \(String(describing: self.localName)), "
        string += "rawVariables = \(String(describing: self.rawVariables)), "
        string += "rawMethods = \(String(describing: self.rawMethods)), "
        string += "rawSubscripts = \(String(describing: self.rawSubscripts)), "
        string += "initializers = \(String(describing: self.initializers)), "
        string += "annotations = \(String(describing: self.annotations)), "
        string += "documentation = \(String(describing: self.documentation)), "
        string += "staticVariables = \(String(describing: self.staticVariables)), "
        string += "staticMethods = \(String(describing: self.staticMethods)), "
        string += "classMethods = \(String(describing: self.classMethods)), "
        string += "instanceVariables = \(String(describing: self.instanceVariables)), "
        string += "instanceMethods = \(String(describing: self.instanceMethods)), "
        string += "computedVariables = \(String(describing: self.computedVariables)), "
        string += "storedVariables = \(String(describing: self.storedVariables)), "
        string += "inheritedTypes = \(String(describing: self.inheritedTypes)), "
        string += "inherits = \(String(describing: self.inherits)), "
        string += "containedTypes = \(String(describing: self.containedTypes)), "
        string += "parentName = \(String(describing: self.parentName)), "
        string += "parentTypes = \(String(describing: self.parentTypes)), "
        string += "attributes = \(String(describing: self.attributes)), "
        string += "modifiers = \(String(describing: self.modifiers)), "
        string += "fileName = \(String(describing: self.fileName))"
        return string
    }
}
extension Typealias {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "aliasName = \(String(describing: self.aliasName)), "
        string += "typeName = \(String(describing: self.typeName)), "
        string += "module = \(String(describing: self.module)), "
        string += "accessLevel = \(String(describing: self.accessLevel)), "
        string += "parentName = \(String(describing: self.parentName)), "
        string += "name = \(String(describing: self.name))"
        return string
    }
}
extension Types {
    /// :nodoc:
    override public var description: String {
        var string = "\(Swift.type(of: self)): "
        string += "types = \(String(describing: self.types)), "
        string += "typealiases = \(String(describing: self.typealiases))"
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
        string += "isAsync = \(String(describing: self.isAsync)), "
        string += "`throws` = \(String(describing: self.`throws`)), "
        string += "isStatic = \(String(describing: self.isStatic)), "
        string += "readAccess = \(String(describing: self.readAccess)), "
        string += "writeAccess = \(String(describing: self.writeAccess)), "
        string += "accessLevel = \(String(describing: self.accessLevel)), "
        string += "isMutable = \(String(describing: self.isMutable)), "
        string += "defaultValue = \(String(describing: self.defaultValue)), "
        string += "annotations = \(String(describing: self.annotations)), "
        string += "documentation = \(String(describing: self.documentation)), "
        string += "attributes = \(String(describing: self.attributes)), "
        string += "modifiers = \(String(describing: self.modifiers)), "
        string += "isFinal = \(String(describing: self.isFinal)), "
        string += "isLazy = \(String(describing: self.isLazy)), "
        string += "definedInTypeName = \(String(describing: self.definedInTypeName)), "
        string += "actualDefinedInTypeName = \(String(describing: self.actualDefinedInTypeName))"
        return string
    }
}
