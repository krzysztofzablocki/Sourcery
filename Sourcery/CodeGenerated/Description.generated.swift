// Generated using Sourcery 0.4.9 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

extension Enum {
    override var description: String {
        var string = super.description
        string += "cases = \(cases), "
        string += "rawType = \(rawType), "
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
        string += "annotations = \(annotations), "
        string += "hasAssociatedValue = \(hasAssociatedValue), "
        return string
    }
}

extension Enum.Case.AssociatedValue {
    override var description: String {
        var string = "\(type(of: self)): "
        string += "name = \(name), "
        string += "typeName = \(typeName), "
        return string
    }
}

extension Method {
    override var description: String {
        var string = "\(type(of: self)): "
        string += "parameters = \(parameters), "
        string += "shortName = \(shortName), "
        string += "selectorName = \(selectorName), "
        string += "returnTypeName = \(returnTypeName), "
        string += "accessLevel = \(accessLevel), "
        string += "isStatic = \(isStatic), "
        string += "isClass = \(isClass), "
        string += "isInitializer = \(isInitializer), "
        string += "isFailableInitializer = \(isFailableInitializer), "
        string += "annotations = \(annotations), "
        return string
    }
}

extension Method.Parameter {
    override var description: String {
        var string = "\(type(of: self)): "
        string += "argumentLabel = \(argumentLabel), "
        string += "name = \(name), "
        string += "typeName = \(typeName), "
        string += "type = \(type), "
        return string
    }
}

extension Type {
    override var description: String {
        var string = "\(type(of: self)): "
        string += "typealiases = \(typealiases), "
        string += "isExtension = \(isExtension), "
        string += "kind = \(kind), "
        string += "accessLevel = \(accessLevel), "
        string += "name = \(name), "
        string += "isGeneric = \(isGeneric), "
        string += "localName = \(localName), "
        string += "variables = \(variables), "
        string += "methods = \(methods), "
        string += "initializers = \(initializers), "
        string += "annotations = \(annotations), "
        string += "staticVariables = \(staticVariables), "
        string += "computedVariables = \(computedVariables), "
        string += "storedVariables = \(storedVariables), "
        string += "inheritedTypes = \(inheritedTypes), "
        string += "containedTypes = \(containedTypes), "
        string += "parentName = \(parentName), "
        return string
    }
}

extension Typealias {
    override var description: String {
        var string = "\(type(of: self)): "
        string += "aliasName = \(aliasName), "
        string += "typeName = \(typeName), "
        string += "parentName = \(parentName), "
        string += "name = \(name), "
        return string
    }
}

extension Variable {
    override var description: String {
        var string = "\(type(of: self)): "
        string += "name = \(name), "
        string += "typeName = \(typeName), "
        string += "isComputed = \(isComputed), "
        string += "isStatic = \(isStatic), "
        string += "readAccess = \(readAccess), "
        string += "writeAccess = \(writeAccess), "
        string += "annotations = \(annotations), "
        return string
    }
}
