// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable vertical_whitespace

#if canImport(ObjectiveC)
// MARK: - Actor AutoHashable
extension Actor {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(super.hash)
        return hasher.finalize()
    }
}
// MARK: - ArrayType AutoHashable
extension ArrayType {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.elementTypeName)
        return hasher.finalize()
    }
}
// MARK: - AssociatedType AutoHashable
extension AssociatedType {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.typeName)
        return hasher.finalize()
    }
}
// MARK: - AssociatedValue AutoHashable
extension AssociatedValue {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.localName)
        hasher.combine(self.externalName)
        hasher.combine(self.typeName)
        hasher.combine(self.defaultValue)
        hasher.combine(self.annotations)
        return hasher.finalize()
    }
}
// MARK: - Attribute AutoHashable
extension Attribute {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.arguments)
        hasher.combine(self._description)
        return hasher.finalize()
    }
}
// MARK: - BytesRange AutoHashable
extension BytesRange {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.offset)
        hasher.combine(self.length)
        return hasher.finalize()
    }
}
// MARK: - Class AutoHashable
extension Class {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(super.hash)
        return hasher.finalize()
    }
}
// MARK: - ClosureParameter AutoHashable
extension ClosureParameter {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.argumentLabel)
        hasher.combine(self.name)
        hasher.combine(self.typeName)
        hasher.combine(self.`inout`)
        hasher.combine(self.defaultValue)
        hasher.combine(self.annotations)
        return hasher.finalize()
    }
}
// MARK: - ClosureType AutoHashable
extension ClosureType {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.parameters)
        hasher.combine(self.returnTypeName)
        hasher.combine(self.isAsync)
        hasher.combine(self.asyncKeyword)
        hasher.combine(self.`throws`)
        hasher.combine(self.throwsOrRethrowsKeyword)
        return hasher.finalize()
    }
}
// MARK: - DictionaryType AutoHashable
extension DictionaryType {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.valueTypeName)
        hasher.combine(self.keyTypeName)
        return hasher.finalize()
    }
}
// MARK: - DiffableResult AutoHashable
extension DiffableResult {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.identifier)
        return hasher.finalize()
    }
}
// MARK: - Enum AutoHashable
extension Enum {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.cases)
        hasher.combine(self.rawTypeName)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
}
// MARK: - EnumCase AutoHashable
extension EnumCase {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.rawValue)
        hasher.combine(self.associatedValues)
        hasher.combine(self.annotations)
        hasher.combine(self.documentation)
        hasher.combine(self.indirect)
        return hasher.finalize()
    }
}
// MARK: - FileParserResult AutoHashable
extension FileParserResult {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.path)
        hasher.combine(self.module)
        hasher.combine(self.types)
        hasher.combine(self.functions)
        hasher.combine(self.typealiases)
        hasher.combine(self.inlineRanges)
        hasher.combine(self.inlineIndentations)
        hasher.combine(self.modifiedDate)
        hasher.combine(self.sourceryVersion)
        return hasher.finalize()
    }
}
// MARK: - GenericRequirement AutoHashable
extension GenericRequirement {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.leftType)
        hasher.combine(self.rightType)
        hasher.combine(self.relationship)
        hasher.combine(self.relationshipSyntax)
        return hasher.finalize()
    }
}
// MARK: - GenericType AutoHashable
extension GenericType {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.typeParameters)
        return hasher.finalize()
    }
}
// MARK: - GenericTypeParameter AutoHashable
extension GenericTypeParameter {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.typeName)
        return hasher.finalize()
    }
}
// MARK: - Import AutoHashable
extension Import {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.kind)
        hasher.combine(self.path)
        return hasher.finalize()
    }
}
// MARK: - Method AutoHashable
extension Method {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.selectorName)
        hasher.combine(self.parameters)
        hasher.combine(self.returnTypeName)
        hasher.combine(self.isAsync)
        hasher.combine(self.`throws`)
        hasher.combine(self.`rethrows`)
        hasher.combine(self.accessLevel)
        hasher.combine(self.isStatic)
        hasher.combine(self.isClass)
        hasher.combine(self.isFailableInitializer)
        hasher.combine(self.annotations)
        hasher.combine(self.documentation)
        hasher.combine(self.definedInTypeName)
        hasher.combine(self.attributes)
        hasher.combine(self.modifiers)
        return hasher.finalize()
    }
}
// MARK: - MethodParameter AutoHashable
extension MethodParameter {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.argumentLabel)
        hasher.combine(self.name)
        hasher.combine(self.typeName)
        hasher.combine(self.`inout`)
        hasher.combine(self.isVariadic)
        hasher.combine(self.defaultValue)
        hasher.combine(self.annotations)
        return hasher.finalize()
    }
}
// MARK: - Modifier AutoHashable
extension Modifier {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.detail)
        return hasher.finalize()
    }
}
// MARK: - Protocol AutoHashable
extension Protocol {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.associatedTypes)
        hasher.combine(self.genericRequirements)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
}
// MARK: - ProtocolComposition AutoHashable
extension ProtocolComposition {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.composedTypeNames)
        hasher.combine(super.hash)
        return hasher.finalize()
    }
}
// MARK: - Struct AutoHashable
extension Struct {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(super.hash)
        return hasher.finalize()
    }
}
// MARK: - Subscript AutoHashable
extension Subscript {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.parameters)
        hasher.combine(self.returnTypeName)
        hasher.combine(self.readAccess)
        hasher.combine(self.writeAccess)
        hasher.combine(self.annotations)
        hasher.combine(self.documentation)
        hasher.combine(self.definedInTypeName)
        hasher.combine(self.attributes)
        hasher.combine(self.modifiers)
        return hasher.finalize()
    }
}
// MARK: - TemplateContext AutoHashable
extension TemplateContext {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.parserResult)
        hasher.combine(self.functions)
        hasher.combine(self.types)
        hasher.combine(self.argument)
        return hasher.finalize()
    }
}
// MARK: - TupleElement AutoHashable
extension TupleElement {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.typeName)
        return hasher.finalize()
    }
}
// MARK: - TupleType AutoHashable
extension TupleType {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.elements)
        return hasher.finalize()
    }
}
// MARK: - Type AutoHashable
extension Type {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.module)
        hasher.combine(self.imports)
        hasher.combine(self.typealiases)
        hasher.combine(self.isExtension)
        hasher.combine(self.accessLevel)
        hasher.combine(self.isUnknownExtension)
        hasher.combine(self.isGeneric)
        hasher.combine(self.localName)
        hasher.combine(self.rawVariables)
        hasher.combine(self.rawMethods)
        hasher.combine(self.rawSubscripts)
        hasher.combine(self.annotations)
        hasher.combine(self.documentation)
        hasher.combine(self.inheritedTypes)
        hasher.combine(self.inherits)
        hasher.combine(self.containedTypes)
        hasher.combine(self.parentName)
        hasher.combine(self.attributes)
        hasher.combine(self.modifiers)
        hasher.combine(self.fileName)
        hasher.combine(kind)
        return hasher.finalize()
    }
}
// MARK: - TypeName AutoHashable
extension TypeName {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.generic)
        hasher.combine(self.isProtocolComposition)
        hasher.combine(self.attributes)
        hasher.combine(self.modifiers)
        hasher.combine(self.tuple)
        hasher.combine(self.array)
        hasher.combine(self.dictionary)
        hasher.combine(self.closure)
        return hasher.finalize()
    }
}
// MARK: - Typealias AutoHashable
extension Typealias {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.aliasName)
        hasher.combine(self.typeName)
        hasher.combine(self.module)
        hasher.combine(self.accessLevel)
        hasher.combine(self.parentName)
        return hasher.finalize()
    }
}
// MARK: - Types AutoHashable
extension Types {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.types)
        hasher.combine(self.typealiases)
        return hasher.finalize()
    }
}
// MARK: - Variable AutoHashable
extension Variable {
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.name)
        hasher.combine(self.typeName)
        hasher.combine(self.isComputed)
        hasher.combine(self.isAsync)
        hasher.combine(self.`throws`)
        hasher.combine(self.isStatic)
        hasher.combine(self.readAccess)
        hasher.combine(self.writeAccess)
        hasher.combine(self.defaultValue)
        hasher.combine(self.annotations)
        hasher.combine(self.documentation)
        hasher.combine(self.attributes)
        hasher.combine(self.modifiers)
        hasher.combine(self.definedInTypeName)
        return hasher.finalize()
    }
}
#endif
