// Generated using Sourcery 0.5.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

extension Attribute: Diffable {
    func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let rhs = object as? Attribute else {
            results.append("Incorrect type <expected: Attribute, received: \(type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: rhs.name))
        results.append(contentsOf: DiffableResult(identifier: "arguments").trackDifference(actual: self.arguments, expected: rhs.arguments))
        results.append(contentsOf: DiffableResult(identifier: "_description").trackDifference(actual: self._description, expected: rhs._description))

        return results
    }
}
extension Class {
    override func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()

        results.append(contentsOf: super.diffAgainst(object))
        return results
    }
}
extension Enum {
    override func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let rhs = object as? Enum else {
            results.append("Incorrect type <expected: Enum, received: \(type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "cases").trackDifference(actual: self.cases, expected: rhs.cases))
        results.append(contentsOf: DiffableResult(identifier: "rawTypeName").trackDifference(actual: self.rawTypeName, expected: rhs.rawTypeName))

        results.append(contentsOf: super.diffAgainst(object))
        return results
    }
}
extension Enum.Case: Diffable {
    func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let rhs = object as? Enum.Case else {
            results.append("Incorrect type <expected: Enum.Case, received: \(type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: rhs.name))
        results.append(contentsOf: DiffableResult(identifier: "rawValue").trackDifference(actual: self.rawValue, expected: rhs.rawValue))
        results.append(contentsOf: DiffableResult(identifier: "associatedValues").trackDifference(actual: self.associatedValues, expected: rhs.associatedValues))
        results.append(contentsOf: DiffableResult(identifier: "annotations").trackDifference(actual: self.annotations, expected: rhs.annotations))

        return results
    }
}
extension Enum.Case.AssociatedValue: Diffable {
    func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let rhs = object as? Enum.Case.AssociatedValue else {
            results.append("Incorrect type <expected: Enum.Case.AssociatedValue, received: \(type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "localName").trackDifference(actual: self.localName, expected: rhs.localName))
        results.append(contentsOf: DiffableResult(identifier: "externalName").trackDifference(actual: self.externalName, expected: rhs.externalName))
        results.append(contentsOf: DiffableResult(identifier: "typeName").trackDifference(actual: self.typeName, expected: rhs.typeName))

        return results
    }
}
extension GenerationContext: Diffable {
    func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let rhs = object as? GenerationContext else {
            results.append("Incorrect type <expected: GenerationContext, received: \(type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "types").trackDifference(actual: self.types, expected: rhs.types))
        results.append(contentsOf: DiffableResult(identifier: "typeByName").trackDifference(actual: self.typeByName, expected: rhs.typeByName))
        results.append(contentsOf: DiffableResult(identifier: "arguments").trackDifference(actual: self.arguments, expected: rhs.arguments))

        return results
    }
}
extension Method: Diffable {
    func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let rhs = object as? Method else {
            results.append("Incorrect type <expected: Method, received: \(type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "selectorName").trackDifference(actual: self.selectorName, expected: rhs.selectorName))
        results.append(contentsOf: DiffableResult(identifier: "parameters").trackDifference(actual: self.parameters, expected: rhs.parameters))
        results.append(contentsOf: DiffableResult(identifier: "returnTypeName").trackDifference(actual: self.returnTypeName, expected: rhs.returnTypeName))
        results.append(contentsOf: DiffableResult(identifier: "accessLevel").trackDifference(actual: self.accessLevel, expected: rhs.accessLevel))
        results.append(contentsOf: DiffableResult(identifier: "isStatic").trackDifference(actual: self.isStatic, expected: rhs.isStatic))
        results.append(contentsOf: DiffableResult(identifier: "isClass").trackDifference(actual: self.isClass, expected: rhs.isClass))
        results.append(contentsOf: DiffableResult(identifier: "isFailableInitializer").trackDifference(actual: self.isFailableInitializer, expected: rhs.isFailableInitializer))
        results.append(contentsOf: DiffableResult(identifier: "annotations").trackDifference(actual: self.annotations, expected: rhs.annotations))
        results.append(contentsOf: DiffableResult(identifier: "attributes").trackDifference(actual: self.attributes, expected: rhs.attributes))

        return results
    }
}
extension Method.Parameter: Diffable {
    func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let rhs = object as? Method.Parameter else {
            results.append("Incorrect type <expected: Method.Parameter, received: \(type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "argumentLabel").trackDifference(actual: self.argumentLabel, expected: rhs.argumentLabel))
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: rhs.name))
        results.append(contentsOf: DiffableResult(identifier: "typeName").trackDifference(actual: self.typeName, expected: rhs.typeName))
        results.append(contentsOf: DiffableResult(identifier: "type").trackDifference(actual: self.type, expected: rhs.type))

        return results
    }
}
extension Protocol {
    override func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()

        results.append(contentsOf: super.diffAgainst(object))
        return results
    }
}
extension Struct {
    override func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()

