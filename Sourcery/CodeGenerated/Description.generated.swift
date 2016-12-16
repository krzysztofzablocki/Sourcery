// Generated using Sourcery 0.3.7 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

extension Enum {
    override var description: String {
        var string = super.description
        string += "cases = \(cases), "
        string += "rawType = \(rawType), "
        string += "inheritedTypes = \(inheritedTypes), "
        string += "hasAssociatedValues = \(hasAssociatedValues), "
        return string
    }
}

extension Enum.Case {
    override var description: String {
        var string = "\(type(of: self)): "
        string += "name = \(name), "
        string += "rawValue = \(rawValue), "
        string += "associatedValues = \(associatedValues), "
        string += "hasAssociatedValue = \(hasAssociatedValue), "
        return string
    }
}

extension Enum.Case.AssociatedValue {
    override var description: String {
        var string = "\(type(of: self)): "
        string += "name = \(name), "
        string += "type = \(type), "
        return string
    }
}

extension Type {
    override var description: String {
        var string = "\(type(of: self)): "
        string += "isExtension = \(isExtension), "
        string += "kind = \(kind), "
        string += "accessLevel = \(accessLevel), "
        string += "name = \(name), "
        string += "localName = \(localName), "
        string += "staticVariables = \(staticVariables), "
        string += "variables = \(variables), "
        string += "annotations = \(annotations), "
        string += "computedVariables = \(computedVariables), "
        string += "storedVariables = \(storedVariables), "
        string += "inheritedTypes = \(inheritedTypes), "
        string += "containedTypes = \(containedTypes), "
        string += "parentName = \(parentName), "
        return string
    }
}

extension Variable {
    override var description: String {
        var string = "\(type(of: self)): "
        string += "name = \(name), "
        string += "typeName = \(typeName), "
        string += "isOptional = \(isOptional), "
        string += "isComputed = \(isComputed), "
        string += "isStatic = \(isStatic), "
        string += "readAccess = \(readAccess), "
        string += "writeAccess = \(writeAccess), "
        string += "annotations = \(annotations), "
        return string
    }
}
