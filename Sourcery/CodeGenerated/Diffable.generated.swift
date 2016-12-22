// Generated using Sourcery 0.4.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

extension Enum {
     override func diffAgainst(_ object: Any?) -> DiffableResult {
        var results = DiffableResult()

        guard let rhs = object as? Enum else {
          results.append("Incorrect type, expected Enum, received: \(type(of: object))")
          return results
        }
        if self.cases != rhs.cases { results.append("Incorrect cases, expected \(self.cases), received: \(rhs.cases)") }
        if self.rawType != rhs.rawType { results.append("Incorrect rawType, expected \(self.rawType), received: \(rhs.rawType)") }

        results.append(contentsOf: super.diffAgainst(object))
        return results
    }
}

extension Protocol {
     override func diffAgainst(_ object: Any?) -> DiffableResult {
        var results = DiffableResult()

        results.append(contentsOf: super.diffAgainst(object))
        return results
    }
}

extension Struct {
     override func diffAgainst(_ object: Any?) -> DiffableResult {
        var results = DiffableResult()

        results.append(contentsOf: super.diffAgainst(object))
        return results
    }
}

extension Type: Diffable {
    func diffAgainst(_ object: Any?) -> DiffableResult {
        var results = DiffableResult()

        guard let rhs = object as? Type else {
          results.append("Incorrect type, expected Type, received: \(type(of: object))")
          return results
        }
        if self.typealiases != rhs.typealiases { results.append("Incorrect typealiases, expected \(self.typealiases), received: \(rhs.typealiases)") }
        if self.isExtension != rhs.isExtension { results.append("Incorrect isExtension, expected \(self.isExtension), received: \(rhs.isExtension)") }
        if self.accessLevel != rhs.accessLevel { results.append("Incorrect accessLevel, expected \(self.accessLevel), received: \(rhs.accessLevel)") }
        if self.isGeneric != rhs.isGeneric { results.append("Incorrect isGeneric, expected \(self.isGeneric), received: \(rhs.isGeneric)") }
        if self.localName != rhs.localName { results.append("Incorrect localName, expected \(self.localName), received: \(rhs.localName)") }
        if self.variables != rhs.variables { results.append("Incorrect variables, expected \(self.variables), received: \(rhs.variables)") }
        if self.annotations != rhs.annotations { results.append("Incorrect annotations, expected \(self.annotations), received: \(rhs.annotations)") }
        if self.inheritedTypes != rhs.inheritedTypes { results.append("Incorrect inheritedTypes, expected \(self.inheritedTypes), received: \(rhs.inheritedTypes)") }
        if self.containedTypes != rhs.containedTypes { results.append("Incorrect containedTypes, expected \(self.containedTypes), received: \(rhs.containedTypes)") }
        if self.parentName != rhs.parentName { results.append("Incorrect parentName, expected \(self.parentName), received: \(rhs.parentName)") }

        return results
    }
}

extension Typealias: Diffable {
    func diffAgainst(_ object: Any?) -> DiffableResult {
        var results = DiffableResult()

        guard let rhs = object as? Typealias else {
          results.append("Incorrect type, expected Typealias, received: \(type(of: object))")
          return results
        }
        if self.aliasName != rhs.aliasName { results.append("Incorrect aliasName, expected \(self.aliasName), received: \(rhs.aliasName)") }
        if self.typeName != rhs.typeName { results.append("Incorrect typeName, expected \(self.typeName), received: \(rhs.typeName)") }
        if self.parentName != rhs.parentName { results.append("Incorrect parentName, expected \(self.parentName), received: \(rhs.parentName)") }

        return results
    }
}

extension Variable: Diffable {
    func diffAgainst(_ object: Any?) -> DiffableResult {
        var results = DiffableResult()

        guard let rhs = object as? Variable else {
          results.append("Incorrect type, expected Variable, received: \(type(of: object))")
          return results
        }
        if self.name != rhs.name { results.append("Incorrect name, expected \(self.name), received: \(rhs.name)") }
        if self.typeName != rhs.typeName { results.append("Incorrect typeName, expected \(self.typeName), received: \(rhs.typeName)") }
        if self.isComputed != rhs.isComputed { results.append("Incorrect isComputed, expected \(self.isComputed), received: \(rhs.isComputed)") }
        if self.isStatic != rhs.isStatic { results.append("Incorrect isStatic, expected \(self.isStatic), received: \(rhs.isStatic)") }
        if self.readAccess != rhs.readAccess { results.append("Incorrect readAccess, expected \(self.readAccess), received: \(rhs.readAccess)") }
        if self.writeAccess != rhs.writeAccess { results.append("Incorrect writeAccess, expected \(self.writeAccess), received: \(rhs.writeAccess)") }
        if self.annotations != rhs.annotations { results.append("Incorrect annotations, expected \(self.annotations), received: \(rhs.annotations)") }

        return results
    }
}
