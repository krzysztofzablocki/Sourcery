// Generated using Sourcery 0.13.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable vertical_whitespace


extension ArrayType {
    /// :nodoc:
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? ArrayType else { return false }
        if self.name != rhs.name { return false }
        if self.elementTypeName != rhs.elementTypeName { return false }
        return true
    }
}
extension AssociatedValue {
    /// :nodoc:
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? AssociatedValue else { return false }
        if self.localName != rhs.localName { return false }
        if self.externalName != rhs.externalName { return false }
        if self.typeName != rhs.typeName { return false }
        if self.annotations != rhs.annotations { return false }
        return true
    }
}
extension Attribute {
    /// :nodoc:
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Attribute else { return false }
        if self.name != rhs.name { return false }
        if self.arguments != rhs.arguments { return false }
        if self._description != rhs._description { return false }
        return true
    }
}
extension BytesRange {
    /// :nodoc:
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? BytesRange else { return false }
        if self.offset != rhs.offset { return false }
        if self.length != rhs.length { return false }
        return true
    }
}
extension Class {
    /// :nodoc:
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Class else { return false }
        return super.isEqual(rhs)
    }
}
extension ClosureType {
    /// :nodoc:
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? ClosureType else { return false }
        if self.name != rhs.name { return false }
        if self.parameters != rhs.parameters { return false }
        if self.returnTypeName != rhs.returnTypeName { return false }
        if self.`throws` != rhs.`throws` { return false }
        return true
    }
}
extension DictionaryType {
    /// :nodoc:
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? DictionaryType else { return false }
        if self.name != rhs.name { return false }
        if self.valueTypeName != rhs.valueTypeName { return false }
        if self.keyTypeName != rhs.keyTypeName { return false }
        return true
    }
}
extension DiffableResult {
    /// :nodoc:
    override internal func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? DiffableResult else { return false }
        if self.identifier != rhs.identifier { return false }
        return true
    }
}
extension Enum {
    /// :nodoc:
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Enum else { return false }
        if self.cases != rhs.cases { return false }
        if self.rawTypeName != rhs.rawTypeName { return false }
        return super.isEqual(rhs)
    }
}
extension EnumCase {
    /// :nodoc:
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? EnumCase else { return false }
        if self.name != rhs.name { return false }
        if self.rawValue != rhs.rawValue { return false }
        if self.associatedValues != rhs.associatedValues { return false }
        if self.annotations != rhs.annotations { return false }
        return true
    }
}
extension FileParserResult {
    /// :nodoc:
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? FileParserResult else { return false }
        if self.path != rhs.path { return false }
        if self.module != rhs.module { return false }
        if self.types != rhs.types { return false }
        if self.typealiases != rhs.typealiases { return false }
        if self.inlineRanges != rhs.inlineRanges { return false }
        if self.contentSha != rhs.contentSha { return false }
        if self.sourceryVersion != rhs.sourceryVersion { return false }
        return true
    }
}
extension GenericType {
    /// :nodoc:
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? GenericType else { return false }
        if self.name != rhs.name { return false }
        if self.typeParameters != rhs.typeParameters { return false }
        return true
    }
}
extension GenericTypeParameter {
    /// :nodoc:
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? GenericTypeParameter else { return false }
        if self.typeName != rhs.typeName { return false }
        return true
    }
}
extension Method {
    /// :nodoc:
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Method else { return false }
        if self.name != rhs.name { return false }
        if self.selectorName != rhs.selectorName { return false }
        if self.parameters != rhs.parameters { return false }
        if self.returnTypeName != rhs.returnTypeName { return false }
        if self.`throws` != rhs.`throws` { return false }
        if self.`rethrows` != rhs.`rethrows` { return false }
        if self.accessLevel != rhs.accessLevel { return false }
        if self.isStatic != rhs.isStatic { return false }
        if self.isClass != rhs.isClass { return false }
        if self.isFailableInitializer != rhs.isFailableInitializer { return false }
        if self.annotations != rhs.annotations { return false }
        if self.definedInTypeName != rhs.definedInTypeName { return false }
        if self.attributes != rhs.attributes { return false }
        return true
    }
}
extension MethodParameter {
    /// :nodoc:
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? MethodParameter else { return false }
        if self.argumentLabel != rhs.argumentLabel { return false }
        if self.name != rhs.name { return false }
        if self.typeName != rhs.typeName { return false }
        if self.`inout` != rhs.`inout` { return false }
        if self.defaultValue != rhs.defaultValue { return false }
        if self.annotations != rhs.annotations { return false }
        return true
    }
}
extension Protocol {
    /// :nodoc:
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Protocol else { return false }
        return super.isEqual(rhs)
    }
}
extension Struct {
    /// :nodoc:
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Struct else { return false }
        return super.isEqual(rhs)
    }
}
extension Subscript {
    /// :nodoc:
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Subscript else { return false }
        if self.parameters != rhs.parameters { return false }
        if self.returnTypeName != rhs.returnTypeName { return false }
        if self.readAccess != rhs.readAccess { return false }
        if self.writeAccess != rhs.writeAccess { return false }
        if self.annotations != rhs.annotations { return false }
        if self.definedInTypeName != rhs.definedInTypeName { return false }
        if self.attributes != rhs.attributes { return false }
        return true
    }
}
extension TemplateContext {
    /// :nodoc:
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TemplateContext else { return false }
        if self.types != rhs.types { return false }
        if self.arguments != rhs.arguments { return false }
        return true
    }
}
extension TupleElement {
    /// :nodoc:
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TupleElement else { return false }
        if self.name != rhs.name { return false }
        if self.typeName != rhs.typeName { return false }
        return true
    }
}
extension TupleType {
    /// :nodoc:
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TupleType else { return false }
        if self.name != rhs.name { return false }
        if self.elements != rhs.elements { return false }
        return true
    }
}
extension Type {
    /// :nodoc:
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Type else { return false }
        if self.module != rhs.module { return false }
        if self.typealiases != rhs.typealiases { return false }
        if self.isExtension != rhs.isExtension { return false }
        if self.accessLevel != rhs.accessLevel { return false }
        if self.isGeneric != rhs.isGeneric { return false }
        if self.localName != rhs.localName { return false }
        if self.variables != rhs.variables { return false }
        if self.methods != rhs.methods { return false }
        if self.subscripts != rhs.subscripts { return false }
        if self.annotations != rhs.annotations { return false }
        if self.inheritedTypes != rhs.inheritedTypes { return false }
        if self.containedTypes != rhs.containedTypes { return false }
        if self.parentName != rhs.parentName { return false }
        if self.attributes != rhs.attributes { return false }
        if self.kind != rhs.kind { return false }
        return true
    }
}
extension TypeName {
    /// :nodoc:
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TypeName else { return false }
        if self.name != rhs.name { return false }
        if self.generic != rhs.generic { return false }
        if self.isGeneric != rhs.isGeneric { return false }
        if self.attributes != rhs.attributes { return false }
        if self.tuple != rhs.tuple { return false }
        if self.array != rhs.array { return false }
        if self.dictionary != rhs.dictionary { return false }
        if self.closure != rhs.closure { return false }
        return true
    }
}
extension Typealias {
    /// :nodoc:
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Typealias else { return false }
        if self.aliasName != rhs.aliasName { return false }
        if self.typeName != rhs.typeName { return false }
        if self.parentName != rhs.parentName { return false }
        return true
    }
}
extension Types {
    /// :nodoc:
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Types else { return false }
        if self.types != rhs.types { return false }
        return true
    }
}
extension Variable {
    /// :nodoc:
    override public func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Variable else { return false }
        if self.name != rhs.name { return false }
        if self.typeName != rhs.typeName { return false }
        if self.isComputed != rhs.isComputed { return false }
        if self.isStatic != rhs.isStatic { return false }
        if self.readAccess != rhs.readAccess { return false }
        if self.writeAccess != rhs.writeAccess { return false }
        if self.defaultValue != rhs.defaultValue { return false }
        if self.annotations != rhs.annotations { return false }
        if self.attributes != rhs.attributes { return false }
        if self.definedInTypeName != rhs.definedInTypeName { return false }
        return true
    }
}
