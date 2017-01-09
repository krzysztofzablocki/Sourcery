// Generated using Sourcery 0.5.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

extension Attribute {
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Attribute else { return false }
        if self.name != rhs.name { return false }
        if self.arguments != rhs.arguments { return false }
        if self._description != rhs._description { return false }

        return true
    }
}

extension Enum {
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Enum else { return false }
        if self.cases != rhs.cases { return false }
        if self.rawTypeName != rhs.rawTypeName { return false }

        return super.isEqual(rhs)
    }
}

extension Enum.Case {
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Enum.Case else { return false }
        if self.name != rhs.name { return false }
        if self.rawValue != rhs.rawValue { return false }
        if self.associatedValues != rhs.associatedValues { return false }
        if self.annotations != rhs.annotations { return false }

        return true
    }
}

extension Enum.Case.AssociatedValue {
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Enum.Case.AssociatedValue else { return false }
        if self.localName != rhs.localName { return false }
        if self.externalName != rhs.externalName { return false }
        if self.typeName != rhs.typeName { return false }

        return true
    }
}

extension Method {
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Method else { return false }
        if self.parameters != rhs.parameters { return false }
        if self.selectorName != rhs.selectorName { return false }
        if self.returnTypeName != rhs.returnTypeName { return false }
        if self.accessLevel != rhs.accessLevel { return false }
        if self.isStatic != rhs.isStatic { return false }
        if self.isClass != rhs.isClass { return false }
        if self.isFailableInitializer != rhs.isFailableInitializer { return false }
        if self.annotations != rhs.annotations { return false }
        if self.attributes != rhs.attributes { return false }

        return true
    }
}

extension Method.Parameter {
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Method.Parameter else { return false }
        if self.argumentLabel != rhs.argumentLabel { return false }
        if self.name != rhs.name { return false }
        if self.typeName != rhs.typeName { return false }
        if self.type != rhs.type { return false }

        return true
    }
}

extension TupleType {
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TupleType else { return false }
        if self.name != rhs.name { return false }
        if self.elements != rhs.elements { return false }

        return true
    }
}

extension TupleType.Element {
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TupleType.Element else { return false }
        if self.name != rhs.name { return false }
        if self.typeName != rhs.typeName { return false }

        return true
    }
}

extension Type {
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Type else { return false }
        if self.typealiases != rhs.typealiases { return false }
        if self.isExtension != rhs.isExtension { return false }
        if self.accessLevel != rhs.accessLevel { return false }
        if self.isGeneric != rhs.isGeneric { return false }
        if self.localName != rhs.localName { return false }
        if self.variables != rhs.variables { return false }
        if self.methods != rhs.methods { return false }
        if self.annotations != rhs.annotations { return false }
        if self.inheritedTypes != rhs.inheritedTypes { return false }
        if self.containedTypes != rhs.containedTypes { return false }
        if self.parentName != rhs.parentName { return false }
        if self.attributes != rhs.attributes { return false }

        return true
    }
}

extension TypeName {
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? TypeName else { return false }
        if self.name != rhs.name { return false }
        if self.attributes != rhs.attributes { return false }
        if self.tuple != rhs.tuple { return false }

        return true
    }
}

extension Typealias {
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Typealias else { return false }
        if self.aliasName != rhs.aliasName { return false }
        if self.typeName != rhs.typeName { return false }
        if self.parentName != rhs.parentName { return false }

        return true
    }
}

extension Variable {
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? Variable else { return false }
        if self.name != rhs.name { return false }
        if self.typeName != rhs.typeName { return false }
        if self.isComputed != rhs.isComputed { return false }
        if self.isStatic != rhs.isStatic { return false }
        if self.readAccess != rhs.readAccess { return false }
        if self.writeAccess != rhs.writeAccess { return false }
        if self.annotations != rhs.annotations { return false }
        if self.attributes != rhs.attributes { return false }

        return true
    }
}
