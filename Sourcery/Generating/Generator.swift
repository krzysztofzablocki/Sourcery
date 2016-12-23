//
// Created by Krzysztof Zablocki on 13/09/2016.
// Copyright (c) 2016 Pixle. All rights reserved.
//

import Foundation
import Stencil

private extension Type {
    var isClass: Bool {
        let isNotClass = self is Struct || self is Enum || self is Protocol
        return !isNotClass && !isExtension
    }
}

private class TypesReflectionBox: NSObject {
    private let types: [Type]

    init(types: [Type]) {
        self.types = types
        super.init()
    }

    /// Lists all known classes in the project
    lazy var classes: [Type] = {
        return self.types.filter { $0.isClass }
    }()

    /// lists all known types, excluding protocols
    lazy var all: [Type] = {
        return self.types.filter { !($0 is Protocol) }
    }()

    /// Lists all known protocols
    lazy var protocols: [Type] = {
        return self.types.filter { $0 is Protocol }
    }()

    /// Lists all known structs
    lazy var structs: [Type] = {
        return self.types.filter { $0 is Struct }
    }()

    /// Lists all known enums
    lazy var enums: [Type] = {
        return self.types.filter { $0 is Enum }
    }()

    /// Lists all encountered types, even if they are not known e.g. Apple or 3rd party frameworks
    lazy var based: [String: [Type]] = {
        var content = [String: [Type]]()
        self.types.forEach { type in
            type.based.keys.forEach { name in
                var list = content[name] ?? [Type]()
                list.append(type)
                content[name] = list
            }
        }
        return content
    }()

    /// Contains reference to types inheriting from any known class
    lazy var inheriting: [String: [Type]] = {
        var content = [String: [Type]]()
        self.classes.forEach { type in
            type.inherits.keys.forEach { name in
                var list = content[name] ?? [Type]()
                list.append(type)
                content[name] = list
            }
        }
        return content
    }()

    /// Contains reference to types implementing any known protocol
    lazy var implementing: [String: [Type]] = {
        var content = [String: [Type]]()
        self.types.forEach { type in
            type.implements.keys.forEach { name in
                var list = content[name] ?? [Type]()
                list.append(type)
                content[name] = list
            }
        }
        return content
    }()
}

extension Type {
    override func value(forUndefinedKey key: String) -> Any? {
        if let innerType = containedTypes.lazy.filter({ $0.localName == key }).first {
            return innerType
        }

        return super.value(forUndefinedKey: key)
    }
}

enum Generator {
    private static func updateTypeRelationship(for type: Type, typesByName: [String: Type], processed: inout [String: Bool]) {
        type.based.keys.forEach { name in
            guard let baseType = typesByName[name] else { return }
            if processed[name] != true {
                processed[name] = true
                updateTypeRelationship(for: baseType, typesByName: typesByName, processed: &processed)
            }

            baseType.based.keys.forEach {  type.based[$0] = $0 }
            baseType.inherits.keys.forEach {  type.inherits[$0] = $0 }
            baseType.implements.keys.forEach {  type.implements[$0] = $0 }

            if baseType.isClass {
                type.inherits[name] = name
            } else if baseType is Protocol {
                type.implements[name] = name
            }
        }
    }

    static func generate(_ types: [Type], template: Template) throws -> String {
        var typesByName = [String: Type]()
        types.forEach { typesByName[$0.name] = $0 }

        var processed = [String: Bool]()
        types.forEach { type in
            if let supertype = type.inheritedTypes.first.flatMap({ typesByName[$0] }), supertype.isClass {
                type.supertype = supertype
            }
            processed[type.name] = true
            updateTypeRelationship(for: type, typesByName: typesByName, processed: &processed)
        }

        let context: [String: Any]? = [
            "types": TypesReflectionBox(types: types),
            "type": typesByName
            ]

        return try template.render(context)
    }
}
