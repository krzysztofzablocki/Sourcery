// Generated using Sourcery 1.8.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable vertical_whitespace


extension ArrayType {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? ArrayType else { return false }
        if self.name != rhs.name { return false }
        if self.elementTypeName != rhs.elementTypeName { return false }
        return true
    }
}
extension AssociatedType {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? AssociatedType else { return false }
        if self.name != rhs.name { return false }
        if self.typeName != rhs.typeName { return false }
        return true
    }
}
extension AssociatedValue {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? AssociatedValue else { return false }
        if self.localName != rhs.localName { return false }
        if self.externalName != rhs.externalName { return false }
        if self.typeName != rhs.typeName { return false }
        if self.defaultValue != rhs.defaultValue { return false }
        if self.annotations != rhs.annotations { return false }
        return true
    }
}
extension Attribute {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Attribute else { return false }
        if self.name != rhs.name { return false }
        if self.arguments != rhs.arguments { return false }
        if self._description != rhs._description { return false }
        return true
    }
}
extension BytesRange {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? BytesRange else { return false }
        if self.offset != rhs.offset { return false }
        if self.length != rhs.length { return false }
        return true
    }
}
extension Class {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Class else { return false }
        return super.isEqual(rhs)
    }
}
extension ClosureParameter {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? ClosureParameter else { return false }
        if self.argumentLabel != rhs.argumentLabel { return false }
        if self.name != rhs.name { return false }
        if self.typeName != rhs.typeName { return false }
        if self.`inout` != rhs.`inout` { return false }
        if self.defaultValue != rhs.defaultValue { return false }
        if self.annotations != rhs.annotations { return false }
        return true
    }
}
extension ClosureType {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? ClosureType else { return false }
        if self.name != rhs.name { return false }
        if self.parameters != rhs.parameters { return false }
        if self.returnTypeName != rhs.returnTypeName { return false }
        if self.isAsync != rhs.isAsync { return false }
        if self.asyncKeyword != rhs.asyncKeyword { return false }
        if self.`throws` != rhs.`throws` { return false }
        if self.throwsOrRethrowsKeyword != rhs.throwsOrRethrowsKeyword { return false }
        return true
    }
}
extension DictionaryType {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? DictionaryType else { return false }
        if self.name != rhs.name { return false }
        if self.valueTypeName != rhs.valueTypeName { return false }
        if self.keyTypeName != rhs.keyTypeName { return false }
        return true
    }
}
extension DiffableResult {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? DiffableResult else { return false }
        if self.identifier != rhs.identifier { return false }
        return true
    }
}
extension Enum {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Enum else { return false }
        if self.cases != rhs.cases { return false }
        if self.rawTypeName != rhs.rawTypeName { return false }
        return super.isEqual(rhs)
    }
}
extension EnumCase {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? EnumCase else { return false }
        if self.name != rhs.name { return false }
        if self.rawValue != rhs.rawValue { return false }
        if self.associatedValues != rhs.associatedValues { return false }
        if self.annotations != rhs.annotations { return false }
        if self.documentation != rhs.documentation { return false }
        if self.indirect != rhs.indirect { return false }
        return true
    }
}
extension FileParserResult {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? FileParserResult else { return false }
        if self.path != rhs.path { return false }
        if self.module != rhs.module { return false }
        if self.types != rhs.types { return false }
        if self.functions != rhs.functions { return false }
        if self.typealiases != rhs.typealiases { return false }
        if self.inlineRanges != rhs.inlineRanges { return false }
        if self.inlineIndentations != rhs.inlineIndentations { return false }
        if self.modifiedDate != rhs.modifiedDate { return false }
        if self.sourceryVersion != rhs.sourceryVersion { return false }
        return true
    }
}
extension GenericRequirement {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? GenericRequirement else { return false }
        if self.leftType != rhs.leftType { return false }
        if self.rightType != rhs.rightType { return false }
        if self.relationship != rhs.relationship { return false }
        if self.relationshipSyntax != rhs.relationshipSyntax { return false }
        return true
    }
}
extension GenericType {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? GenericType else { return false }
        if self.name != rhs.name { return false }
        if self.typeParameters != rhs.typeParameters { return false }
        return true
    }
}
extension GenericTypeParameter {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? GenericTypeParameter else { return false }
        if self.typeName != rhs.typeName { return false }
        return true
    }
}
extension Import {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Import else { return false }
        if self.kind != rhs.kind { return false }
        if self.path != rhs.path { return false }
        return true
    }
}
extension Method {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Method else { return false }
        if self.name != rhs.name { return false }
        if self.selectorName != rhs.selectorName { return false }
        if self.parameters != rhs.parameters { return false }
        if self.returnTypeName != rhs.returnTypeName { return false }
        if self.isAsync != rhs.isAsync { return false }
        if self.`throws` != rhs.`throws` { return false }
        if self.`rethrows` != rhs.`rethrows` { return false }
        if self.accessLevel != rhs.accessLevel { return false }
        if self.isStatic != rhs.isStatic { return false }
        if self.isClass != rhs.isClass { return false }
        if self.isFailableInitializer != rhs.isFailableInitializer { return false }
        if self.annotations != rhs.annotations { return false }
        if self.documentation != rhs.documentation { return false }
        if self.definedInTypeName != rhs.definedInTypeName { return false }
        if self.attributes != rhs.attributes { return false }
        if self.modifiers != rhs.modifiers { return false }
        return true
    }
}
extension MethodParameter {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? MethodParameter else { return false }
        if self.argumentLabel != rhs.argumentLabel { return false }
        if self.name != rhs.name { return false }
        if self.typeName != rhs.typeName { return false }
        if self.`inout` != rhs.`inout` { return false }
        if self.isVariadic != rhs.isVariadic { return false }
        if self.defaultValue != rhs.defaultValue { return false }
        if self.annotations != rhs.annotations { return false }
        return true
    }
}
extension Modifier {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Modifier else { return false }
        if self.name != rhs.name { return false }
        if self.detail != rhs.detail { return false }
        return true
    }
}
extension Protocol {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Protocol else { return false }
        if self.associatedTypes != rhs.associatedTypes { return false }
        if self.genericRequirements != rhs.genericRequirements { return false }
        return super.isEqual(rhs)
    }
}
extension ProtocolComposition {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? ProtocolComposition else { return false }
        if self.composedTypeNames != rhs.composedTypeNames { return false }
        return super.isEqual(rhs)
    }
}
extension Struct {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Struct else { return false }
        return super.isEqual(rhs)
    }
}
extension Subscript {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Subscript else { return false }
        if self.parameters != rhs.parameters { return false }
        if self.returnTypeName != rhs.returnTypeName { return false }
        if self.readAccess != rhs.readAccess { return false }
        if self.writeAccess != rhs.writeAccess { return false }
        if self.annotations != rhs.annotations { return false }
        if self.documentation != rhs.documentation { return false }
        if self.definedInTypeName != rhs.definedInTypeName { return false }
        if self.attributes != rhs.attributes { return false }
        if self.modifiers != rhs.modifiers { return false }
        return true
    }
}
extension TemplateContext {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TemplateContext else { return false }
        if self.parserResult != rhs.parserResult { return false }
        if self.functions != rhs.functions { return false }
        if self.types != rhs.types { return false }
        if self.argument != rhs.argument { return false }
        return true
    }
}
extension TupleElement {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TupleElement else { return false }
        if self.name != rhs.name { return false }
        if self.typeName != rhs.typeName { return false }
        return true
    }
}
extension TupleType {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TupleType else { return false }
        if self.name != rhs.name { return false }
        if self.elements != rhs.elements { return false }
        return true
    }
}
extension Type {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Type else { return false }
        if self.module != rhs.module { return false }
        if self.imports != rhs.imports { return false }
        if self.typealiases != rhs.typealiases { return false }
        if self.isExtension != rhs.isExtension { return false }
        if self.accessLevel != rhs.accessLevel { return false }
        if self.isUnknownExtension != rhs.isUnknownExtension { return false }
        if self.isGeneric != rhs.isGeneric { return false }
        if self.localName != rhs.localName { return false }
        if self.rawVariables != rhs.rawVariables { return false }
        if self.rawMethods != rhs.rawMethods { return false }
        if self.rawSubscripts != rhs.rawSubscripts { return false }
        if self.annotations != rhs.annotations { return false }
        if self.documentation != rhs.documentation { return false }
        if self.inheritedTypes != rhs.inheritedTypes { return false }
        if self.inherits != rhs.inherits { return false }
        if self.containedTypes != rhs.containedTypes { return false }
        if self.parentName != rhs.parentName { return false }
        if self.attributes != rhs.attributes { return false }
        if self.modifiers != rhs.modifiers { return false }
        if self.fileName != rhs.fileName { return false }
        if self.kind != rhs.kind { return false }
        return true
    }
}
extension TypeName {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TypeName else { return false }
        if self.name != rhs.name { return false }
        if self.generic != rhs.generic { return false }
        if self.isProtocolComposition != rhs.isProtocolComposition { return false }
        if self.attributes != rhs.attributes { return false }
        if self.modifiers != rhs.modifiers { return false }
        if self.tuple != rhs.tuple { return false }
        if self.array != rhs.array { return false }
        if self.dictionary != rhs.dictionary { return false }
        if self.closure != rhs.closure { return false }
        return true
    }
}
extension Typealias {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Typealias else { return false }
        if self.aliasName != rhs.aliasName { return false }
        if self.typeName != rhs.typeName { return false }
        if self.module != rhs.module { return false }
        if self.accessLevel != rhs.accessLevel { return false }
        if self.parentName != rhs.parentName { return false }
        return true
    }
}
extension Types {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Types else { return false }
        if self.types != rhs.types { return false }
        if self.typealiases != rhs.typealiases { return false }
        return true
    }
}
extension Variable {
    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Variable else { return false }
        if self.name != rhs.name { return false }
        if self.typeName != rhs.typeName { return false }
        if self.isComputed != rhs.isComputed { return false }
        if self.isAsync != rhs.isAsync { return false }
        if self.`throws` != rhs.`throws` { return false }
        if self.isStatic != rhs.isStatic { return false }
        if self.readAccess != rhs.readAccess { return false }
        if self.writeAccess != rhs.writeAccess { return false }
        if self.defaultValue != rhs.defaultValue { return false }
        if self.annotations != rhs.annotations { return false }
        if self.documentation != rhs.documentation { return false }
        if self.attributes != rhs.attributes { return false }
        if self.modifiers != rhs.modifiers { return false }
        if self.definedInTypeName != rhs.definedInTypeName { return false }
        return true
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