        results.append(contentsOf: super.diffAgainst(object))
        return results
    }
}
extension TupleType: Diffable {
    func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let rhs = object as? TupleType else {
            results.append("Incorrect type <expected: TupleType, received: \(type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: rhs.name))
        results.append(contentsOf: DiffableResult(identifier: "elements").trackDifference(actual: self.elements, expected: rhs.elements))

        return results
    }
}
extension TupleType.Element: Diffable {
    func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let rhs = object as? TupleType.Element else {
            results.append("Incorrect type <expected: TupleType.Element, received: \(type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: rhs.name))
        results.append(contentsOf: DiffableResult(identifier: "typeName").trackDifference(actual: self.typeName, expected: rhs.typeName))

        return results
    }
}
extension Type: Diffable {
    func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let rhs = object as? Type else {
            results.append("Incorrect type <expected: Type, received: \(type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "typealiases").trackDifference(actual: self.typealiases, expected: rhs.typealiases))
        results.append(contentsOf: DiffableResult(identifier: "isExtension").trackDifference(actual: self.isExtension, expected: rhs.isExtension))
        results.append(contentsOf: DiffableResult(identifier: "accessLevel").trackDifference(actual: self.accessLevel, expected: rhs.accessLevel))
        results.append(contentsOf: DiffableResult(identifier: "isGeneric").trackDifference(actual: self.isGeneric, expected: rhs.isGeneric))
        results.append(contentsOf: DiffableResult(identifier: "localName").trackDifference(actual: self.localName, expected: rhs.localName))
        results.append(contentsOf: DiffableResult(identifier: "variables").trackDifference(actual: self.variables, expected: rhs.variables))
        results.append(contentsOf: DiffableResult(identifier: "methods").trackDifference(actual: self.methods, expected: rhs.methods))
        results.append(contentsOf: DiffableResult(identifier: "annotations").trackDifference(actual: self.annotations, expected: rhs.annotations))
        results.append(contentsOf: DiffableResult(identifier: "inheritedTypes").trackDifference(actual: self.inheritedTypes, expected: rhs.inheritedTypes))
        results.append(contentsOf: DiffableResult(identifier: "containedTypes").trackDifference(actual: self.containedTypes, expected: rhs.containedTypes))
        results.append(contentsOf: DiffableResult(identifier: "parentName").trackDifference(actual: self.parentName, expected: rhs.parentName))
        results.append(contentsOf: DiffableResult(identifier: "attributes").trackDifference(actual: self.attributes, expected: rhs.attributes))

        return results
    }
}
extension TypeName: Diffable {
    func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let rhs = object as? TypeName else {
            results.append("Incorrect type <expected: TypeName, received: \(type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: rhs.name))
        results.append(contentsOf: DiffableResult(identifier: "attributes").trackDifference(actual: self.attributes, expected: rhs.attributes))
        results.append(contentsOf: DiffableResult(identifier: "tuple").trackDifference(actual: self.tuple, expected: rhs.tuple))

        return results
    }
}
extension Typealias: Diffable {
    func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let rhs = object as? Typealias else {
            results.append("Incorrect type <expected: Typealias, received: \(type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "aliasName").trackDifference(actual: self.aliasName, expected: rhs.aliasName))
        results.append(contentsOf: DiffableResult(identifier: "typeName").trackDifference(actual: self.typeName, expected: rhs.typeName))
        results.append(contentsOf: DiffableResult(identifier: "parentName").trackDifference(actual: self.parentName, expected: rhs.parentName))

        return results
    }
}
extension Variable: Diffable {
    func diffAgainst(_ object: Any?) -> DiffableResult {
        let results = DiffableResult()
        guard let rhs = object as? Variable else {
            results.append("Incorrect type <expected: Variable, received: \(type(of: object))>")
            return results
        }
        results.append(contentsOf: DiffableResult(identifier: "name").trackDifference(actual: self.name, expected: rhs.name))
        results.append(contentsOf: DiffableResult(identifier: "typeName").trackDifference(actual: self.typeName, expected: rhs.typeName))
        results.append(contentsOf: DiffableResult(identifier: "isComputed").trackDifference(actual: self.isComputed, expected: rhs.isComputed))
        results.append(contentsOf: DiffableResult(identifier: "isStatic").trackDifference(actual: self.isStatic, expected: rhs.isStatic))
        results.append(contentsOf: DiffableResult(identifier: "readAccess").trackDifference(actual: self.readAccess, expected: rhs.readAccess))
        results.append(contentsOf: DiffableResult(identifier: "writeAccess").trackDifference(actual: self.writeAccess, expected: rhs.writeAccess))
        results.append(contentsOf: DiffableResult(identifier: "annotations").trackDifference(actual: self.annotations, expected: rhs.annotations))
        results.append(contentsOf: DiffableResult(identifier: "attributes").trackDifference(actual: self.attributes, expected: rhs.attributes))

        return results
    }
}
